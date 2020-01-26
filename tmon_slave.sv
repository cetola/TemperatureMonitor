/*
Module: tmon_slave.sv
Authors:
Stephano Cetola <cetola@pdx.edu>
SPDX-License-Identifier: MIT
*/

module  tmon_slave #(
    parameter type DTYPE = logic [7:0]
    ) (
    tmon_bus tmon,
    input logic clk,
    input logic reset,
    input logic tick, //synchronous with clk, really needed?
    input DTYPE temp
    );
    DTYPE dataOut;
    reg tick_reg;
    TMON_OP cur_op;
    reg [7:0] cur_opnd, frq, tick_count, hi_temp, low_temp;
    wire [7:0] buff_addr, buff_in, buff_max, buff_min, buff_avg, buff_out;
    
    //I think this state machine will need more states than possible TMON_OP values,
    //so we will test this theory in the testbench. If not we can remove this.
    enum bit [4:0] {WAIT = 5'b00000,
    CMD_RESET = 5'b10000,
    CMD_SET_FRQ = 5'b10001,
    CMD_SET_HIGH_TEMP = 5'b10010,
    CMD_SET_LOW_TEMP = 5'b10011,
    CMD_OUT_MAX = 5'b10100,
    CMD_OUT_MIN = 5'b10101,
    CMD_OUT_ADDR = 5'b10110,
    CMD_OUT_AVG = 5'b10111,
    CMD_NOOP = 5'b11000,
    READY = 5'b11111} State, Next;
    
    buffer buff(tick_reg, reset, temp, cur_opnd, buff_max, buff_min, buff_addr, buff_out);
    
    //Store the values of the op code and operand
    always_ff @(posedge clk)
    begin
        cur_op <= tmon.op;
        cur_opnd <= tmon.opnd;
    end
    
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset)
        begin
            tmon.status <= OK;
            tmon.ready <= TRUE;
            tmon.valid <= FALSE;
            
            cur_op <= NOOP;
            cur_opnd <= 0;
            frq <= 0;
            tick_count <=0;
            tick_reg <=0;
            //These defaults are so that we (hopefully) won't get warnings.
            hi_temp <= 8'hFF;
            low_temp <=0;

            Next <= READY;
        end
        else
        begin
            State <= Next;
            /*
            JOB 1
            Fill the buffer on each tick cycle based off the freq variable.
            (clk and tick are synchronous, so trigger on posedge clk)
            */
            if(tick_count >= frq)
            begin
                tick_count <= 0;
                tick_reg <= ~ tick_reg;
            end
            else
            begin
                tick_count <= tick_count + 1;
            end
            
            //JOB 2
            //Check for high/low temp and set or clear the warning
            if(temp > hi_temp)
            begin
                tmon.status <= HIGH;
            end
            else if(temp < low_temp)
            begin
                tmon.status <= LOW;
            end
            else
            begin
                tmon.status <= OK;
            end
        end
    end //always_ff
    
    //JOB 3
    //Iterate over the possible op codes and perform the correct operation.
    always_ff @(State)
    begin
        checkStat("state change");
        case(State)
            READY:
            begin
                case(cur_op)
                    4'b0000: Next <= CMD_RESET;
                    4'b0001: Next <= CMD_SET_FRQ;
                    4'b0010: Next <= CMD_SET_HIGH_TEMP;
                    4'b0011: Next <= CMD_SET_LOW_TEMP;
                    4'b0100: Next <= CMD_OUT_MAX;
                    4'b0101: Next <= CMD_OUT_MIN;
                    4'b0110: Next <= CMD_OUT_ADDR;
                    4'b0111: Next <= CMD_OUT_AVG;
                    4'b1xxx: Next <= CMD_NOOP;
                endcase
            end
            CMD_RESET:
            begin
                tmon.status <= OK;
                tmon.valid <= 0;
                tmon.ready <= 1;
                Next <= READY;
            end
            CMD_SET_FRQ:
            begin
                frq <= tmon.opnd;
                Next <= READY;
            end
            CMD_SET_HIGH_TEMP:
            begin
                hi_temp <= tmon.opnd;
                Next <= READY;
            end
            CMD_SET_LOW_TEMP:
            begin
                low_temp <= tmon.opnd;
                Next <= READY;
            end
            CMD_OUT_MAX:
            begin
                dataOut <= buff_max;
                Next <= READY;
            end
            CMD_OUT_MIN:
            begin
                dataOut <= buff_min;
                Next <= READY;
            end
            CMD_OUT_ADDR:
            begin
                //TODO: set the buffer's address and wait 1 clock cycle?
                dataOut <= buff_out;
                Next <= READY;
            end
            CMD_OUT_AVG:
            begin
                dataOut <= buff_avg;
                Next <= READY;
            end
            CMD_NOOP:
            begin
                dataOut <= '0;
                Next <= READY;
            end
        endcase //STATE CASE
    end
    function automatic void checkStat(input string msg);
        $display($time,"ns:slave:%s\t|cur_op:%s\tcur_opnd:%b\tState:%s\tNext:%s",msg,cur_op.name,cur_opnd, State.name,Next.name);
    endfunction
endmodule
