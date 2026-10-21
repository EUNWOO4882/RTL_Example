`timescale 1ns/1ps

module mux4_to_1(

    output reg out,
    input wire i0, i1, i2, i3
    input wire s0, s1
);

    always @(*) begin
        case({s1, s0})
        2'd00: out = i0;
        2'd01: out = i1;
        2'd10: out = i2;
        2'd11: out = i3;
        endcase
    end

endmodule