`timescale 1ns/1ps

module tb_automatic_task#(
    parameter delay = 10
)();
    reg clk, clk2;
    reg [15:0] c, d, e, f;
    reg [15:0] ef_s, cd_s;
    reg [15:0] ef_a, cd_a;

    
    task xor_static(
        output [15:0] ab_xor,
        input [15:0] a, b
    );
        begin
            $display("[%0d] static start : a=%h b=%h", $time, a, b);
            #delay ab_xor = a ^ b;
            $display("[%0d] static end   : a=%h b=%h -> %h", $time, a, b, ab_xor);
        end
    endtask

    
    task automatic xor_auto(
        output [15:0] ab_xor,
        input [15:0] a, b
    );    
        begin
            $display("[%0d] static start : a=%h b=%h", $time, a, b);
            #delay ab_xor = a ^ b;
            $display("[%0d] static end   : a=%h b=%h -> %h", $time, a, b, ab_xor);
        end
    endtask

    always @(posedge clk)
        xor_static(ef_s, e, f);
    
    always @(posedge clk2)
        xor_static(cd_s, c, d);
    
    always @(posedge clk)
        xor_auto(ef_a, e, f);
    
    always @(posedge clk2)
        xor_auto(cd_a, c, d);

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        clk2 = 0;
        #3 forever #10 clk2 = ~clk2;
    end

    initial begin
        e = 16'h00FF;
        f = 16'h0F0F;
        c = 16'hAAAA;
        d = 16'h5555;
    
        #28
        $display("expected: ef = %h cd = %h", e ^ f, c ^ d);
        $display("static    : ef=%h  cd=%h  %s", ef_s, cd_s,
             (ef_s === (e ^ f)) ? "PASS" : "FAIL");
        $display("automatic : ef=%h  cd=%h  %s", ef_a, cd_a,
             (ef_a === (e ^ f)) ? "PASS" : "FAIL");
        $finish;
    end

endmodule