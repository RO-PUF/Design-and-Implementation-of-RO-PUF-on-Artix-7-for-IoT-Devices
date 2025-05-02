`timescale 1ns / 1ps

module MUX_tb;

    reg [15:0] in;
    reg [3:0] select;
    wire out;

    MUX uut (
        .in(in),
        .select(select),
        .out(out)
    );

    initial begin
        in = 16'b1010_1100_1111_0001;

        // Test all select values from 0 to 15
        for (select = 0; select < 16; select = select + 1) begin
            #10;
            $display("Select = %0d | Output = %b", select, out);
        end

        $display("MUX Test Completed.");
        $finish;
    end

endmodule
