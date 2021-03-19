# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/../..

# export PYTHONPATH := $(PWD)/../../../../../lib:$(PYTHONPATH)

SIM ?= verilator

#ifeq ($(SIM),icarus)
#SIM_ARGS += -g2012
#endif

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
VERILOG_SOURCES = $(TOPDIR)/hdl/hash_update.sv
VERILOG_SOURCES += $(TOPDIR)/hdl/madd_32_64.v
TOPLEVEL = hash_update

export TOPLEVEL_LANG
MODULE = hash_update_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
