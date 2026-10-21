`timescale 1ns/1ps

module magnitude_comparator(

    output a_gt_b, a_lt_b, a_eq_b,
    input [3:0] a, b
);

    assign a_gt_b = (a > b);
    assign a_lt_b = (a < b);
    assign a_eq_b = (a == b);

endmodule