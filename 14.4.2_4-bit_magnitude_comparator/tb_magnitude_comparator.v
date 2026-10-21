`timescale 1ns/1ps

module tb_magnitude_comparator();

    wire A_GT_B, A_LT_B, A_EQ_B;
    reg [3:0] A, B;

    magnitude_comparator dut(.a_gt_b(A_GT_B), .a_lt_b(A_LT_B), .a_eq_b(A_EQ_B), .a(A), .b(B));

    initial begin
        $display("time\t A    B    | A>B A<B A=B");
        $display("----------------------------------");
        $monitor("%0t\t %b %b |  %0d   %0d   %0d", $time, A, B, A_GT_B, A_LT_B, A_EQ_B);
    end

    initial begin
        A = 4'b1010; B = 4'b1001;
        #10 A = 4'b1110; B = 4'b1111;
        #10 A = 4'b0000; B = 4'b0000;
        #10 A = 4'b1000; B = 4'b1100;
        #10 A = 4'b0110; B = 4'b1110;
        #10 A = 4'b1110; B = 4'b1110;
        #10 $display("Simulation finished");
        $finish;
    end

endmodule
