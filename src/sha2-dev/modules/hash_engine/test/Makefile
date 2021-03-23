# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..
MODULES_DIR=$(TOPDIR)/..
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
COMPILE_ARGS+=-I$(MODULES_DIR)/padder/hdl/
COMPILE_ARGS+=-I$(MODULES_DIR)/wt_unit/hdl/
COMPILE_ARGS+=-I$(MODULES_DIR)/hcu/hdl/
COMPILE_ARGS+=-I$(MODULES_DIR)/digest/hdl/
COMPILE_ARGS+=-I$(SHADIR)/headers/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hash_engine/hdl/
COMPILE_ARGS+=+incdir+$(MODULES_DIR)/padder/hdl/
COMPILE_ARGS+=+incdir+$(MODULES_DIR)/wt_unit/hdl/
COMPILE_ARGS+=+incdir+$(MODULES_DIR)/hcu/hdl/
COMPILE_ARGS+=+incdir+$(MODULES_DIR)/digest/hdl/
COMPILE_ARGS+=+incdir+$(SHADIR)/headers/
endif

# DUT
VERILOG_SOURCES = $(TOPDIR)/hdl/hash_engine.v
VERILOG_SOURCES += $(MODULES_DIR)/padder/hdl/padder.sv
VERILOG_SOURCES += $(MODULES_DIR)/wt_unit/hdl/wt_unit.v
VERILOG_SOURCES += $(MODULES_DIR)/wt_unit/hdl/bridge.v
VERILOG_SOURCES += $(MODULES_DIR)/wt_unit/hdl/wt_sigma_define.v
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/hcu.sv
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/hcu_define.v
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/hash_update.sv
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/madd_32_64.v
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/madd_Kt.v
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/Majority.v
VERILOG_SOURCES += $(MODULES_DIR)/hcu/hdl/Sigma.v
VERILOG_SOURCES += $(MODULES_DIR)/digest/hdl/digest.v
VERILOG_SOURCES += $(MODULES_DIR)/digest/hdl/big_endian.v


TOPLEVEL = hash_engine

export TOPLEVEL_LANG
MODULE = hash_engine_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim