`timescale 1s / 1ms

`include "defs.sv"
`include "buffer.sv"
`include "tmon_bus.sv"
`include "tmon_master.sv"
`include "tmon_slave.sv"
`include "temp_sensor.sv"

module toptb();
    
    integer log;
    int err_count;
    int log_count;
    
    //default to 1Hz
    parameter CLOCK_CYCLE  = 2;
    parameter CLOCK_WIDTH  = CLOCK_CYCLE/2;
    parameter IDLE_CLOCKS  = 4;
    
    bit Clock, Reset, Done;

    DTYPE D;
    TMON_OP request;
    logic [7:0] reqData;

    logic [7:0] temp;
    logic tick;

    temp_sensor sensor(Clock, Reset, tick, temp);
    tmon_bus #(.DTYPE(DTYPE)) tbus();
    tmon_slave #(.DTYPE(DTYPE)) slave(tbus, Clock, Reset, tick, temp);
    tmon_master #(.DTYPE(DTYPE)) master(tbus, Clock, Reset, request, reqData, Done);
    
    //TODO: for now, always monitor
    bool_t DEBUG_MON = TRUE;
    
    initial
    begin
        log = $fopen("tmon.log");
        $display(">>>>>Begin tmon testbench");
        `ifdef DEBUG_MON
        $fdisplay(log, "\t\trequest\treqData\tdone\tClock\tReset");
        $fmonitor(log, "\t\t%b\t%b\t%b\t%b\t%b", request, reqData, Done, Clock, Reset);
        `endif
    end
    
    //free running clock
    initial
    begin
        Clock = TRUE;
        forever #CLOCK_WIDTH Clock = ~Clock;
    end
    
    //Start reset low, then pull high.
    initial
    begin
        Reset = FALSE;
        repeat (IDLE_CLOCKS) @(negedge Clock);
        Reset = TRUE;
    end
    
    //----------------------------------------------------
    // Main Tests
    //
    // ===TESTS===
    // 1. TODO: List tests here
    //----------------------------------------------------
    
    initial
    begin
        repeat (1) @(negedge Clock);
        request=NOOP;
        reqData='0;
        repeat (4) @(negedge Clock); log_err(request, reqData); $fdisplay(log, "SOME ACTION");
        
        $fclose(log);
        $display(">>>>>There were %d errors.", err_count);
        $display(">>>>>End tmon testbench");
        $stop;
    end
    
    function automatic void log_err(
        input TMON_OP request,
        logic [7:0] reqData);
        log_count++;
        if(1===1) //TODO: test something meaningful
        begin
            err_count++;
            $fdisplay(log, "ERR%d: expected this %b %b got %b %b", err_count, request, reqData, 0, 0);
        end
        else
        $fdisplay(log, "no error, log count: %d", log_count);
    endfunction
    
endmodule

