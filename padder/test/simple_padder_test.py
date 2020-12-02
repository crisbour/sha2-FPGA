import asyncio
import random
import cocotb
import logging

from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.result import ReturnValue
from cocotbext.axis import *
from axis import AXIS_Writer, AXIS_Reader

from generate_message import *

CLK_PERIOD_NS = 10

class PadderTB(object):

	def __init__(self, dut, debug=False):
		self.dut = dut
		self.s_axis = AXIS_Driver(dut, "s_axis", dut.axi_aclk)
		self.m_axis = AXIS_Monitor(dut, "m_axis", dut.axi_aclk)
		self.m_axis.m_axis_tready = 1;

		self.bits_sent = 0

		level = logging.DEBUG if debug else logging.WARNING
		self.dut.log.setLevel(debug)

	async def reset(self,duration = 2):
		self.dut._log.debug("Resetting DUT")
		self.dut.axi_resetn <= 0
		await self.s_axis.rst()
		await self.m_axis.rst()
		await Timer(duration, units='ns')
		await RisingEdge(self.dut.axi_aclk)
		self.dut.axi_resetn <= 1
		self.dut._log.debug("Out of reset")

	def sendMessage(self, max_length=300):
		mess_obj = Message(max_length)
		tdata, tkeep, _ = mess_obj.AXIS_Message()
		self.dut._log.debug('Sending TDATA: {}'.format([hex(td) for td in tdata]))
		self.dut._log.debug('Sending TKEEP: {}'.format([hex(tk) for tk in tkeep]))
		self.st_axis.write(tdata, tkeep)


@cocotb.test()
async def write_random_message(dut):
	""" Write a random message to the padder.
	
	This test doesn't analyse the output,
	but the functionality can be assesed by opening waveform.vcd
	in GTKWave.
	"""
	dut.axi_resetn <= 0
	dut.sha_type <= 0
	s_axis = AXIS_Driver(dut, "s_axis", dut.axi_aclk)
	m_axis = AXIS_Monitor(dut, "m_axis", dut.axi_aclk)
	cocotb.fork(Clock(dut.axi_aclk, CLK_PERIOD_NS, units='ns').start())
	await Timer(CLK_PERIOD_NS, units='ns')
	await RisingEdge(dut.axi_aclk)
	dut.axi_resetn <= 1

	my_message = Message()
	dut._log.info("Transmitting byte-string: {}".format(my_message.ByteStr()))
	await s_axis.send(my_message.ByteStr())
	await Timer(CLK_PERIOD_NS, units='ns') 

	