`include "defs.sv"

interface tmod_bus();
    parameter type DTYPE = logic [7:0];
    logic clk;
    logic reset;
    TMOD_OP op;
    logic [7:0] opnd;
    logic [1:0] status;
    logic valid;
    logic ready;
    
    modport Master(
    input status,
    input valid,
    input ready,
    input clk,
    input reset,
    output op,
    output opnd
    );
    
    modport Slave(
    input clk,
    input op,
    input opnd,
    input reset,
    output status,
    output valid,
    output ready
    );
    
endinterface
