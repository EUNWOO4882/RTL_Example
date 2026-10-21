`timescale 1ns/1ps

module T_FF(

    output reg q,
    input wire clk, rst
);

    wire d;
    assign d = ~q;

    always @(negedge clk or posedge rst) begin
        if(rst) 
            q <= 1'd0;
        else
            q <= d;
    end
endmodule

