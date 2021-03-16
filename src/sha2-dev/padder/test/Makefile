# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/../..
DESIGNDIR=$(PWD)/..

export PYTHONPATH := $(TOPDIR)/:$(PYTHONPATH)

SIM ?= verilator

ifeq ($(SIM), verilator)
EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += --trace-fst --trace-structs -CFLAGS -DVM_TRACE_FST=1
endif

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(DESIGNDIR)/hdl/
COMPILE_ARGS+=-I$(TOPDIR)
else
COMPILE_ARGS+=+incdir+$(DESIGNDIR)/hdl/
COMPILE_ARGS+=+incdir+$(TOPDIR)
endif

# DUT
VERILOG_SOURCES = $(DESIGNDIR)/hdl/padder.sv
VERILOG_SOURCES += $(TOPDIR)/multiformats_codec.vh
TOPLEVEL = padder

export TOPLEVEL_LANG
MODULE = padder_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
