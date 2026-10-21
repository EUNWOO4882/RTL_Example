`timescale 1ns/1ps

module ripple_counter(

    output wire [3:0] q,
    input wire clock, clear
);

    T_FF tff0(.q(q[0]), .clk(clock), .rst(clear));
    T_FF tff1(.q(q[1]), .clk(q[0]), .rst(clear));
    T_FF tff2(.q(q[2]), .clk(q[1]), .rst(clear));
    T_FF tff3(.q(q[3]), .clk(q[2]), .rst(clear));

endmodule