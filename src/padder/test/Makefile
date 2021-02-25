# Makefile
TOPLEVEL_LANG = verilog

PWD=$(shell pwd)
TOPDIR=$(PWD)/..

export PYTHONPATH := $(TOPDIR)/../:$(PYTHONPATH)

SIM ?= icarus

#not sure if only icarus include is by -I ...
ifeq ($(SIM),icarus)
COMPILE_ARGS+=-I$(TOPDIR)/hdl/
else
COMPILE_ARGS+=+incdir+$(TOPDIR)/hdl/
endif

# DUT
VERILOG_SOURCES = $(PWD)/../hdl/padder.v
TOPLEVEL = padder

export TOPLEVEL_LANG
MODULE = padder_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim