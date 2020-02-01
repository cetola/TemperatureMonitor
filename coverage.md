# Coverage Description

## ECE 593 - Fundamentals of Pre-Silicon Validation - Assignment 2 - Stephano Cetola

### Coverage Details (see toptb.sv)

#### Overview

All the following blocks of code are located in toptb.sv. They would be extracted out into classes, with each block encapsulating specific features. This enhances reuse and code readability, a fundamental part of OO programming.

#### Tester

The tester block calls "get_op" and "get_data" functions and loops 50 times. Any less than 40 loops did not achieve 100% coverage, and so 50 was chosen as a good safety margin.

#### Data Generation (get_op & get_data)

The get_op function uses a random 4 bit value to return op codes. The random number, if starting *and* ending with a 1, will return the RESET commend, while if it starts with a 1 and ends with a zero will return the NOOP command. All values where the first bit is not a 1 will return one of the other op codes. This ensure that we test RESET and NOOP much more than the other op codes.

The get_data function does something similar, with the function returning all 1's or all 0's about half the time.

#### Coverage

The one coverage group has a coverpoint of the request line, so only op codes are covered. We split these opcodes up into 2 bins: "get commands" and "set commands". We also have a coverpoint for the reqData variable, which checks three bins, "all ones", "all zeros", and "everything else".

#### Monitor / Checker / Scorecard

Since we only have 1 covergroup, we really only check to see if coverage is 100%. This value is only checked visually, where as in a proper checker, we would test to see if the get_coverage value was greater than a certain threshold (e.g. 95%). We could also check to see if the bin "all zeros" for data gets tested more than a certain percent.

#### Summary

As you can see from the coverage report (example_report.txt), we cover 100% of the op codes and data. However, some codes, for example OUT_AVG, are only tested once. Other codes like SET_LOW_TEMP are tested 6 times. Likewise, as expected, the "all ones" and "all zeros" data are tested 1/4 as much as the "other" data values. As shown in the log (example_log.txt) the test takes 151ns.