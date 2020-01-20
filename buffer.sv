module buffer #(
    parameter type DTYPE = logic [7:0],
    parameter addressWidth = 8
    ) (
    input logic clk,
    input logic reset,
    input DTYPE dataIn,
    input logic [addressWidth-1:0] address,
    output DTYPE buff_max,
    output DTYPE buff_min,
    output DTYPE buff_avg,
    output DTYPE buff_out
    );
    reg [7:0] data[addressWidth-1:0];
    reg [7:0] max, min, avg, curAdd;
    reg [63:0] sum;
    
    //TODO: this may always be 0 if it does the array split first, which I think will be the case,
    //so we will likely need to steps to get the proper value.
    assign avg = sum[8:0] >> curAdd;
    assign buff_avg = avg;
    assign buff_min = min;
    assign buff_max = max;
    assign buff_out = data[address];
    
    always @(posedge clk)
    begin
        if (reset)
        begin
            max <= '0;
            min <= '0;
            curAdd <= '0;
            sum <= '0;
        end
        else
        begin
            //store data
            data[curAdd] <= dataIn;
            curAdd <= curAdd + 1;
            
            //set min and max
            if(dataIn > max)
            begin
                max <= dataIn;
            end
            if(dataIn < min)
            begin
                min <= dataIn;
            end
            
            //set sum
            sum <= sum + dataIn;
        end
    end
endmodule