`timescale 1ns / 1ps

module LFSR_tb;

    // Parameters
    parameter NUM_BITS = 8;

    // Inputs
    reg clk;
    reg en;
    reg seed_DV;
    reg [NUM_BITS-1:0] seed;

    // Outputs
    wire [NUM_BITS-1:0] LFSR_data;

    // Instantiate the LFSR module
    LFSR #(.NUM_BITS(NUM_BITS)) uut (
        .clk(clk),
        .en(en),
        .seed_DV(seed_DV),
        .seed(seed),
        .LFSR_data(LFSR_data)
        // .LFSR_done is not connected since it's commented in your module
    );

    // Clock generation (100 MHz = 10ns period)
    always #5 clk = ~clk;

    // Initial block to drive simulation
    initial begin
        // Initialize signals
        clk = 0;
        en = 0;
        seed_DV = 0;
        seed = 8'b11110000;  // master challenge

        // Wait a few cycles
        #20;

        // Load seed
        en = 1;
        seed_DV = 1;
        #10;
        seed_DV = 0;

        // Generate and display 20 pseudo-random challenge values
        repeat (20) begin
            #10;
            $display("Challenge = %b", LFSR_data);
        end

        $display("Simulation completed.");
        $finish;
    end

endmodule
