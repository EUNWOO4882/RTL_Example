`timescale 1ns/1ps

module parity();

    reg [31:0] addr;
    reg parity;

    function calc_parity(
        input [31:0] address
    );
        calc_parity = ^address;
    endfunction

    always @(addr) begin
        parity = calc_parity(addr);
        $display("Parity calculated = %b", parity);
    end

    initial begin
        $display("addr = 32'h0000_0000 (expected 0)");
        addr = 32'h0000_0000;
        #10 $display("addr = 32'h0000_0001 (expected 1)");
        addr = 32'h0000_0001;
        #10 $display("addr = 32'h3456_789A (expected 1)");
        addr = 32'h3456_789A;
        #10 $display("addr = 32'hFFFF_FFFF (expected 0)");
        addr = 32'hFFFF_FFFF;
        #10 $finish;
    end

endmodule
