# File: Makefile
# Authors:
# Stephano Cetola

all: lib build

lib:

	@echo "Running vlib"
	vlib work

build:

	@echo "Running vlog"
	vlog buffer.sv defs.sv temp_sensor.sv tmod_bus.sv tmod_master.sv tmod_slave.sv top.sv toptb.sv

run:

	vsim -c -do tmod.do toptb

clean:
	rm -rf  work
