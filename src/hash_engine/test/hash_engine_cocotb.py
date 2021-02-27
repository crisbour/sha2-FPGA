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


from sha_model import Sha
import hashlib

# Data generators
with warnings.catch_warnings():
    warnings.simplefilter('ignore')
    from cocotb.generators.byte import random_data, get_bytes
    from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

DATA_BIT_WIDTH = 512
DATA_BYTE_WIDTH = 64
PAD_BYTES = 9

class HashEngineTB(object):

    def __init__(self, dut, sha_type, debug=False):
        dut._log.info("Preparing tb for padder, sha_type={sha_type}")
        self.dut = dut
        self.sha_type = sha_type    # sha_type_actual
        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axi_aclk)
        self.backpressure = BitDriver(dut.m_axis_tready, dut.axi_aclk)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axi_aclk)

        self.expected_output = []

        # Create a scoreboard on the m_axis bus
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.m_axis, self.expected_output)

        # Reconstrut the input transactions
        self.s_axis_recovered = AXIS_Monitor(dut, "s_axis", dut.axi_aclk, callback=self.model)

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
        self.dut._log.debug(f'Incoming message={message}')
        self.dut._log.debug(f'Length={len(message)}')

        sha = hashlib.sha256()
        sha.update(message)
        digest = sha.digest()    

        self.expected_output.append({'data': digest,'user':94*'0'+"{0:02b}".format(self.sha_type)+32*'0'})

def random_message(min_size=1, max_size=400, npackets=4):
    """random string data of a random length"""
    for i in range(npackets):
        yield get_bytes(random.randint(min_size, max_size), random_data())


async def run_test(dut, data_in=None, sha_type=None, backpressure_inserter=None):
    dut.m_axis_tready <= 0
    dut.log.setLevel(logging.DEBUG)

    """ Setup testbench and run a test. """
    clock = Clock(dut.axi_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    tb = HashEngineTB(dut, sha_type, False) # Debug=False

    await tb.reset()
    dut.m_axis_tready <= 1
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())



    # Send in the packets
    for transaction in data_in():
        tb.s_axis.bus.tuser <= BinaryValue(94*'0'+"{0:02b}".format(sha_type)+32*'0')
        await tb.s_axis.send(transaction)

    # Wait for last transmission
    await RisingEdge(dut.axi_aclk)
    while not ( dut.m_axis_tlast.value and dut.m_axis_tvalid.value and dut.m_axis_tready.value ):
        await RisingEdge(dut.axi_aclk)

    for _ in range(3):
        await RisingEdge(dut.axi_aclk)
    
    dut._log.info("DUT testbench finished!")

    raise tb.scoreboard.result


# Register the test.
factory = TestFactory(run_test)
factory.add_option("sha_type", [0,1,2,3])
factory.add_option("data_in", [random_message])
factory.add_option("backpressure_inserter", 
                    [None, random_50_percent])
factory.generate_tests()
