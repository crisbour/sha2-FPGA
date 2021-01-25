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

def Majority_model(x, y, z):
    return (x&y)^(x&z)^(y&z);

@cocotb.test()
async def Sigma0_test(dut):
    """Try accessing the design."""


    dut._log.info("Running test!")
    for _ in range(10):
        x = random.randint(0,1<<32 - 1)
        y = random.randint(0,1<<32 - 1)
        z = random.randint(0,1<<32 - 1)
        dut.x_val = x
        dut.y_val = y
        dut.z_val = z
        await Timer(1, units='ns')
        maj = dut.maj_value
        assert maj == Majority_model(x, y, z) , "Randomised test failed"
        await Timer(1, units='ns')
    dut._log.info("Running test!")