import cocotb
import struct
import random

from cocotb.triggers import Timer

from cocotb.regression import TestFactory
from cocotb.scoreboard import Scoreboard
from cocotb.result import TestFailure

# Data generators
from cocotb.generators.byte import random_data, get_bytes
from cocotb.generators.bit import wave, intermittent_single_cycles, random_50_percent

def random_word(size=4):
    yield get_bytes(size, random_data())

def Sigma_model(input_val, data_width_bits):
    def RotR(r):
        return (input_val>>r) | (input_val<<(data_width_bits - r))
    return RotR(2)^RotR(13)^RotR(22)

@cocotb.test()
async def Sigma0_test(dut):
    """Try accessing the design."""


    dut._log.info("Running test!")
    dut.data_width_flag = 0
    for _ in range(10):
        x = random.randint(0,1<<32 - 1)
        dut.data_value = x
        await Timer(1, units='ns')
        y = dut.sigma_value
        assert y == Sigma_model(x, 32) , "Randomised test failed"
        print(y)
        await Timer(1, units='ns')
    dut._log.info("Running test!")