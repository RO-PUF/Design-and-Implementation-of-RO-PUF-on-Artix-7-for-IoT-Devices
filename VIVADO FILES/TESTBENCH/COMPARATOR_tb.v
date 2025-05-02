`timescale 1ns / 1ps

module COMPARATOR_tb;

    reg [31:0] count1, count2;
    wire response;

    COMPARATOR uut (
        .count1(count1),
        .count2(count2),
        .response(response)
    );

    initial begin
        // Test case 1: count1 > count2
        count1 = 100;
        count2 = 50;
        #10 $display("C1: %d, C2: %d -> Response: %b (Expected: 0)", count1, count2, response);

        // Test case 2: count1 < count2
        count1 = 20;
        count2 = 80;
        #10 $display("C1: %d, C2: %d -> Response: %b (Expected: 1)", count1, count2, response);

        // Test case 3: count1 == count2
        count1 = 55;
        count2 = 52;
        #10 $display("C1: %d, C2: %d -> Response: %b (Expected: 1)", count1, count2, response);

        $display("COMPARATOR Test Completed.");
        $finish;
    end

endmodule
