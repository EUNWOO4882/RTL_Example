`timescale 1ns/1ps

module delay_and(

    output wire out,
    input wire in1, in2
);

    assign #10 out = in1 & in2;
endmodule

