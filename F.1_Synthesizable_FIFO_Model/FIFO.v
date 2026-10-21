`timescale 1ns/1ps

module FIFO #(
    parameter FWIDTH = 32,      // Data width of one FIFO word.
    parameter FDEPTH = 4,       // Number of words the FIFO can hold.
    parameter FCWIDTH = 2       // Pointer width (2**FCWIDTH = FDEPTH).
)(
    output [FWIDTH-1:0] F_Data,  // FIFO data out (oldest word in FIFO).
    output reg F_Full,           // FIFO full (FDEPTH words stored).
    output reg F_Empty,          // FIFO empty (no word stored).
    output reg F_Last,           // Only one empty space left (FDEPTH-1 words).
    output reg F_SLast,          // Only two empty spaces left (FDEPTH-2 words).
    output reg F_First,          // Only one word in FIFO.

    input Clk,                   // Clock.
    input RstN,                  // Asynchronous reset (active low).
    input [FWIDTH-1:0] Data_In,  // Data into FIFO.
    input FIn,                   // Write request (active high).
    input FClr,                  // Synchronous clear (active high).
    input FOut                   // Read request (active high).
);

    reg [FCWIDTH:0] data_cnt, data_cnt_next;    // data_cnt      : number of words in FIFO
                                                // data_cnt_next : data_cnt value at next clock

    reg [FCWIDTH-1:0] rd_ptr;    // Read pointer (address of the oldest word).
    reg [FCWIDTH-1:0] wr_ptr;    // Write pointer (address for the next write).


    wire wr_en = FIn && !F_Full;        // Write actually performed (ignored when full).
    wire rd_en = FOut && !F_Empty;      // Read actually performed (ignored when empty).
    wire wr_only = wr_en && !rd_en;     // Write without read : count +1.
    wire rd_only = rd_en && !wr_en;     // Read without write : count -1.


    FIFO_MEM_BLK #(
        .FWIDTH(FWIDTH),
        .FDEPTH(FDEPTH),
        .FCWIDTH(FCWIDTH)
    ) memblk (
        .data_out(F_Data),
        .clk(Clk),
        .write(wr_en),
        .wr_addr(wr_ptr),
        .rd_addr(rd_ptr),
        .data_in(Data_In)
    );


    always @(posedge Clk or negedge RstN) begin
        if(!RstN)
            wr_ptr <= 0;
        else if(FClr)
            wr_ptr <= 0;
        else if(wr_en)
            wr_ptr <= wr_ptr + 1;
    end


    always @(posedge Clk or negedge RstN) begin
        if(!RstN)
            rd_ptr <= 0;
        else if(FClr)
            rd_ptr <= 0;
        else if(rd_en)
            rd_ptr <= rd_ptr + 1;
    end


    always @(*) begin
        if(FClr)
            data_cnt_next = 0;
        else if(wr_only)
            data_cnt_next = data_cnt + 1;
        else if(rd_only)
            data_cnt_next = data_cnt - 1;
        else
            data_cnt_next = data_cnt;
    end


    always @(posedge Clk or negedge RstN) begin
        if(!RstN) begin
            data_cnt <= 0;
            F_Empty  <= 1'b1;
            F_First  <= 1'b0;
            F_SLast  <= 1'b0;
            F_Last   <= 1'b0;
            F_Full   <= 1'b0;
        end
        else begin
            data_cnt <= data_cnt_next;
            F_Empty  <= (data_cnt_next == 0);          
            F_First  <= (data_cnt_next == 1);          
            F_SLast  <= (data_cnt_next == FDEPTH-2);   
            F_Last   <= (data_cnt_next == FDEPTH-1);   
            F_Full   <= (data_cnt_next == FDEPTH);     
        end
    end

endmodule
