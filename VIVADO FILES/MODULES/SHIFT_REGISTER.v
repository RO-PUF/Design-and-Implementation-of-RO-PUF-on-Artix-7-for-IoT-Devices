// The `SHIFT_REGISTER` implements a 256-bit serial-in, parallel-out shift register: on each
// rising clock edge when `en` is high, it shifts the current 256-bit word right by one and
// concatenates the new serial input (`s_in`) into the most significant bit, exposing the full
// collected word on `p_out`. This lets the ROPUF datapath serially load each generated response
// bit into a complete 256-bit bus for further processing.


module SHIFT_REGISTER(
    input clk,
    input s_in,
    input en,
    output reg [255:0] p_out
    );
    
    reg [7:0] counter;
    
    always@(posedge clk) begin
        if (en)
            p_out <= {s_in,p_out[255:1]};
    end
        
endmodule

