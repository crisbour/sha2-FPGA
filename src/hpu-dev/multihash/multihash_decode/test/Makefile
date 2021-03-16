# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..

export PYTHONPATH := $(TOPDIR)/../:$(PYTHONPATH)

SIM ?=  icarus

ifeq ($(SIM), verilator)
EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += --trace-fst --trace-structs -CFLAGS -DVM_TRACE_FST=1
endif

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
endif

# DUT
VERILOG_SOURCES = $(TOPDIR)/hdl/multihash_decode.v
VERILOG_SOURCES += $(TOPDIR)/hdl/multicodec_define.v
VERILOG_SOURCES += $(TOPDIR)/hdl/fallthrough_small_fifo.v
VERILOG_SOURCES += $(TOPDIR)/hdl/small_fifo.v

TOPLEVEL = multihash_decode
MODULE = multihash_decode_cocotb

export TOPLEVEL_LANG

include $(shell cocotb-config --makefiles)/Makefile.sim
