`timescale 1ns/1ps

module tb_delay_and();

    wire OUT;
    reg IN1, IN2;

    delay_and DUT(.out(OUT), .in1(IN1), .in2(IN2));

    initial begin
        $dumpfile("tb_delay_and.vcd");
        $dumpvars(0, tb_delay_and);
        $monitor("t = %0d, IN1 = %b, IN2 = %b, out = %b", $time, IN1, IN2, OUT);
    end

    initial begin
        IN1 = 0; IN2 = 0;
        #20 IN1 = 1; IN2 = 1;
        #40 IN1 = 0;
        #20 IN1 = 1;
        #5 IN1 = 0;
        #20 $finish;
    end
endmodule