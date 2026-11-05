`timescale 1ns/1ps

`define ADDR_WIDTH 7
`define DATA_WIDTH 16
`define MEM_DEPTH 128

module tb_bram();

reg clk , reset_n;
reg 					i_run;
reg  [`ADDR_WIDTH-1:0]	i_num_cnt;
wire 					o_idle;
wire 					o_write;
wire 					o_read;
wire 					o_done;
 
// Memory I/F
wire [`ADDR_WIDTH-1:0] 	addr0;
wire  					ce0;
wire  					we0;
wire [`DATA_WIDTH-1:0]  q0;
wire [`DATA_WIDTH-1:0] 	d0;

wire  					o_valid;
wire [`DATA_WIDTH-1:0] 	o_mem_data;

// clk gen
always
    #5 clk = ~clk;

integer i;

initial begin
//initialize value
$display("initialize value [%0d]", $time);
    reset_n <= 1;
    clk     <= 0;
	i_run 	<= 0;
	i_num_cnt <= 0;
	
// reset_n gen
$display("Reset! [%0d]", $time);
# 100
    reset_n <= 0;
# 10
    reset_n <= 1;
# 10
@(posedge clk);


$display("Check Idle [%0d]", $time);
wait(o_idle);

$display("Start! [%0d]", $time);
	i_num_cnt <= 7'd100;
	i_run <= 1;
@(posedge clk);
	i_run <= 0;

$display("Wait Done [%0d]", $time);
wait(o_done);

# 100
$display("Success Simulation!! [%0d]", $time);
$finish;
end

// Call DUT
bram_ctrl
#(	.DWIDTH   (`DATA_WIDTH), 
	.AWIDTH   (`ADDR_WIDTH), 
	.MEM_SIZE (`MEM_DEPTH)) 
u_bram_ctrl(
    .clk 			(clk),
    .rst_n 			(reset_n),
	.i_run 			(i_run),
	.i_num_cnt 		(i_num_cnt),
	.o_idle 		(o_idle),
	.o_write 		(o_write),
	.o_read 		(o_read),
	.o_done 		(o_done),

	// Memory I/F
	.addr0		(addr0), 
	.ce0		(ce0), 
	.we0		(we0), 
	.q0			(q0), 
	.d0			(d0),

	// output read value from BRAM
	.o_valid	(o_valid),
	.o_mem_data	(o_mem_data)
    );

// Memory (True Dual Port BRAM for single clock version )
bram
#(	.DWIDTH   (`DATA_WIDTH), 
	.AWIDTH   (`ADDR_WIDTH), 
	.MEM_SIZE (`MEM_DEPTH)) 
u_TDPBRAM(
	.clk		(clk), 

	.addr0		(addr0), 
	.ce0		(ce0), 
	.we0		(we0), 
	.q0			(q0), 
	.d0			(d0), 

// no use port B.
	.addr1 		(0), 
	.ce1		(0), 
	.we1		(0),
	.q1			(), 
	.d1			(0)
);


endmodule
