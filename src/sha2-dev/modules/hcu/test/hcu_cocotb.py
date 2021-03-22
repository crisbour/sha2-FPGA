import cocotb
import random
import struct
import warnings
import logging
from collections import deque

from cocotb.triggers import Timer
from cocotb.regression import TestFactory
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.monitors import BusMonitor
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.scoreboard import Scoreboard

from cocotbext.axis import AXIS_Driver, AXIS_Monitor

# Data generators
from cocotb.generators.byte import random_data, get_bytes
from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

# My sha model:
from sha_model import Sha

from typing import Iterator

N_WORDS = 8
BIT_WIDTH_WORDS = 64
BYTE_WIDTH_WORDS = 8

def little_endian_codec(codec):
    if(codec >= 0x80):
        codec = codec<<8 | codec >>8;
    return "{0:016b}".format(codec)

class HcuTb(object):
    def __init__(self, dut, codec, debug=False):
        dut._log.info(f"Setting up test bench object with codec={codec}")
        self.dut = dut
        self.codec = codec
        self.sha = Sha.get_method(codec=codec)

        self.dut._log.info(f"Configure driver, monitors and scoreboard for {self.sha.sha_name}")
        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axis_aclk, lsb_first=False)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axis_aclk, lsb_first=False)

        self.expected_output = []
        
        # Create a scoreboard on the m_axis bus
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.m_axis, self.expected_output)  

        # Reconstrut the input transactions
        self.s_axis_recovered = AXIS_Monitor(dut, "s_axis", dut.axis_aclk, callback=self.model, lsb_first=False)

        level = logging.DEBUG if debug else logging.WARNING
        self.s_axis.log.setLevel(level)
        self.s_axis_recovered.log.setLevel(level)

    async def reset(self,duration = 2):
        self.dut._log.debug("Resetting DUT")
        self.dut.axis_resetn <= 0
        await Timer(duration, units='ns')
        await RisingEdge(self.dut.axis_aclk)
        self.dut.axis_resetn <= 1
        self.dut._log.debug("Out of reset")    
    
    def model(self, transaction):
        self.dut._log.debug(f'Transaction = {transaction}')
        message = transaction['data']
        # print(f'Length or received tansaction = {len(message)}')
        self.sha.init()
        words_block = self.sha.wt_iters
        while(message):
            for i in range(words_block):
                # print(f'Word to unpack: {message[i*BYTE_WIDTH_WORDS:(i+1)*BYTE_WIDTH_WORDS]}')
                w_temp, = struct.unpack('!Q', message[i*BYTE_WIDTH_WORDS:(i+1)*BYTE_WIDTH_WORDS])
                self.sha.update(w_temp)
            message = message[BYTE_WIDTH_WORDS*words_block:]
        
        self.dut._log.debug(f'Hash Computed = {[hex(reg) for  reg in self.sha.get_hash()]}')
        self.expected_output.append({'data': self.sha.get_bytes_hash(), 'user':80*'0'+little_endian_codec(self.codec)+32*'0'})

def random_wt(word_size) -> Iterator[int]:
    wt_empty_bytes = BYTE_WIDTH_WORDS - word_size
    while True:
        for i in range(BYTE_WIDTH_WORDS):
            if i<wt_empty_bytes:
                yield 0
            else:
                yield random.randrange(256)



# def random_wt(sha_type=0b01, min_blocks=1, max_blocks=4, npackets=4):
#     virtual_bytes_per_block = BYTE_WIDTH_WORDS*Sha.iters(sha_type)
#     for _ in range(npackets):
#         yield get_bytes(virtual_bytes_per_block*random.randint(min_blocks, max_blocks), random_data())

def format_wt(codec, min_blocks=1, max_blocks=4, npackets=4):
    dumy_sha_instance = Sha.get_method(codec)
    virtual_bytes_per_block = BYTE_WIDTH_WORDS*dumy_sha_instance.wt_iters
    gen = random_wt(dumy_sha_instance.word_size)
    for _ in range(npackets):
        yield get_bytes(virtual_bytes_per_block*random.randint(min_blocks,max_blocks),gen)
        
async def run_test(dut, codec=0x12, data_in=None, backpressure_inserter=None):
    dut._log.info(f"Init testbench with codec={codec}")

    dut.m_axis_tready <= 0
    #dut._log.setLevel(logging.DEBUG)
    """ Setup testbench and run a test. """
    clock = Clock(dut.axis_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    tb = HcuTb(dut, codec)

    await tb.reset()

    dut.m_axis_tready <= 1
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())

    dut._log.info('Send Wt parsed from message')
    # Send in the packets
    for transaction in format_wt(codec):
        tb.s_axis.bus.tuser <= BinaryValue(80*'0'+little_endian_codec(codec)+32*'0')
        #transaction = format_wt_message(transaction, sha_type=sha_type)
        await tb.s_axis.send(transaction)

    dut._log.info('Wait for last outgoing transaction to be monitored')
    # Wait for last transmission
    while not (dut.m_axis_tlast.value and dut.m_axis_tvalid.value and dut.m_axis_tready.value):
        await RisingEdge(dut.axis_aclk)
    for _ in range(3):
        await RisingEdge(dut.axis_aclk)
    
    dut._log.info("DUT testbench finished!")

    raise tb.scoreboard.result

factory = TestFactory(run_test)
factory.add_option('codec', [0x12,0x13,0x09,0x10])
factory.add_option('data_in', [format_wt])
#factory.add_option('H_in', [random_hash_stream])
factory.generate_tests()