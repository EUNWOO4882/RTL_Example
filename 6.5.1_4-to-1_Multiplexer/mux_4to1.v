`timescale 1ns/1ps

module mux_4to1(

    output wire out,
    input wire i0, i1, i2, i3,
    input wire s0, s1
);

    assign out = s1 ? (s0 ? i3 : i2) : (s0 ? i1 : i0);

endmodule