# Temperature Monitor V0.1

## ECE 593 - Fundamentals of Pre-Silicon Validation - Assignment 1 - Stephano Cetola

### Implementation Details

#### Overview

This temperature monitor currently conforms to Assignment 1 guidelines in that it implements the SystemVerilog code for the given diagram along with several clarifications. There is no guarantee that this code works, or for that matter, even does anything useful. A very primitive shell of a testbench is provided, however no actual tests are currently working.  

I used a master/slave method where the roles of the devices are described below. Both master and slave device are implemented as finite state machines. The temperature sensor is a "dummy" device that simply reads out random data. The motivation was that there could be (in theory) multiple temperature sensors feeding data to multiple temperature monitor slave devices, with only one master device. That master device could (with some improvements to the bus) choose a slave ID and send that slave commands.

#### tmon_bus

The temperature monitor bus allows the abstraction of the signals into slave and master modports. Since the slave and master use the same signals, but with different inputs and outputs, this seemed natural. This bus would need to include an ID and "number of slaves" variable if it were to operate with multiple slaves.

#### tmon_slave

The temperature monitor slave FSM takes inputs from the master and outputs status, valid, and ready values. The slave has 3 jobs to do:  

1. Fill the buffer on each tick cycle based off the freq variable. Since the clk and tick are synchronous, we can trigger on the posedge of the clk. On each posege clk, assuming no reset, we can determine the frequency of the sample and clock the buffer appropriately.

2. Check for high/low temperatures and set or clear the warning as appropriate.  

3. Iterate over the possible op codes and perform the correct operation. This is obviously the most important job. The op codes are pulled out into a typedef of an enum for ease of use, however I assume we will need more states than op codes here, so states are defined with an extra bit width than the op codes.  

#### tmon_master

The temperature monitor master FSM takes inputs from the testbench, feeds outputs of op code and operand to the slave, and outputs a "done" flag to the testbench when finished. The only task of the master is to take requests and deliver them to the slave in the form of op codes and operands, as well as monitoring the slave to ensure it is ready to receive data.  

#### temp_sensor

This is a dummy device that simply generates random bytes of data and outputs them. On reset it outputs 0. Since "tick" and "clock" are synchronous, it simply assigns one to the other, wiring them together.

#### buffer

The buffer needs the most testing. In theory, it should store the min, max, and average values while holding a 8x8 bit memory array. The issues here are two fold: 1. When the buffer overwrites its first byte, the "average" is wrong. Also, the way we are computing average is undoubtably wrong. It will be much easier to test this and find a better solution when the testbench is fully exercising the buffer.  

#### toptb

The shell of a testbench. Much of the work still needs to be done, however there are no errors, as there are no tests.

### Brief Verification Plan

#### Overview

See the overview of the functionality above.

#### Features to test

1. We should be able to test all the given op codes and see correct output from the devices.

2. We should be able to test a wide range of operand values since the data width is small (obviously this does not scale).

3. We should be able to fill the buffer and test that the output is still correct. (again not scaleable).

4. We should be able to pull the reset line high, see the devices reset, and resume normal operation afterwards.

#### Verification Environment

Right now we are limited in our techniques, as the class just began. We have many ways to generate and inject random data using C and SystemVerilog. We should think about ways to inject errors or configure the part in strange ways in order to attempt to produce errors.

#### Stimulus Generation, Checker, and Coverage Plans

Right now we can make use of commands like $random and tcl or C functions for generating data. We can check the data using $display or $monitor. We have learned a few tools like bins, covergroups, and coverpoints that I'm sure will be useful.