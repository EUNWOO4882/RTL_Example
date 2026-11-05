`timescale 1ns/1ps

module bram_ctrl #(

    parameter DWIDTH = 16,
    parameter AWIDTH = 12,
    parameter MEM_SIZE = 3840
)(
    output o_idle,
    output o_write,
    output o_read,
    output o_done,

    input clk,
    input rst_n,
    input i_run,
    input [AWIDTH-1:0] i_num_cnt,

    //Memory I/F
    output [AWIDTH-1:0] addr0,
    output ce0,
    output we0,
    output [DWIDTH-1:0] d0,
    input [DWIDTH-1:0] q0,

    //output read value from BRAM
    output o_valid,
    output [DWIDTH-1:0] o_mem_data
);
    
    //FSM Control logic
    localparam S_IDLE = 2'b00;
    localparam S_WRITE = 2'b01;
    localparam S_READ = 2'b10;
    localparam S_DONE = 2'b11;

    reg [1:0] c_state, n_state;
    wire is_write_done, is_read_done;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            c_state <= S_IDLE;
        else
            c_state <= n_state;
    end

    always @(*) begin
        case(c_state)
            S_IDLE: if(i_run)
                        n_state = S_WRITE;
                    else
                        n_state = S_IDLE;
            S_WRITE:    if(is_write_done)
                            n_state =  S_READ;
                        else
                            n_state = S_WRITE;
            S_READ: if(is_read_done)
                        n_state = S_DONE;
                    else
                        n_state = S_READ;
            S_DONE: n_state = S_IDLE;
        endcase
    end

    assign o_idle = (c_state == S_IDLE);
    assign o_write = (c_state == S_WRITE);
    assign o_read = (c_state == S_READ);
    assign o_done = (c_state == S_DONE);

    
    //addr_cnt
    reg [AWIDTH-1:0] num_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            num_cnt <= 0;
        else if(i_run) 
            num_cnt <= i_num_cnt;
        else if(o_done)
            num_cnt <= 0;
    end

    reg [AWIDTH-1:0] addr_cnt;
    assign is_write_done = o_write && (addr_cnt == num_cnt - 1);
    assign is_read_done  = o_read  && (addr_cnt == num_cnt - 1);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            addr_cnt <= 0;
        else if(is_write_done || is_read_done)
            addr_cnt <= 0;
        else if(o_write || o_read)
            addr_cnt <= addr_cnt + 1;
    end


    //Memeory I/F
    assign addr0 = addr_cnt;
    assign ce0 = o_write || o_read;
    assign we0 = o_write;
    assign d0 = addr_cnt;

    //output data from memory
    reg r_valid;
    reg [DWIDTH-1:0] r_mem_data;
    
    //1-cycle latency to sync mem output
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            r_valid <= 0;
        else
            r_valid <= o_read;
    end

    assign o_valid = r_valid;
    assign o_mem_data = q0;

endmodule