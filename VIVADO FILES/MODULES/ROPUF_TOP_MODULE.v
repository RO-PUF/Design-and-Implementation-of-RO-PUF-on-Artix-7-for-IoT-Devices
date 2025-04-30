// Upon a start pulse, the ROPUF core seeds its internal LFSR with the 8-bit master_challenge and generates per-cycle
// challenge values that index one ring oscillator from each of two 16-RO banks via two multiplexers. Those selected RO 
// outputs drive separate counters-gated by a programmable reference counter-and a comparator produces one response bit
// per sampling period. A shift register then serially collects all 256 bits into the response bus, and a control FSM
// sequences the LFSR stepping, counter and reference enables, shift-register loading, and finally asserts done when the
// full PUF response is ready. Simulation vs. synthesis variants are handled through generate blocks and synthesis pragmas
// to model ideal delays in simulation and programmable-delay lines in hardware.


module ROPUF(
    input wire clk,
    input wire start,
    input wire [7:0] master_challenge,
    output wire [255:0] response,
    output wire done
);
  
    
    wire [31:0] oc1;
    wire [31:0] oc2;
    wire [7:0] challenge;
    wire result;
    wire roEN;
    wire [7:0] refcount;
    

// This is necessary percussion to ensure that the signal coming from the ROs will go to the multiplexer.
// and forwarded to the counter without undergoing in Vivado optimization.

    (* DONT_TOUCH = "true" *) wire [15:0] o1, o2;
    (* DONT_TOUCH = "true" *) wire mux1_out, mux2_out;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) wire om1, om2;
    assign om1 = mux1_out;
    assign om2 = mux2_out;
    

// Genvar is used to generate the two groups of Ring Oscillators which contain 16 ROs each.

genvar i;

// This is only used for simulation purposes. This is differ from the code for synthesis since in 
// there's a need to add the delays of  in simulation due to ideal behavior of the gates and the 
// physical variation of the gates is not present. 

`ifdef SIMULATION

    generate
        for (i = 0; i < 16; i = i + 1) begin: RING
            RO R1(.en(roEN), .c(challenge[7:4] + i), .o(o1[i]));
            RO R2(.en(roEN), .c(challenge[7:4] + i + 1), .o(o2[i]));
        end
    endgenerate
    
`else

// This is only used for synthesis purposes. This uses 6LUT as a logic inverter and NAND gates 
// and is implemented using the Programmable Delay Line. This method will introduce controlled 
// delay that will differ based on the challenge bit.
    
    for(i=0; i<16; i=i+1) begin: RING
         RO R1(roEN, challenge[7:0], o1[i]);
         RO R2(roEN, challenge[7:0], o2[i]);
    end

`endif
    
    
// This is for the multiplexer that will select which ring oscillator will be going to compare.
// Mux0 will be the selector for the 16 ROs in Group 1 oscillators and the Mux2 will be the 
// selector for Group 2 oscillators.

    MUX MUX1 (
        .in(o1),
        .select(challenge[7:4]),
        .out(mux1_out)
    );

    MUX MUX2 (
        .in(o2),
        .select(challenge[3:0]),
        .out(mux2_out)
    );
    
    
// Counters to count oscillation cycles for selected ROs.
    
    COUNTER COUNTER1 (
        .clk(om1), 
        .en(countEN), 
        .reset(countReset), 
        .q(oc1)
        );
        
    COUNTER COUNTER2 (
        .clk(om2), 
        .en(countEN), 
        .reset(countReset), 
        .q(oc2)
        );
        
        
// Reference counter to track sampling period.    

    COUNTER #(8) REFCOUNTER (
        .clk(clk), 
        .en(refEN), 
        .reset(countReset), 
        .q(refcount)
        );
        
        
// Comparator to generate a response bit based on the counter values.

    COMPARATOR COMPARATOR (
        .count1(oc1), 
        .count2(oc2), 
        .response(result)
        );


// Shift Register will store the bits that generated every challenge

    SHIFT_REGISTER SR(
        .clk(clk),
        .en(srEN),
        .s_in(result),
        .p_out(response)
        );

        
// LFSR for generating pseudo-random challenge values.

    LFSR #(8) LFSR (
        .clk(clk),
        .en(lfsrEN),
        .seed_DV(lfsrDV),
        .seed(master_challenge),
        .LFSR_data(challenge)
        );


// Control will be responsibble to the states of the operation to achieve the 256bit response

        CONTROL CPU(
        .clk(clk),
        .start(start),
        .refcount(refcount),
        .lfsrDV(lfsrDV), 
        .countEN(countEN), 
        .refEN(refEN), 
        .lfsrEN(lfsrEN),
        .srEN(srEN),
        .roEN(roEN),
        .countReset(countReset),
        .done(done)
        );

endmodule
