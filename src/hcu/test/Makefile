# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..

export PYTHONPATH := $(PWD)/../../../../lib:$(PYTHONPATH)

SIM ?= verilator

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
VERILOG_SOURCES = $(TOPDIR)/hdl/hcu.sv
VERILOG_SOURCES += $(TOPDIR)/hdl/hash_update.sv
VERILOG_SOURCES += $(TOPDIR)/hdl/hcu_define.v
VERILOG_SOURCES += $(TOPDIR)/hdl/madd_32_64.v
VERILOG_SOURCES += $(TOPDIR)/hdl/Majority.v
VERILOG_SOURCES += $(TOPDIR)/hdl/Sigma.v

TOPLEVEL = hcu

export TOPLEVEL_LANG
MODULE = hcu_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
