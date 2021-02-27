# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/../..

export PYTHONPATH := $(TOPDIR)/:$(PYTHONPATH)

SIM ?= icarus

ifeq ($(SIM), verilator)
EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += --trace-fst --trace-structs -CFLAGS -DVM_TRACE_FST=1
endif

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hash_engine/hdl/
COMPILE_ARGS+=-I$(TOPDIR)/padder/hdl/
COMPILE_ARGS+=-I$(TOPDIR)/wt_unit/hdl/
COMPILE_ARGS+=-I$(TOPDIR)/hcu/hdl/
COMPILE_ARGS+=-I$(TOPDIR)/digest/hdl/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hash_engine/hdl/
COMPILE_ARGS+=+incdir+$(TOPDIR)/padder/hdl/
COMPILE_ARGS+=+incdir+$(TOPDIR)/wt_unit/hdl/
COMPILE_ARGS+=+incdir+$(TOPDIR)/hcu/hdl/
COMPILE_ARGS+=-I$(TOPDIR)/digest/hdl/
endif

# DUT
VERILOG_SOURCES = $(PWD)/../hdl/hash_engine.v
VERILOG_SOURCES += $(TOPDIR)/padder/hdl/padder.v
VERILOG_SOURCES += $(TOPDIR)/wt_unit/hdl/wt_unit.v
VERILOG_SOURCES += $(TOPDIR)/wt_unit/hdl/wt_sigma_define.v
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/hcu.sv
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/hcu_define.v
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/hash_update.sv
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/madd_32_64.v
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/madd_Kt.v
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/Majority.v
VERILOG_SOURCES += $(TOPDIR)/hcu/hdl/Sigma.v
VERILOG_SOURCES += $(TOPDIR)/digest/hdl/digest.v
VERILOG_SOURCES += $(TOPDIR)/digest/hdl/big_endian.v
TOPLEVEL = hash_engine

export TOPLEVEL_LANG
MODULE = hash_engine_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim