// The `COMPARATOR` module is a purely combinational block that takes two 32-bit unsigned
// inputs (`count1` and `count2`) and produces a single-bit `response`: it drives `response`
// low (`0`) if `count1` exceeds `count2`, and high (`1`) otherwise. This simple comparator
// logic is used in the RO PUF datapath to decide each response bit based on which 
// ring-oscillator counter ticked more cycles during the sampling window.


module COMPARATOR(
    input [31:0] count1, count2,
    output reg response
    );
    
    always@(*) begin
        if (count1 > count2)
            response <= 1'b0;
        else
            response <= 1'b1;
    end
    
endmodule
