# File: Makefile
# Authors:
# Stephano Cetola

all: lib build run

lib:

	@echo "Running vlib"
	vlib work

build:

	@echo "Running vlog"
	vlog +cover toptb.sv

run:

	vsim -c toptb -do "coverage save -onexit report.ucdb; run -all;exit"
	vsim -c -cvgperinstance -viewcov report.ucdb -do "coverage report -file report.txt -byfile -detail -noannotate -option -cvg;exit"

clean:
	rm -rf  work transcript tmon.log report.*
