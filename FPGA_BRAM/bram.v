`timescale 1ns/1ps

module bram #(

    parameter DWIDTH = 16,
    parameter AWIDTH = 12,
    parameter MEM_SIZE = 3840
)(

    input clk,

    //Port A
    output reg [DWIDTH-1:0] q0,
    input [AWIDTH-1:0] addr0,
    input ce0,
    input we0,
    input [DWIDTH-1:0] d0,

    //Port B
    output reg [DWIDTH-1:0] q1,
    input ce1,
    input we1,
    input [DWIDTH-1:0] d1,
    input [AWIDTH-1:0] addr1
);

    reg [DWIDTH-1:0] ram [0:MEM_SIZE-1];

    always @(posedge clk) begin 
        if (ce0) begin
            if (we0) 
                ram[addr0] <= d0;
            else
                q0 <= ram[addr0];
        end
    end

    always @(posedge clk) begin 
        if (ce1) begin
            if (we1) 
                ram[addr1] <= d1;
            else
                q1 <= ram[addr1];
        end
    end

endmodule