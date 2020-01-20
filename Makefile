# File: Makefile
# Authors:
# Stephano Cetola

all: lib build

lib:

	@echo "Running vlib"
	vlib work

build:

	@echo "Running vlog"
	vlog toptb.sv

run:

	vsim -c -do tmod.do toptb

clean:
	rm -rf  work
