`include "defs.sv"

module  tmod_master #(
    parameter type DTYPE = logic [7:0]
    ) (
    tmod_bus tmod,
    input TMOD_OP request,
    input logic [7:0] reqData,
    output logic done
    );
    
    logic working;
    TMOD_OP State, Next;
    TMOD_STATUS status;
    
    //probably something here every time
    always_ff @(posedge tmod.clk)
    begin
    end //always_ff
    
    //Wait for a request, then read in the opcode.
    always_ff @(request)
    begin
        Next <= request;
        working <= TRUE;
    end
    
    always_ff @(posedge tmod.clk, posedge tmod.reset)
    begin
        if (tmod.reset)
        begin
            //reset values
            done <= FALSE;
            working <= FALSE;
            /* Assuming we come out of reset and nothing has been placed on the
            opcode lines, we should just loop a noop until the driving module
            pulls the opcode lines high to some meaningful state. */
            Next <= NOOP;
        end
        else
        begin
            /* If reset has gone low and no request (opcode) has changed, we end
            up here. Let's assume the Next state is probably NOOP, though
            we should check that in the TB.*/
            State <= Next;
            if(tmod.valid && tmod.ready && !working)
            begin
                done <= TRUE;
                //Not sure what the next state should be
                //so wait for the request line to decide.
                Next <= NOOP;
            end
        end
    end //always_ff
    
    //We might have changed states before the monitor is ready, so we watch for
    //both a state change or the tmod.ready line going high.
    always_ff @(State or posedge tmod.ready)
    begin
        if(tmod.ready)
        begin
            case(State)
                RESET:
                begin
                    //do reset
                end
                NOOP:
                begin
                    //Here we do nothing and wait for the state to change again.
                    tmod.op <= NOOP;
                end
                SET_FRQ:
                begin
                    //we assume that all ops take 1 clock cycle
                    //this is probably a horrible assumtion
                    working <= FALSE;
                    tmod.op <= SET_FRQ;
                    tmod.opnd <= reqData;
                end
                SET_HIGH_TEMP:
                begin
                    working <= FALSE;
                    tmod.op <= SET_HIGH_TEMP;
                    tmod.opnd <= reqData;
                end
            endcase
        end
        else
        begin
            //wait for ready state to change
        end
    end
endmodule
