SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../src/noc_router.v $(PWD)/../src/noc_mesh_4x4.v
TOPLEVEL := noc_mesh_4x4
MODULE := test_noc_mesh
ifeq ($(SIM),verilator)
EXTRA_ARGS += -Wno-fatal -Wno-WIDTH -Wno-lint -Wno-style
endif
include $(shell cocotb-config --makefiles)/Makefile.sim
