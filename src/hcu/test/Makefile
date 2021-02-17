# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..

export PYTHONPATH := $(PWD)/../../../../lib:$(PYTHONPATH)

SIM ?= icarus

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
endif

# DUT
VERILOG_SOURCES = $(PWD)/../hdl/hcu.v
VERILOG_SOURCES += $(PWD)/../hdl/hash_update.v
VERILOG_SOURCES += $(PWD)/../hdl/hcu_define.v
VERILOG_SOURCES += $(PWD)/../hdl/madd_32_64.v
VERILOG_SOURCES += $(PWD)/../hdl/Majority.v
VERILOG_SOURCES += $(PWD)/../hdl/Sigma.v

TOPLEVEL = Sigma

export TOPLEVEL_LANG
MODULE = hcu_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
