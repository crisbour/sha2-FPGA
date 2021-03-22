# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..
SHADIR=$(TOPDIR)/../..

export PYTHONPATH := $(SHADIR)/model:$(PYTHONPATH)

SIM ?= verilator

ifeq ($(SIM), verilator)
EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += --trace-fst --trace-structs -CFLAGS -DVM_TRACE_FST=1
endif


#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
COMPILE_ARGS+=-I$(SHADIR)/headers
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
COMPILE_ARGS+=+incdir+$(SHADIR)/headers
endif

# DUT
VERILOG_SOURCES = $(TOPDIR)/hdl/digest.v
VERILOG_SOURCES += $(TOPDIR)/hdl/big_endian.v

TOPLEVEL = digest
MODULE = digest_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim