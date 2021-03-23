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

def little_endian_codec(codec):
    if(codec >= 0x80):
        codec = codec<<8 | codec >>8;
    return "{0:016b}".format(codec)

class HashEngineTB(object):

    def __init__(self, dut, codec, debug=False):
        dut._log.info(f"Preparing tb for hashing-engine, codec={Sha.resolve_name(codec)}")
        self.dut = dut
        self.codec = codec    # sha_type_actual
        self.sha = Sha.get_method(codec)

        self.s_axis = AXIS_Driver(dut, "s_axis", dut.axis_aclk)
        self.backpressure = BitDriver(dut.m_axis_tready, dut.axis_aclk)
        self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axis_aclk)

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
        message = transaction['data']
        self.dut._log.debug(f'Incoming message={message}')
        self.dut._log.debug(f'Length={len(message)}')

        # sha = hashlib.sha256()
        # sha.update(message)
        # digest = sha.digest()    
        self.sha.init()
        self.sha.padder(message)
        self.sha.wt_transaction()
        digest = self.sha.digest()

        self.expected_output.append({'data': digest,'user':80*'0'+little_endian_codec(self.codec)+32*'0'})

def random_message(min_size=1, max_size=400, npackets=4):
    """random string data of a random length"""
    for i in range(npackets):
        yield get_bytes(random.randint(min_size, max_size), random_data())


async def run_test(dut, codec=0x12, data_in=None, backpressure_inserter=None):
    dut.m_axis_tready <= 0
    #dut.log.setLevel(logging.DEBUG)

    """ Setup testbench and run a test. """
    clock = Clock(dut.axis_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    tb = HashEngineTB(dut, codec, False) # Debug=False

    await tb.reset()
    dut.m_axis_tready <= 1
    
    if backpressure_inserter is not None:
        tb.backpressure.start(backpressure_inserter())



    # Send in the packets
    for transaction in data_in():
        tb.s_axis.bus.tuser <= BinaryValue(80*'0'+little_endian_codec(codec)+32*'0')
        await tb.s_axis.send(transaction)

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
factory.add_option("codec", [0x12,0x13,0x09,0x10])
factory.add_option("data_in", [random_message])
factory.add_option("backpressure_inserter", 
                    [None, random_50_percent])
factory.generate_tests()
