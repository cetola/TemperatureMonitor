/*
Module: temp_sensor.sv
Authors:
Stephano Cetola <cetola@pdx.edu>
SPDX-License-Identifier: MIT
*/

`include "defs.sv"
module temp_sensor(input logic clk, input logic reset, output logic tick, output logic[7:0] temp);
    
    //seems silly, but they are synchronous.
    assign tick = clk;

    always @(posedge clk)
    begin
        if (reset)
        begin
            temp <= '0;
        end
        else
        begin
            temp <= $urandom_range(0,255);
        end
    end
endmodule