`timescale 1ns / 1ps

`define SIMULATION  // Make sure this is defined to simulate the behavioral version

module RO_tb;

    // Inputs
    reg en;

    // Outputs
    wire out;

    // Instantiate the RO module
    RO uut (
        .en(en),
        .out(out)
    );

    // Initial block to drive simulation
    initial begin
        $display("Starting RO Simulation...");
        
        // Initialize
        en = 0;
        #20;

        // Enable the ring oscillator
        en = 1;
        #200;

        // Disable after some time
        en = 0;
        #50;

        $display("Final output value: %b", out);
        $display("RO Simulation completed.");
        $stop;
    end

endmodule
