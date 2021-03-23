# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..
SHADIR=$(TOPDIR)/../..

export PYTHONPATH := $(SHADIR)/model:$(PYTHONPATH)

SIM ?= icarus

ifeq ($(SIM), verilator)
EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += -Wno-WIDTH
#EXTRA_ARGS += --trace-fst --trace-structs -CFLAGS -DVM_TRACE_FST=1
endif

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
COMPILE_ARGS+=-I$(SHADIR)/headers/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
COMPILE_ARGS+=+incdir+$(SHADIR)/headers/
endif

# DUT
VERILOG_SOURCES = $(TOPDIR)/hdl/wt_unit_tb.v
VERILOG_SOURCES += $(TOPDIR)/hdl/bridge.v
VERILOG_SOURCES += $(SHADIR)/headers/multiformats_codec.vh
VERILOG_SOURCES += $(TOPDIR)/hdl/wt_unit.v
TOPLEVEL = wt_unit_tb

export TOPLEVEL_LANG
MODULE = wt_unit_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
