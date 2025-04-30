`timescale 1ns / 1ps

// This module implements a parameterized Linear Feedback Shift Register (LFSR)
// used for generating pseudo-random challenge values in the RO PUF design.
// The LFSR can be seeded externally and produces a repeatable, deterministic
// sequence of values used to drive multiplexer select lines for oscillator comparison.
// It supports various bit lengths based on the NUM_BITS parameter.

// When 'en' is high, the LFSR either loads a seed (if 'seed_DV' is high) or shifts and updates itself.
// The output 'LFSR_data' provides the current pseudo-random value,
// and 'LFSR_done' indicates when the LFSR state matches the seed (sequence completion).

module LFSR #(parameter NUM_BITS = 8)
(
    input clk,                                          // System clock
    input en,                                           // Enable signal for LFSR operation

                                                        // Optional seed input for initializing the LFSR sequence
    input seed_DV,                                      // Seed data valid pulse
    input [NUM_BITS-1:0] seed,                          // Seed value to start or restart the sequence

    output [NUM_BITS-1:0] LFSR_data                    // Current output of the LFSR
//    output LFSR_done                                    // Flag set when current state matches the seed
);

// Internal LFSR register: indexed from 1 to NUM_BITS for clarity with feedback taps
  
  reg [NUM_BITS:1] r_LFSR = 0;
  reg r_XNOR;                                            // Feedback bit calculated from tap positions


// LFSR shift logic with optional seeding
  
  always @(posedge clk)
  begin
    if (en == 1'b1) begin
      if (seed_DV == 1'b1)
        r_LFSR <= seed;                                  // Load seed value when seed_DV is asserted
      else
        r_LFSR <= {r_LFSR[NUM_BITS-1:1], r_XNOR};        // Shift and insert feedback
    end
  end


// Feedback logic based on polynomial taps for different LFSR lengths
  
  always @(*)
  begin
    case (NUM_BITS)
      3:  r_XNOR = r_LFSR[3]  ^~ r_LFSR[2];
      4:  r_XNOR = r_LFSR[4]  ^~ r_LFSR[3];
      5:  r_XNOR = r_LFSR[5]  ^~ r_LFSR[3];
      6:  r_XNOR = r_LFSR[6]  ^~ r_LFSR[5];
      7:  r_XNOR = r_LFSR[7]  ^~ r_LFSR[6];
      8:  r_XNOR = r_LFSR[8]  ^~ r_LFSR[6] ^~ r_LFSR[5] ^~ r_LFSR[4];
      9:  r_XNOR = r_LFSR[9]  ^~ r_LFSR[5];
      10: r_XNOR = r_LFSR[10] ^~ r_LFSR[7];
      11: r_XNOR = r_LFSR[11] ^~ r_LFSR[9];
      12: r_XNOR = r_LFSR[12] ^~ r_LFSR[6] ^~ r_LFSR[4] ^~ r_LFSR[1];
      13: r_XNOR = r_LFSR[13] ^~ r_LFSR[4] ^~ r_LFSR[3] ^~ r_LFSR[1];
      14: r_XNOR = r_LFSR[14] ^~ r_LFSR[5] ^~ r_LFSR[3] ^~ r_LFSR[1];
      15: r_XNOR = r_LFSR[15] ^~ r_LFSR[14];
      16: r_XNOR = r_LFSR[16] ^~ r_LFSR[15] ^~ r_LFSR[13] ^~ r_LFSR[4];
      17: r_XNOR = r_LFSR[17] ^~ r_LFSR[14];
      18: r_XNOR = r_LFSR[18] ^~ r_LFSR[11];
      19: r_XNOR = r_LFSR[19] ^~ r_LFSR[6] ^~ r_LFSR[2] ^~ r_LFSR[1];
      20: r_XNOR = r_LFSR[20] ^~ r_LFSR[17];
      21: r_XNOR = r_LFSR[21] ^~ r_LFSR[19];
      22: r_XNOR = r_LFSR[22] ^~ r_LFSR[21];
      23: r_XNOR = r_LFSR[23] ^~ r_LFSR[18];
      24: r_XNOR = r_LFSR[24] ^~ r_LFSR[23] ^~ r_LFSR[22] ^~ r_LFSR[17];
      25: r_XNOR = r_LFSR[25] ^~ r_LFSR[22];
      26: r_XNOR = r_LFSR[26] ^~ r_LFSR[6] ^~ r_LFSR[2] ^~ r_LFSR[1];
      27: r_XNOR = r_LFSR[27] ^~ r_LFSR[5] ^~ r_LFSR[2] ^~ r_LFSR[1];
      28: r_XNOR = r_LFSR[28] ^~ r_LFSR[25];
      29: r_XNOR = r_LFSR[29] ^~ r_LFSR[27];
      30: r_XNOR = r_LFSR[30] ^~ r_LFSR[6] ^~ r_LFSR[4] ^~ r_LFSR[1];
      31: r_XNOR = r_LFSR[31] ^~ r_LFSR[28];
      32: r_XNOR = r_LFSR[32] ^~ r_LFSR[22] ^~ r_LFSR[2] ^~ r_LFSR[1];
    endcase
  end

// Output the current LFSR value (excluding MSB index zero)

  assign LFSR_data = r_LFSR[NUM_BITS:1];


// LFSR_done goes high when the register cycles back to the initial seed value

  assign LFSR_done = (r_LFSR[NUM_BITS:1] == seed) ? 1'b1 : 1'b0;

endmodule

