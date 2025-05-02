`timescale 1ns/1ps

module CONTROL_tb;

    // Inputs
    reg clk;
    reg start;
    reg [7:0] refcount;

    // Outputs
    wire done;
    wire lfsrDV;
    wire countEN;
    wire refEN;
    wire lfsrEN;
    wire srEN;
    wire roEN;
    wire countReset;

    // Instantiate the Unit Under Test (UUT)
    CONTROL uut (
        .clk(clk),
        .start(start),
        .refcount(refcount),
        .done(done),
        .lfsrDV(lfsrDV),
        .countEN(countEN),
        .refEN(refEN),
        .lfsrEN(lfsrEN),
        .srEN(srEN),
        .roEN(roEN),
        .countReset(countReset)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        start = 0;
        refcount = 8'd0;

        // Hold reset (start low) initially
        #20;

        // Assert start to trigger FSM
        start = 1;
        #10;

        // Deassert start (simulate pulse)
        start = 0;
        #10;

        // Simulate refcount increasing to 255 to move from INNER to PRE
        repeat (260) begin
            refcount = refcount + 1;
            #10;
        end

        // Let FSM complete until done is high
        #5000;

        $display("Simulation completed.");
        $stop;
    end

endmodule
