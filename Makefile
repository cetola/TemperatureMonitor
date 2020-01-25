# File: Makefile
# Authors:
# Stephano Cetola

all: lib build run

lib:

	@echo "Running vlib"
	vlib work

build:

	@echo "Running vlog"
	vlog toptb.sv

run:

	vsim -c -do tmon.do toptb

clean:
	rm -rf  work transcript tmon.log
