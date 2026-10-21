`timescale 1ns/1ps

module tb_shifter #(
    parameter LEFT_SHIFT = 1'b0,
    parameter RIGHT_SHIFT = 1'b1
)();
    reg [31:0] addr, left_addr, right_addr;

    function [31:0] shift(
        input [31:0] address,
        input control
    );
        shift = (control == LEFT_SHIFT) ? (address << 1) : (address >> 1);
    endfunction

    always @(addr) begin
        left_addr = shift(addr, LEFT_SHIFT);
        right_addr = shift(addr, RIGHT_SHIFT);
    end

    task check(
        input [31:0] a, exp_left, exp_right
    );
        begin
            addr = a;
            #10;
            $display("addr=%h  left=%h (exp %h) %s  right=%h (exp %h) %s",
                     addr,
                     left_addr, exp_left, (left_addr === exp_left) ? "PASS" : "FAIL",
                     right_addr, exp_right, (right_addr === exp_right) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        check(32'h0000_0001, 32'h0000_0002, 32'h0000_0000);
        check(32'h8000_0001, 32'h0000_0002, 32'h4000_0000);
        check(32'h1234_5678, 32'h2468_ACF0, 32'h091A_2B3C);
        check(32'hFFFF_FFFF, 32'hFFFF_FFFE, 32'h7FFF_FFFF);
        $finish;
    end

endmodule
