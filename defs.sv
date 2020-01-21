`ifndef DEFS_IMPORT
`define DEFS_IMPORT

package defs;
    
    typedef	enum {FALSE, TRUE} bool_t;
    typedef logic [7:0] DTYPE;
    
    /* 

    Command codes:
    000 - reset
    001 - set sample frq
    010 - set high temp warn
    011 - set low tmp warn
    100 - output max since reset
    101 - output min since reset
    110 - output sampled value
    111 - output average
    1xxx - noop
    
    */
    typedef enum bit [3:0] {RESET = 4'b0000,
    SET_FRQ = 4'b0001,
    SET_HIGH_TEMP = 4'b0010,
    SET_LOW_TEMP = 4'b0011,
    OUT_MAX = 4'b0100,
    OUT_MIN = 4'b0101,
    OUT_ADDR = 4'b0110,
    OUT_AVG = 4'b0111,
    NOOP = 4'b1000} TMON_OP;
    
    typedef enum bit [1:0] {OK = 2'b00,
    LOW = 2'b01,
    HIGH = 2'b10} TMON_STATUS;
    
endpackage

import defs::*;

`endif
