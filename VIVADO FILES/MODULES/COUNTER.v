// The COUNTER module is a parameterizable binary up-counter (default width 32 bits) with an 
// asynchronous reset: on the rising edge of the reset input it clears its output register q
// to zero; on each rising clock edge, if en is high it increments q by one, otherwise it holds
// its current value. The SIZE parameter lets you adjust the bit-width to match your counting
// range requirements.


module COUNTER #(parameter SIZE=32)(
    input clk, 
    input en, 
    input reset,
    output reg [SIZE-1:0] q
);
    
    always @ (posedge clk, posedge reset )
        if(reset)
            q <= 0;
        else begin
            if(en)
                q <= q + 1;
            else q <= q;
        end
endmodule