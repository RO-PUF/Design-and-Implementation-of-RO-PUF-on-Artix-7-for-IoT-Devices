`timescale 1ns / 1ps

module SHIFT_REGISTER_tb;

    // Inputs
    reg clk;
    reg s_in;
    reg en;

    // Output
    wire [255:0] p_out;

    // Instantiate the Unit Under Test (UUT)
    SHIFT_REGISTER uut (
        .clk(clk),
        .s_in(s_in),
        .en(en),
        .p_out(p_out)
    );

    // Clock generation (10 ns period = 100 MHz)
    always #5 clk = ~clk;

    // Initialize and drive the inputs
    initial begin
        clk = 0;
        en = 0;
        s_in = 0;

        // Wait before enabling
        #20;

        // Enable and feed a known bit pattern serially: 8'b10101010
        en = 1;
        s_in = 1; #10;
        s_in = 0; #10;
        s_in = 1; #10;
        s_in = 0; #10;
        s_in = 1; #10;
        s_in = 0; #10;
        s_in = 1; #10;
        s_in = 0; #10;

        // Disable shifting
        en = 0;
        #20;

        $display("Final Parallel Output (MSB first): %b", p_out);
        $finish;
    end

endmodule
