# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/../..

export PYTHONPATH := $(PWD)/../../../../../lib:$(PYTHONPATH)

SIM ?= icarus

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
endif

# DUT
VERILOG_SOURCES = $(TOPDIR)/hdl/Majority.v
TOPLEVEL = Majority

export TOPLEVEL_LANG
MODULE = modules_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
