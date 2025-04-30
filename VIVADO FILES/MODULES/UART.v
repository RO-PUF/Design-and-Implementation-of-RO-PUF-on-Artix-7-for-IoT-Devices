module UART_TX (
    input clk,
    input rst,
    input [7:0] data_in,
    input start,
    output reg tx,
    output reg busy
);

parameter BAUD_DIV = 868;

reg [3:0] bit_index;
reg [9:0] shift_reg;
reg [15:0] baud_counter;
reg sending;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1'b1;
        busy <= 0;
        sending <= 0;
        baud_counter <= 0;
        bit_index <= 0;
        shift_reg <= 10'b1111111111;
    end else begin
        if (!sending && start) begin
            sending <= 1;
            busy <= 1;
            shift_reg <= {1'b1, data_in, 1'b0}; // stop, data, start
            bit_index <= 0;
            baud_counter <= 0;
        end else if (sending) begin
            if (baud_counter < BAUD_DIV) begin
                baud_counter <= baud_counter + 1;
            end else begin
                baud_counter <= 0;
                tx <= shift_reg[0];
                shift_reg <= {1'b1, shift_reg[9:1]};
                bit_index <= bit_index + 1;
                if (bit_index == 9) begin
                    sending <= 0;
                    busy <= 0;
                    tx <= 1;
                end
            end
        end
    end
end

endmodule
