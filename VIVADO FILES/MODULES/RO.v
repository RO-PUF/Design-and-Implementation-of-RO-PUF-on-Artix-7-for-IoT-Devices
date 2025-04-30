// This module is for the Ring Oscillator. This RO is composed of LUT6 that are use as Nand and Inverter
// gate. The series connection of this gates causes the oscilation and the feedback loop allows it to
// continuously oscillates.

// This module is for the Ring Oscillator. This RO is composed of LUT6 that are use as Nand and Inverter
// gate. The series connection of this gates causes the oscilation and the feedback loop allows it to
// continuously oscillates.

(* DONT_TOUCH = "true" *)  
module RO ( 
    input en, 
    input [9:0] c,   
    output o 
); 


// This code is for the Simulation Code. The use of LUT6 for simulation is no optimal since it is use for 
// functional simulation which limits Vivado 2023.2 software. To replicate the variation of the fpga chips,
// this code has controlled random delays for the oscillators.

    
`ifdef SIMULATION

    reg o;
    initial begin
        o = 0; 
    end

    always @(posedge en) begin
        if (en) begin
            forever begin
                #((c + $random % 5) * 2) o = ~o; 
            end
        end
    end

endmodule

`else


// This code is for the Synthesis Code. This contains one Nand and three inverters using 6 input LUt. The 
// physical variation of the fpga chips will introduce the delay for oscillation, making there frequency 
// different from each other. NOTE: Disable this code when doing simulation.



    wire out0, out1, out2, out3, out4, out5;
    
// LUT-based ring oscillator logic
    (* DONT_TOUCH = "true", BEL = "D6LUT" *)LUT6_L #(.INIT(64'h0000000000000001))AND (.LO(out0), .I0(en), .I1(out5), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));   
    (* DONT_TOUCH = "true", BEL = "B6LUT" *)LUT6_L #(.INIT(64'h0000000000000066))XOR1 (.LO(out1), .I0(out0), .I1(en), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
    (* DONT_TOUCH = "true", BEL = "A6LUT" *)LUT6_L #(.INIT(64'hFFFFFFFFFFFFFFFE))INV1 (.LO(out2), .I0(out1), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0)); 
    (* DONT_TOUCH = "true", BEL = "B6LUT" *)LUT6_L #(.INIT(64'h0000000000000066))XOR2 (.LO(out3), .I0(out2), .I1(en), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
    (* DONT_TOUCH = "true", BEL = "A6LUT" *)LUT6_L #(.INIT(64'hFFFFFFFFFFFFFFFE))INV2 (.LO(out5), .I0(out3), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  
    (* KEEP = "true" *) (* NOREDUCE = "true" *) wire o_internal;
    assign o_internal = out5; 

    assign o = o_internal; 

endmodule

`endif    


