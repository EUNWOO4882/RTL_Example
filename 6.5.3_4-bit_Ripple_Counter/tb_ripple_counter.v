`timescale 1ns/1ps

module tb_ripple_counter();

    wire [3:0] Q;
    reg CLOCK, CLEAR;

    ripple_counter dut(.q(Q), .clock(CLOCK), .clear(CLEAR));

    initial begin
        $dumpfile("tb_ripple_counter.vcd");
        $dumpvars(0, tb_ripple_counter);
        $monitor("time = %0d, Count Q = %b, Clear = %b", $time, Q, CLEAR);
    end

    initial begin
        CLEAR = 1'b1;
        #34 CLEAR = 1'b0;
        #200 CLEAR = 1'b1;
        #50 CLEAR = 1'b0;
    end

    initial begin
        CLOCK = 1'b0;
        forever #10 CLOCK = ~CLOCK;
    end

    initial
        #400 $finish;
endmodule