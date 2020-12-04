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

from collections import deque

# Data generators
with warnings.catch_warnings():
	warnings.simplefilter('ignore')
	from cocotb.generators.byte import random_data, get_bytes
	from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

DATA_BIT_WIDTH = 512
DATA_BYTE_WIDTH = int(DATA_BIT_WIDTH/8)

class WtUnitTB(object):

	def __init__(self, dut, debug=False):
		self.dut = dut
		dut.sha_type <= 0	# Set it to SHA224/256
		self.s_axis = AXIS_Driver(dut, "s_axis", dut.axi_aclk)
		self.backpressure = BitDriver(dut.m_axis_tready, dut.axi_aclk)
		self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axi_aclk, lsb_first=False)

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

	def _rotr(self, word, rsh):
		return ((word >> rsh) | (word<<(32-rsh))) & 0xFFFFFFFF

	def model(self, transaction):
		print('Transaction={}'.format(transaction))
		message = transaction['data']
		w = deque()
		buffer = b''
		while len(message):
			for i in range(16):
				w_temp, = struct.unpack('!Q',4*b'\x00'+message[4*i:4*(i+1)])
				w.append(w_temp)
				buffer += struct.pack('!Q',w_temp)
			for i in range(16,64):
				sigma0 = self._rotr(w[1], 7) ^ self._rotr(w[1], 18) ^ (w[1] >> 3)
				sigma1 = self._rotr(w[14], 17) ^ self._rotr(w[14], 19) ^ (w[14] >> 10)
				w.append((w[0] + sigma0 + w[9] + sigma1) & 0xFFFFFFFF)
				w.popleft()
				buffer += struct.pack('!Q',w[-1])
			w = deque()
			message = message[DATA_BYTE_WIDTH:]
		self.expected_output.append({'data': buffer})

def random_message(min_blocks=1, max_blocks=4, npackets=4):
	"""random string data of a random length"""
	for _ in range(npackets):
		yield get_bytes(DATA_BYTE_WIDTH*random.randint(min_blocks, max_blocks), random_data())


async def run_test(dut, data_in=None, backpressure_inserter=None):
	dut.m_axis_tready <= 0
	dut.en <= 1
	#dut._log.setLevel(logging.DEBUG)

	""" Setup testbench and run a test. """
	clock = Clock(dut.axi_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
	cocotb.fork(clock.start())  # Start the clock
	tb = WtUnitTB(dut, True)

	await tb.reset()

	dut.m_axis_tready <= 1
	
	if backpressure_inserter is not None:
		tb.backpressure.start(backpressure_inserter())

	# Send in the packets
	for transaction in data_in():
		await tb.s_axis.send(transaction)

	# Wait for last transmission
	while not ( dut.m_axis_tlast.value and dut.m_axis_tvalid.value and dut.m_axis_tready.value):
		await RisingEdge(dut.axi_aclk)
	await RisingEdge(dut.axi_aclk)
	
	
	dut._log.info("DUT testbench finished!")

	raise tb.scoreboard.result


# Register the test.
factory = TestFactory(run_test)
factory.add_option("data_in", [random_message])
factory.add_option("backpressure_inserter", 
					[None, random_50_percent]) # Throtle tready: random_50_percent
factory.generate_tests()
