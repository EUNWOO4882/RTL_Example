`timescale 1ns/1ps

module FIFO_MEM_BLK #(
    parameter FWIDTH = 32,      // Data width of one word.
    parameter FDEPTH = 4,       // Number of words.
    parameter FCWIDTH = 2       // Address width (2**FCWIDTH = FDEPTH).
)(
    output [FWIDTH-1:0] data_out,   // Data at rd_addr (asynchronous read).

    input clk,                      // Clock.
    input write,                    // Write enable (active high).
    input [FCWIDTH-1:0] wr_addr,    // Write address.
    input [FCWIDTH-1:0] rd_addr,    // Read address.
    input [FWIDTH-1:0] data_in      // Data to write.
);
    reg [FWIDTH-1:0] FIFO[0:FDEPTH-1];  // Storage : FDEPTH words of FWIDTH bits.


    always @(posedge clk) begin
        if(write)
            FIFO[wr_addr] <= data_in;
    end

    assign data_out = FIFO[rd_addr];

endmodule
