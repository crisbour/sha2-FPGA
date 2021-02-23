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

class DigestTB(object):

    def __init__(self, dut, sha_type, debug=False):
        self.dut = dut
        self.dut.sha_type <= sha_type
        self.sha_type = sha_type	# Set it to SHA224/256
        
        self.dut._log.info("Configure driver, monitors and scoreboard")
        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axi_aclk, lsb_first=False)
        self.backpressure = BitDriver(dut.m_axis_tready, dut.axi_aclk)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axi_aclk)

        self.expected_output = []

        # Create a scoreboard on the m_axis bus
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.m_axis, self.expected_output)

        # Reconstrut the input transactions
        self.s_axis_recovered = AXIS_Monitor(dut, "s_axis", dut.axi_aclk, callback=self.model, lsb_first=False)

        level = logging.DEBUG if debug else logging.WARNING
        self.s_axis.log.setLevel(level)
        self.s_axis_recovered.log.setLevel(level)

    async def reset(self,duration = 2):
        self.dut._log.debug("Resetting DUT")
        self.dut.axi_resetn <= 0
        await Timer(duration, units='ns')
        await RisingEdge(self.dut.axi_aclk)
        self.dut.axi_resetn <= 1
        self.dut._log.debug("Out of reset")

    def model(self, transaction):
        message = transaction['data']
        #print(f'Transaction = {transaction}')
        print(message)
        sha=Sha(self.sha_type)
        digest = sha.digest(message)
        self.expected_output.append({'data': digest})
        #print(f'Expected digest = {digest}')
        #self.dut._log.debug("Message block received: {}".format(buffer[0:DATA_BYTE_WIDTH]))

def random_hash(npackets=5):
    """random string data of a random length"""
    for _ in range(npackets):
        yield get_bytes(64, random_data())


async def run_test(dut, data_in=None, sha_type=0b01, backpressure_inserter=None):
    dut.m_axis_tready <= 0
    #dut.log.setLevel(logging.DEBUG)

    """ Setup testbench and run a test. """
    clock = Clock(dut.axi_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    tb = DigestTB(dut, True)

    await tb.reset()
    dut.m_axis_tready <= 1
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())

    # Send in the packets
    for transaction in data_in():
        await tb.s_axis.send(transaction)

    # Wait for last transmission
    await RisingEdge(dut.axi_aclk)
    while not ( dut.m_axis_tlast.value and dut.m_axis_tvalid.value ):
        await RisingEdge(dut.axi_aclk)
    
    dut._log.info("DUT testbench finished!")

    raise tb.scoreboard.result


# Register the test.
factory = TestFactory(run_test)
factory.add_option("data_in", [random_hash])
factory.add_option("sha_type", [0,1,2,3])
# factory.add_option("backpressure_inserter", 
#                    [None, random_50_percent])
factory.generate_tests()
