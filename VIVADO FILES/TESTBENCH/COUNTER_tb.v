`timescale 1ns / 1ps

module COUNTER_tb;

    reg clk;
    reg en;
    reg reset;
    wire [31:0] q;

    // Instantiate 32-bit counter
    COUNTER #(.SIZE(32)) uut (
        .clk(clk),
        .en(en),
        .reset(reset),
        .q(q)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        en = 0;

        #10 reset = 0;
        en = 1;

        // Let it count for 10 cycles
        repeat (10) #10;

        // Disable counter
        en = 0;
        #20;

        $display("Final counter value = %d", q);
        $display("COUNTER Test Completed.");
        $finish;
    end

endmodule
