# Makefile

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../../../../lib:$(PYTHONPATH)

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/../hdl/digest.v
TOPLEVEL = digest
MODULE = digest_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim