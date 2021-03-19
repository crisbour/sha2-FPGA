#!/bin/python

import random
import logging
import warnings
import struct

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.drivers import BitDriver
from cocotb.result import ReturnValue
from cocotb.regression import TestFactory
from cocotb.scoreboard import Scoreboard
from cocotbext.axis import AXIS_Driver, AXIS_Monitor
from cocotb.binary import BinaryValue

from collections import deque

# My sha model:
from sha_model import Sha

# Data generators
with warnings.catch_warnings():
    warnings.simplefilter('ignore')
    from cocotb.generators.byte import random_data, get_bytes
    from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

BLOCK_BIT_WIDTH = 512
BLOCK_BYTE_WIDTH = 64

class WtUnitTB(object):

    def __init__(self, dut, codec, debug=False):
        self.dut = dut
        self.codec = codec
        self.sha = Sha.get_method(codec=codec)
        self.dut._log.info(f'Creating testbench with sha_type={self.sha.sha_name}')

        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axis_aclk)
        self.backpressure = BitDriver(dut.m_axis_tready, dut.axis_aclk)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axis_aclk, lsb_first=False)

        self.expected_output = []

        # Create a scoreboard on the m_axis bus
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.m_axis, self.expected_output)

        # Reconstrut the input transactions
        self.s_axis_recovered = AXIS_Monitor(dut, "s_axis", dut.axis_aclk, callback=self.model)

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
        self.dut._log.debug('Transaction={}'.format(transaction))
        message = transaction['data']
        self.sha.init()
        buffer = self.sha.wt_transaction(message=message)
        self.expected_output.append({'data': buffer, 'user':80*'0'+little_endian_codec(self.codec)+32*'0'})

def random_message(blocks512 ,min_blocks=1, max_blocks=4, npackets=4):
    """random string data of a random length"""
    if blocks512>>1:
        max_blocks = int(max_blocks/2)
        if(max_blocks == 0):
            max_blocks = 1
        mult_blocks = 2
    else:
        mult_blocks = 1
    for _ in range(npackets):
        yield get_bytes(BLOCK_BYTE_WIDTH*mult_blocks*random.randint(min_blocks, max_blocks), random_data())

def little_endian_codec(codec):
    if(codec >= 0x80):
        codec = codec<<8 | codec >>8;
    return "{0:016b}".format(codec)

async def run_test(dut, data_in=None, codec='sha256', backpressure_inserter=None):
    # dut._log.setLevel(logging.DEBUG)
    dut.m_axis_tready <= 0;

    """ Setup testbench and run a test. """
    clock = Clock(dut.axis_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    tb = WtUnitTB(dut, codec, True)

    await tb.reset()

    dut.m_axis_tready <= 1;
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())

    # Send in the packets
    for transaction in data_in(Sha.blocks512(codec)):
        tb.s_axis.bus.tuser <= BinaryValue(80*'0'+little_endian_codec(codec)+32*'0')
        await tb.s_axis.send(transaction)

    # Wait for last transmission
    while not ( dut.m_axis_tlast.value and dut.m_axis_tvalid.value and dut.m_axis_tready.value):
        await RisingEdge(dut.axis_aclk)
    await RisingEdge(dut.axis_aclk)
    
    
    dut._log.info("DUT testbench finished!")

    raise tb.scoreboard.result


# Register the test.
factory = TestFactory(run_test)
factory.add_option("codec", [0x12,0x13,0x09,0x10])
factory.add_option("data_in", [random_message])
factory.add_option("backpressure_inserter", 
                    [None, random_50_percent]) # Throtle tready: random_50_percent
factory.generate_tests()
