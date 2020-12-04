# Makefile

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../../../../lib:$(PYTHONPATH)

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/../hdl/padder.v
TOPLEVEL = padder
MODULE = padder_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim