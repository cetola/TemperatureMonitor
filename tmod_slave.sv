`include "buffer.sv"

module  tmod_slave #(
    parameter type DTYPE = logic [7:0]
    ) (
    tmod_bus tmod,
    input logic tick,
    input DTYPE temp
    );
    DTYPE dataOut;
    reg tick_reg;
    reg [3:0] cur_op;
    reg [7:0] cur_opnd, frq, tick_count, hi_temp, low_temp;
    wire [7:0] buff_clk, buff_addr, buff_in, buff_max, buff_min, buff_avg, buff_out;
    
    enum bit [1:0] {OK = 2'b00,
    LOW = 2'b01,
    HIGH = 2'b10} TMOD_STATUS;
    
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
    
    assign buff_clk = tick_reg;
    assign buff_in = temp;
    assign tmod.status = TMOD_STATUS;
    assign buff_add = cur_opnd;
    
    buffer buff(buff_clk, tmod.reset, buff_in, buff_addr, buff_max, buff_min, buff_addr, buff_out);
    
    //Store the values of the op code and operand
    always_ff @(posedge tmod.clk)
    begin
        cur_op <= tmod.op;
        cur_opnd <= tmod.opnd;
    end //always_ff
    
    always_ff @(posedge tmod.clk, posedge tmod.reset)
    begin
        if (tmod.reset)
        begin
            TMOD_STATUS <= OK;
            tmod.ready = 0;
            tmod.valid = 0;
            
            cur_op <= 0;
            cur_opnd <= 0;
            frq <= 0;
            tick_count <=0;
            hi_temp <=0;
            low_temp <=0;
            tmod.valid <= 0;
            tmod.ready <= 1;
            Next <= READY;
        end
        else
        begin
            State <= Next;
            //fill the buffer on each clk cycle
            if(tick_count >= frq)
            begin
                tick_count <= 0;
                tick_reg <= ~ tick_reg;
            end
            else
            begin
                tick_count <= tick_count + 1;
            end
            
            //Check for high/low temp
            if(temp > hi_temp)
            begin
                TMOD_STATUS <= HIGH;
            end
            else if(temp < low_temp)
            begin
                TMOD_STATUS <= LOW;
            end
            else
            begin
                TMOD_STATUS <= OK;
            end
        end
    end //always_ff
    
    always_ff @(State)
    begin
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
                endcase //READY CASE
            end
            CMD_RESET:
            begin
                //clear all data in buffer
                TMOD_STATUS <= OK;
                tmod.valid <= 0;
                tmod.ready <= 1;
                Next <= READY;
            end
            CMD_SET_FRQ:
            begin
                frq <= tmod.opnd;
                Next <= READY;
            end
            CMD_SET_HIGH_TEMP:
            begin
                hi_temp <= tmod.opnd;
                Next <= READY;
            end
            CMD_SET_LOW_TEMP:
            begin
                low_temp <= tmod.opnd;
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
endmodule
