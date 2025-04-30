// The `CONTROL` module is a finite-state machine that sequences the entire PUF measurement
// cycle: on asserting `start` it moves from IDLE to DVALID (to load the LFSR with the master
// challenge and enable the ring oscillators), waits a fixed "warm-up" delay (RO_WAIT), then
// in INNER repeatedly enables the ring-oscillator counters and reference counter until the
// sample window closes, steps the LFSR and shifts the comparator result into the shift register
// (PRE and OUTER), increments a bit counter until all 256 bits are collected (asserting `done`),
// and finally returns to IDLE once `start` is released-using the control outputs (`lfsrDV`,
// `lfsrEN`, `roEN`, `countEN`, `refEN`, `srEN`, `countReset`) to gate each submodule at the
// right time.


module CONTROL (
    input clk,
    input start,
    input [7:0] refcount,
    output reg done,
    output reg lfsrDV,
    output reg countEN,
    output reg refEN,
    output reg lfsrEN,
    output reg srEN,
    output reg roEN,
    output reg countReset
);

    reg [2:0] state;
    reg [7:0] bitscount;
    reg [3:0] delay_counter;

    parameter IDLE   = 3'b000,
              DVALID = 3'b001,
              RO_WAIT = 3'b110,
              INNER  = 3'b010,
              PRE    = 3'b011,
              OUTER  = 3'b100,
              TEMP   = 3'b101;

    parameter DELAY_CYCLES = 4'd4;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                done <= 1'b0;
                bitscount <= 8'b0;
                delay_counter <= 4'd0;
                if (!start)
                    state <= IDLE;
                else
                    state <= DVALID;
            end

            DVALID: begin
                delay_counter <= 4'd0;
                state <= RO_WAIT;
            end

            RO_WAIT: begin
                if (delay_counter == DELAY_CYCLES)
                    state <= INNER;
                else
                    delay_counter <= delay_counter + 1;
            end

            INNER: begin
                if (refcount == 8'hFF)
                    state <= PRE;
                else 
                    state <= INNER;
            end

            PRE: state <= OUTER;

            OUTER: begin
                bitscount <= bitscount + 1;
                if (bitscount == 8'hFF) begin
                    state <= TEMP;
                    done <= 1'b1;
                end else begin 
                    state <= INNER;
                    done <= 1'b0;
                end            
            end

            TEMP: begin
                done <= 1'b0;
                if (start)
                    state <= TEMP;
                else
                    state <= IDLE;
            end

            default: begin
                state <= IDLE;
                bitscount <= 8'b0;
                done <= 1'b0;
            end
        endcase
    end

    // Combinational control logic
    always @(*) begin 
        case(state)
            IDLE: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b0;
                refEN <= 1'b0;
                lfsrEN <= 1'b0;
                srEN <= 1'b0;
                roEN <= 1'b0;
                countReset <= 1'b1;
            end

            DVALID: begin
                lfsrDV <= 1'b1;
                countEN <= 1'b0;
                refEN <= 1'b0;
                lfsrEN <= 1'b1;
                srEN <= 1'b0;
                roEN <= 1'b1;
                countReset <= 1'b1;
            end

            RO_WAIT: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b0;
                refEN <= 1'b0;
                lfsrEN <= 1'b0;
                srEN <= 1'b0;
                roEN <= 1'b1;
                countReset <= 1'b1;
            end

            INNER: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b1;
                refEN <= 1'b1;
                lfsrEN <= 1'b0;
                srEN <= 1'b0;
                roEN <= 1'b1;
                countReset <= 1'b0;
            end 

            PRE: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b1;
                refEN <= 1'b0;
                lfsrEN <= 1'b1;
                srEN <= 1'b1;
                roEN <= 1'b0;
                countReset <= 1'b0;
            end

            OUTER: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b1;
                refEN <= 1'b0;
                lfsrEN <= 1'b0;
                srEN <= 1'b0;
                roEN <= 1'b0;
                countReset <= 1'b1;
            end

            TEMP: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b0;
                refEN <= 1'b0;
                lfsrEN <= 1'b0;
                srEN <= 1'b0;
                roEN <= 1'b0;
                countReset <= 1'b1;
            end

            default: begin
                lfsrDV <= 1'b0;
                countEN <= 1'b0;
                refEN <= 1'b0;
                lfsrEN <= 1'b0;
                srEN <= 1'b0;
                roEN <= 1'b0;
                countReset <= 1'b1;
            end
        endcase
    end
endmodule
