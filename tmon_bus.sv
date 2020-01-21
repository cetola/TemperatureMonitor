`include "defs.sv"

interface tmon_bus();
    parameter type DTYPE = logic [7:0];
    TMON_OP op;
    DTYPE opnd;
    TMON_STATUS status;
    logic valid;
    logic ready;
    
    modport Master(
    input status,
    input valid,
    input ready,
    output op,
    output opnd
    );
    
    modport Slave(
    input op,
    input opnd,
    output status,
    output valid,
    output ready
    );
    
endinterface
