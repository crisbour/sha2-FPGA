#!/bin/python

import warnings
import random
import logging
import struct

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.drivers import BitDriver
from cocotb.result import ReturnValue
from cocotb.regression import TestFactory
from cocotb.scoreboard import Scoreboard
from cocotbext.axis import *


# Data generators
with warnings.catch_warnings():
    warnings.simplefilter('ignore')
    from cocotb.generators.byte import random_data, get_bytes
    from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

class MultihashTB(object):

    def __init__(self, dut, codec, debug=False):
        dut._log.info(f"Preparing tb for multihash, codec={hex(codec)}")
        self.dut = dut
        self.codec = codec    # sha_type_actual

        dut._log.info(f"AXI Stream driver and sink.")
        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axis_aclk, lsb_first=False)
        self.backpressure = BitDriver(dut.m_axis_tready, dut.axis_aclk)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axis_aclk, lsb_first=False)

        self.expected_output = []
        dut._log.info("Setup scoreboard.")
        # Create a scoreboard on the m_axis bus
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.m_axis, self.expected_output)

        dut._log.info('Reconstruct input transactions')
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

    def _encode(self, number):
        """Pack `number` into varint bytes"""
        buf = b''
        while True:
            towrite = number & 0x7f
            number >>= 7
            if number:
                buf += struct.pack('B',(towrite | 0x80))
            else:
                buf += struct.pack('B',towrite)
                break
        return buf
    
    def _pack_codec(self,codec):
        buf = b''
        while codec:
            buf = struct.pack('B',codec & 0xff) + buf
            codec = codec >> 8
        return buf

    def model(self, transaction):
        message = transaction['data']
        self.dut._log.debug(f'Incoming message={message}')
        length = len(message)
        self.dut._log.info(f'Transaction of length {length} bytes long has been received.')
        new_message = self._pack_codec(self.codec) + self._encode(length) + message
        print(f'New Message: {new_message}')
        self.expected_output.append({'data': new_message,'user':80*'0'+"{0:016b}".format(0x31)+32*'0'})

def random_message(min_size=1, max_size=256, npackets=4):
    """random string data of a random length"""
    for i in range(npackets):
        yield get_bytes(random.randint(min_size, max_size), random_data())


async def run_test(dut, data_in=None, codec=None, backpressure_inserter=None):
    dut.m_axis_tready <= 0
    dut.log.setLevel(logging.DEBUG)

    dut._log.info('Setting up the clock.')
    """ Setup testbench and run a test. """
    clock = Clock(dut.axis_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock

    dut._log.info('Instantiate testbench object')
    tb = MultihashTB(dut, codec, False) # Debug=False

    await tb.reset()
    dut.m_axis_tready <= 1
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())



    # Send in the packets
    dut._log.info('Send data to multihash_encode module')
    if(codec & 0xFF00):
        codec_lit_end = codec>>8 | (codec<<8 & 0xFF00)
    else:
        codec_lit_end = codec
    for transaction in data_in():
        tb.s_axis.bus.tuser <= BinaryValue(80*'0'+"{0:016b}".format(codec_lit_end)+32*'0')
        await tb.s_axis.send(transaction)

    dut._log.info('Wait for last transmission')

    # Wait for all transactions to be received
    wait_transac = True
    while(wait_transac):
        await RisingEdge(dut.axis_aclk)
        wait_transac = False
        for monitor, expected_output in tb.scoreboard.expected.items():
            if(len(expected_output)):
                wait_transac = True
    
    dut._log.info("DUT testbench finished!")

    raise tb.scoreboard.result


# Register the test.
factory = TestFactory(run_test)
factory.add_option("codec", [0x12,0x13,0xB21B])
factory.add_option("data_in", [random_message])
factory.add_option("backpressure_inserter", 
                    [None, random_50_percent])
factory.generate_tests()
