/*
Module: toptb.sv
Authors:
Stephano Cetola <cetola@pdx.edu>
SPDX-License-Identifier: MIT
*/

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
    parameter IDLE_CLOCKS  = 10;
    
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
    
    initial
    begin
        log = $fopen("tmon.log");
        $display(">>>>>Begin tmon testbench");
        $fdisplay(log, "\t\trequest\treqData\tdone\tClock\tReset");
        $fmonitor(log, "\t\t%b\t%b\t%b\t%b\t%b", request, reqData, Done, Clock, Reset);
    end
    
    //free running clock
    initial
    begin
        Clock = TRUE;
        forever #CLOCK_WIDTH Clock = ~Clock;
    end
    
    //RESET starts high
    initial
    begin
        Reset = TRUE;
        repeat (IDLE_CLOCKS) @(negedge Clock);
        Reset = FALSE;
    end
    
    //----------------------------------------------------
    // Tester  TODO: make a class
    //----------------------------------------------------
    
    initial begin : tester
        repeat (IDLE_CLOCKS) @(negedge Clock);
        
        repeat (50) begin
            @(negedge Clock);
            request = get_op();
            reqData = get_data();
            case(request)
                NOOP: begin
                    @(posedge Clock);
                end
                RESET: begin
                    Reset = TRUE;
                    @(negedge Clock);
                    Reset = FALSE;
                end
                default: begin
                    wait(Done);
                end
            endcase
        end
        
        $fclose(log);
        $display(">>>>>There were %d errors.", err_count);
        $display(">>>>>End tmon testbench");
        report_cov();
        $stop;
    end : tester
    //----------------------------------------------------
    // Coverage TODO: make into a class
    //----------------------------------------------------

    covergroup op_cov;
        all_ops: coverpoint request {
            bins set_cmds[] = {SET_FRQ, SET_HIGH_TEMP, SET_LOW_TEMP};
            bins get_cmds[] = {OUT_MIN, OUT_MAX, OUT_ADDR, OUT_AVG};
        }
    endgroup
    
    op_cov oc;

    initial begin : coverage
        oc = new();
        forever begin @(negedge Clock);
            oc.sample();
        end
    end : coverage
    
    function automatic void log_err(
        input TMON_OP request,
        input logic[7:0] reqData);
        log_count++;
        if(1===0) //TODO: test something meaningful
        begin
            err_count++;
            $fdisplay(log, "ERR%d: expected this %b %b got %b %b", err_count, request, reqData, 0, 0);
        end
        else
        $fdisplay(log, "no error, log count: %d", log_count);
    endfunction

    //----------------------------------------------------
    // Monitor / Checker / Scoreboard  TODO: make into a classes
    //----------------------------------------------------
    function automatic void report_cov();
        $display("coverage: %f", oc.get_coverage());
    endfunction
    
    //----------------------------------------------------
    // Data generation  TODO: make into a classes
    //----------------------------------------------------
    function TMON_OP get_op();
        bit [3:0] op_choice;
        op_choice = $random;
        casez(op_choice)
            4'b1??1 : return RESET;
            4'b0001 : return SET_FRQ;
            4'b0010 : return SET_HIGH_TEMP;
            4'b0011 : return SET_LOW_TEMP;
            4'b0100 : return OUT_MAX;
            4'b0101 : return OUT_MIN;
            4'b0110 : return OUT_ADDR;
            4'b0111 : return OUT_AVG;
            4'b1??0 : return NOOP;
        endcase
    endfunction

    function byte get_data();
        bit [1:0] zero_ones;
        zero_ones = $random;
        if(zero_ones === 2'b00)
            return 8'h00;
        else if (zero_ones === 2'b11)
            return 8'hff;
        else
            return $random;
    endfunction
    
endmodule

