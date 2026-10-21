`timescale 1ns/1ps

module tb_sig_control();

    wire [1:0] MAIN_SIG, CNTRY_SIG;
    reg CAR_ON_CNTRY_RD;
    reg CLOCK, RST_N;

    sig_control DUT(.hwy(MAIN_SIG), .cntry(CNTRY_SIG), .X(CAR_ON_CNTRY_RD), .clk(CLOCK), .rst_n(RST_N));

    initial begin
        $dumpfile("tb_sig_control.vcd");
        $dumpvars(0, tb_sig_control);
        $monitor("time = %0d, State = S%0d, Main Sig = %b, Country Sig = %b, Car_on_cntry_rd = %b",
                    $time, DUT.state, MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD);
    end

    initial begin
        CLOCK = 1'b0;
        #5 forever begin
            #5 CLOCK = ~CLOCK;
        end
    end

    initial begin
        RST_N = 1'b0;
        CAR_ON_CNTRY_RD = 1'b0;
        #25  RST_N = 1'b1;              
        #50  CAR_ON_CNTRY_RD = 1'b1;    
        #150 CAR_ON_CNTRY_RD = 1'b0;    
        #100 $finish;
    end

endmodule
