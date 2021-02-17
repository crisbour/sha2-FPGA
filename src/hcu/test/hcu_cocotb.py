import cocotb
import struct
import warnings
import logging
from random import getrandbits

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

from hash_update.hash_init import h_init, sha_iterations

N_WORDS = 8
WIDTH_WORDS = 64

class HcuTb(object):
	def __init__(self, dut, sha_type, debug=False):
		self.dut = dut
		self.dut.sha_type <= sha_type
		self.dut._log.info("Configure driver, monitors and scoreboard")
		self.s_axis = AXIS_Driver(dut, "s_axis", dut.axi_aclk)
		self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axi_aclk, lsb_first=False)

		self.H = h_init[sha_type]
		self.word_count = 0

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
		print(f'Transaction = {transaction}')
		message = transaction['data']
		self.word_count = self.word_count + 1
		if self.word_count == sha_iterations(self.sha_type):
			self.expected_output.append({'data':buffer})




def create_hash_regs(func, nregs):
	return [func(WIDTH_WORDS) for n in range(nregs)]

def create_hash(func):
	return create_hash_regs(func, N_WORDS)

def random_hash_stream(niters=100, func=getrandbits):
	''' Generate random data for registers from HCU '''
	for _ in range(niters):
		yield create_hash(func)

def random_message(min_blocks=1, max_blocks=4, npackets=4):
	"""random string data of a random length"""
	for _ in range(npackets):
		yield get_bytes(DATA_BYTE_WIDTH*random.randint(min_blocks, max_blocks), random_data())

def random_wt_message(sha_type=0b01):
	if (sha_type>>1):
		wt_shift = 0
	else:
		wt_shift = 4
	for _ in range(npackets):
		yield get_bytes()

async def run_test(dut, sha_type=None, backpressure_inserter=None):
	dut.m_axis_tready <= 0
	dut.en <= 1
	#dut._log.setLevel(logging.DEBUG)
	""" Setup testbench and run a test. """
	clock = Clock(dut.axi_aclk, 10, units="ns")  # Create a 10ns period clock on port clk
	cocotb.fork(clock.start())  # Start the clock
	tb = HcuTb(dut, True)

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

factory = TestFactory(run_test)
factory.add_option('sha_type', [0,1,2,3])
#factory.add_option('H_in', [random_hash_stream])
factory.generate_tests()