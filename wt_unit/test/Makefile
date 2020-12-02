# Makefile

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../../../../lib:$(PYTHONPATH)

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/../hdl/wt_unit.v
TOPLEVEL = wt_unit
MODULE = wt_unit_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim