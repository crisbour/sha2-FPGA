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

# import sys
# sys.path.append("../../")
from sha_model import Sha


# Data generators
with warnings.catch_warnings():
    warnings.simplefilter('ignore')
    from cocotb.generators.byte import random_data, get_bytes
    from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

DATA_BIT_WIDTH = 512
DATA_BYTE_WIDTH = int(DATA_BIT_WIDTH/8)

def little_endian_codec(codec):
    if(codec >= 0x80):
        codec = codec<<8 | codec >>8;
    return "{0:016b}".format(codec)

class DigestTB(object):

    def __init__(self, dut, codec, debug=False):
        self.dut = dut
        self.codec = codec
        self.sha = Sha.get_method(codec)
        
        self.dut._log.info("Configure driver, monitors and scoreboard")
        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axis_aclk, lsb_first=False)
        self.backpressure = BitDriver(dut.m_axis_tready, dut.axis_aclk)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axis_aclk)

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
        message = transaction['data']
        #print(f'Transaction = {transaction}')
        print(message)
        self.sha.init()
        digest = self.sha.digest(message)
        self.expected_output.append({'data': digest,'user':80*'0'+little_endian_codec(self.codec)+32*'0'})
        #print(f'Expected digest = {digest}')
        #self.dut._log.debug("Message block received: {}".format(buffer[0:DATA_BYTE_WIDTH]))

def random_hash(npackets=5):
    """random string data of a random length"""
    for _ in range(npackets):
        yield get_bytes(64, random_data())
        


async def run_test(dut, codec=None, data_in=None, backpressure_inserter=None):
    dut.m_axis_tready <= 0
    #dut.log.setLevel(logging.DEBUG)

    """ Setup testbench and run a test. """
    clock = Clock(dut.axis_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    tb = DigestTB(dut, codec, True)

    await tb.reset()
    dut.m_axis_tready <= 1
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())

    # Send in the packets
    for transaction in data_in():
        tb.s_axis.bus.tuser <= BinaryValue(80*'0'+little_endian_codec(codec)+32*'0')
        await tb.s_axis.send(transaction)

    # Wait for last transmission
    await RisingEdge(dut.axis_aclk)
    while not ( dut.m_axis_tlast.value and dut.m_axis_tvalid.value ):
        await RisingEdge(dut.axis_aclk)
    
    dut._log.info("DUT testbench finished!")

    raise tb.scoreboard.result


# Register the test.
factory = TestFactory(run_test)
factory.add_option("data_in", [random_hash])
factory.add_option("codec", [0x12,0x13,0x09,0x10])
# factory.add_option("backpressure_inserter", 
#                    [None, random_50_percent])
factory.generate_tests()
