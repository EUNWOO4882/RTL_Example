`timescale 1ns/1ps

module fulladd4(

    output wire [3:0] sum,
    output wire c_out,
    input wire [3:0] a, b,
    input wire c_in
);

    assign {c_out, sum} = a + b + c_in;
    
endmodule