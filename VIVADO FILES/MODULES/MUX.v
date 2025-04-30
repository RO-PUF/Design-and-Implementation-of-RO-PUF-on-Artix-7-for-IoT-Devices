// The `MUX` module implements a 16-to-1 bit-level multiplexer: it takes a 16-bit input vector 
// (`in[15:0]`) and a 4-bit select signal (`select[3:0]`) and routes the selected bit to the 
// single-bit output (`out`). The `(* DONT_TOUCH = "true" *)` attribute prevents synthesis 
// optimizations from altering or removing this logic, preserving its exact structure and 
// timing-essential when precise routing and delays matter.

(* DONT_TOUCH = "true" *)

module MUX (
    input [15:0] in,
    input [3:0] select,
    output out
);
    assign out = in[select];  
endmodule