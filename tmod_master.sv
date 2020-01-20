`include "defs.sv"

module  tmod_master #(
    parameter type DTYPE = logic [7:0]
    ) (
    tmod_bus tmod,
    input TMOD_STATE request,
    input logic [7:0] reqData,
    output logic done
    );
    
    TMOD_STATE State, Next;
    TMOD_STATUS status;
    
    //probably something
    always_ff @(posedge tmod.clk)
    begin
    end //always_ff
    
    //Wait for a request, then read in the opcode.
    always_ff @(request)
    begin
        Next <= request;
    end
    
    always_ff @(posedge tmod.clk, posedge tmod.reset)
    begin
        if (tmod.reset)
        begin
            //reset values
            done = 0;
            //Assuming we come out of reset and nothing has been placed on the
            //opcode lines, we should just loop a noop until the driving module
            //pulls the opcode lines high to some meaningful state.
            Next <= NOOP;
        end
        else
        begin
            State <= Next;
            //any glue logic goes here.
        end
    end //always_ff
    
    always_ff @(State or posedge tmod.ready)
    begin
        if(tmod.ready)
        begin
            case(State)
                RESET:
                begin
                    //do reset
                end
                SET_FRQ:
                begin
                    //set frequency
                end
                NOOP:
                begin
                    //do noop
                end
            endcase
        end
        else
        begin
            //wait for ready state to change
        end
    end
endmodule
