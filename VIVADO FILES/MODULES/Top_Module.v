// This top-level Verilog module implements a button-triggered ring-oscillator PUF tester and UART reporter: 
// on each rising edge of btn_start it launches the ROPUF core with the current 8-bit challenge (also shown on 
// the eight LEDs), waits for the 256-bit response, converts each 4-bit nibble into ASCII hex (plus CR/LF), and 
// then streams the 66-byte ASCII string over the UART transmitter at the configured BAUD_DIV rate; once all 
// challenges (0x00-0xFF) have been sent, it enters a final idle state.


module TOP_MODULE (
    input clk,
    input nrst,
    input btn_start,          
    output [7:0] led,
    output tx
);

// === UART TX ===
reg [7:0] tx_data;
reg transmit;
wire busy;

UART_TX #(.BAUD_DIV(434)) uart_tx (
    .clk(clk),
    .rst(~nrst),
    .data_in(tx_data),
    .start(transmit),
    .tx(tx),
    .busy(busy)
);

// === ROPUF ===
wire [255:0] binary_data;
reg [7:0] current_challenge;
reg ropuf_start;
wire done;

ROPUF RO_PUF (
    .clk(clk),
    .start(ropuf_start),
    .master_challenge(current_challenge),
    .response(binary_data),
    .done(done)
);

// === FSM & Control ===
reg [2:0] state;
reg [6:0] index;
reg [7:0] challenge_counter;
reg start_flag;

// === Edge Detector for Button ===
reg btn_start_prev;
wire btn_start_rising = btn_start & ~btn_start_prev;

// === LED Display ===
assign led = current_challenge;

localparam IDLE       = 3'd0,
           START_PUF  = 3'd1,
           WAIT_DONE  = 3'd2,
           PREP_TX    = 3'd3,
           LOAD       = 3'd4,
           SEND       = 3'd5,
           INCR_CHAL  = 3'd6,
           DONE_STATE = 3'd7;

reg [7:0] hex_buffer [0:65];

// === HEX ENCODER FUNCTION ===
function [7:0] to_ascii_hex;
    input [3:0] nibble;
    begin
        if (nibble < 10)
            to_ascii_hex = 8'h30 + nibble;
        else
            to_ascii_hex = 8'h41 + (nibble - 10);
    end
endfunction

// === FSM ===
integer i;
always @(posedge clk or negedge nrst) begin
    if (!nrst) begin
        state <= IDLE;
        ropuf_start <= 0;
        current_challenge <= 8'b0;
        challenge_counter <= 8'b0;
        index <= 0;
        transmit <= 0;
        start_flag <= 0;
        btn_start_prev <= 0;
    end else begin
        btn_start_prev <= btn_start;
        transmit <= 0;

        // One-shot start signal
        if (btn_start_rising)
            start_flag <= 1;

        case (state)
            IDLE: begin
                ropuf_start <= 0;
                if (start_flag)
                    state <= START_PUF;
            end

            START_PUF: begin
                ropuf_start <= 1;
                current_challenge <= challenge_counter;
                state <= WAIT_DONE;
            end

            WAIT_DONE: begin
                ropuf_start <= 0;
                if (done)
                    state <= PREP_TX;
            end

            PREP_TX: begin
                for (i = 0; i < 64; i = i + 1)
                    hex_buffer[i] <= to_ascii_hex(binary_data[255 - (i * 4) -: 4]);
                hex_buffer[64] <= 8'h0D; // CR
                hex_buffer[65] <= 8'h0A; // LF
                index <= 0;
                state <= LOAD;
            end

            LOAD: begin
                if (!busy) begin
                    tx_data <= hex_buffer[index];
                    transmit <= 1;
                    state <= SEND;
                end
            end

            SEND: begin
                if (!busy) begin
                    index <= index + 1;
                    if (index == 65)
                        state <= INCR_CHAL;
                    else
                        state <= LOAD;
                end
            end

            INCR_CHAL: begin
                if (challenge_counter == 8'hFF)
                    state <= DONE_STATE;
                else begin
                    challenge_counter <= challenge_counter + 1;
                    state <= START_PUF;
                end
            end

            DONE_STATE: begin
                ropuf_start <= 0;
                transmit <= 0;
                state <= DONE_STATE;
            end
        endcase
    end
end

endmodule
