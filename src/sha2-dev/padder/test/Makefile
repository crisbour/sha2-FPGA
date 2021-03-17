# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..
HDIR=$(TOPDIR)/../headers


export PYTHONPATH := $(TOPDIR)/../:$(PYTHONPATH)

SIM ?= verilator

ifeq ($(SIM), verilator)
EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += --trace-fst --trace-structs -CFLAGS -DVM_TRACE_FST=1
endif

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
COMPILE_ARGS+=-I$(HDIR)
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
COMPILE_ARGS+=+incdir+$(HDIR)
endif

# DUT
VERILOG_SOURCES = $(TOPDIR)/hdl/padder.sv
VERILOG_SOURCES += $(HDIR)/multiformats_codec.vh
TOPLEVEL = padder

export TOPLEVEL_LANG
MODULE = padder_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
