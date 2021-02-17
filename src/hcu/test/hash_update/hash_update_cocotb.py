import cocotb
import struct
from random import getrandbits

from cocotb.triggers import Timer

from cocotb.regression import TestFactory

from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.monitors import BusMonitor
from cocotb.triggers import RisingEdge, ReadOnly

# Data generators
from cocotb.generators.byte import random_data, get_bytes
from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

from hash_init import h_init, sha_iterations

N_WORDS = 8
WIDTH_WORDS = 64

class RegisterMonitor(BusMonitor):
    ''' Base class for monitoring inputs/outputs of hash_update. '''
    def __init__(self, dut, callback=None, event=None):
        self.dut = dut
        super().__init__(dut, "", dut.clk, callback=callback, event=event)

class RegisterInMonitor(RegisterMonitor):
    ''' Monitor inputs of hash_update module. '''
    _signals = {'H_in': 'AH', 'H_out': 'H', 'update': 'update', 'sha': 'sha_type', 'reset': 'reset'}

    def sum(self, a, b, mode64):
        if mode64:
            return (a + b) & 0xFFFFFFFFFFFFFFFF
        else:
            return ((a & 0xFFFFFFFF) + (b & 0xFFFFFFFF)) & 0xFFFFFFFF

    def hash_init(self, sha_type):
        sha_type = sha_type.integer
        # shift = int(WIDTH_WORDS/2) if (~sha_type & 0x2) else 0
        shift = 0
        H_out_next = [BinaryValue(h_init[sha_type][i] << (shift)) for i in range(N_WORDS)]
        H_out_next.reverse()
        return H_out_next

    async def _monitor_recv(self):
        #Wait for reset
        while True:
            await RisingEdge(self.clock)
            await ReadOnly()
            if self.bus.reset.value:
                break
        self.dut._log.info(f'Sha Type in Monitor = {self.bus.sha.value}')
        H_out_next = self.hash_init(self.bus.sha.value)
        # self.dut._log.info(f'Initialized H_out_next = {hex(H_out_next[0])}')
        while True:
            await RisingEdge(self.clock)
            await ReadOnly()

            H_out = H_out_next
            H_out_next = self.bus.H_out.value

            if self.bus.update.value:
                sha = self.bus.sha.value
                update = self.bus.update.value
                H_in = self.bus.H_in.value

                H_out_next = [
                    BinaryValue(
                        self.sum(H_in[i], H_out_next[i], sha&0x2)
                    ) for i in range(N_WORDS)
                ]

            if self.bus.reset.value:
                H_out_next = self.hash_init(self.bus.sha.value)
            else:
                self._recv(H_out)

class RegisterOutMonitor(RegisterMonitor):
    _signals = {'H_in': 'AH', 'H_out': 'H', 'update': 'update', 'sha': 'sha_type', 'reset': 'reset'}
    async def _monitor_recv(self):
        # Wait for reset
        while True:
            await RisingEdge(self.clock)
            await ReadOnly()
            if self.bus.reset.value:
                break
        while True:
            await RisingEdge(self.clock)
            await ReadOnly()

            if not self.bus.reset.value:
                self._recv(self.bus.H_out.value)


def create_hash_regs(func, nregs):
    return [func(WIDTH_WORDS) for n in range(nregs)]

def create_hash(func):
    return create_hash_regs(func, N_WORDS)

def random_hash_stream(niters=100, func=getrandbits):
    ''' Generate random data for registers from HCU '''
    for _ in range(niters):
        yield create_hash(func)

async def test_hash_update(dut, H_in, sha_type=1):
    ''' Test hash_update module '''

    cocotb.fork(Clock(dut.clk, 10, units='ns').start())
    
    # Configure checker to compare module results to expectd
    expected_output =[]

    dut._log.info("Configure monitors")

    in_monitor = RegisterInMonitor(dut, callback=expected_output.append)

    def check_output(transaction):
        if not expected_output:
            raise RuntimeError("Monitor capture unexpected update operation")
        exp = expected_output.pop(0)
        assert transaction == exp, f'Hash output {transaction} did not match expected result {exp}'

    out_monitor = RegisterOutMonitor(dut, callback = check_output)

    dut._log.info("Initialize and reset model")

    # Initial value
    dut.update <= 0
    dut.AH <= create_hash(lambda x: 0)
    dut.sha_type <= sha_type
    
    # Reset DUT
    dut.reset <= 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.reset <= 0

    dut._log.info(f'Sha Type in main = {dut.sha_type.value}')
    
    dut._log.info("Test update hash module")

    # Feed registers
    for i, h in enumerate(H_in()):
        dut.AH <= h
        if i == sha_iterations(sha_type) - 1:
            dut.update <= 1
        else:
            dut.update <= 0
        
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)


factory = TestFactory(test_hash_update)
factory.add_option('sha_type', [0,1,2,3])
factory.add_option('H_in', [random_hash_stream])
factory.generate_tests()