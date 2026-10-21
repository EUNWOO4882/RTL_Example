`timescale 1ns/1ps

module tb_vending_machine();

    wire RELEASE_DOOR;
    reg [1:0] COIN;
    reg CLK, RST_N;

    vending_machine dut(.release_door(RELEASE_DOOR), .coin(COIN), .clk(CLK), .rst_n(RST_N));

    initial begin
        $display("Time  RST_N  State  COIN  RELEASE_DOOR");
        $monitor("%4d  %b      %b     %b    %b", $time, RST_N, dut.state, COIN, RELEASE_DOOR);
    end

    initial begin
        CLK = 1'b0;
        forever #20 CLK = ~CLK;
    end

    task reset_dut;
        begin
            RST_N = 1'b0;
            repeat(2) @(negedge CLK);
            RST_N = 1'b1;
        end
    endtask

    task insert_coin(
        input [1:0] c);
        begin
            @(posedge CLK)
                COIN <= c;
            @(posedge CLK)
                COIN <= 2'b00;
        end
    endtask

    task idle(
        input integer n);
        repeat(n) @(posedge CLK);
    endtask

    // 마지막 동전이 샘플링된 다음 negedge에서 S15이고 RELEASE_DOOR = 1인지 확인
    task check_s15;
        begin
            @(negedge CLK)
                if (dut.state == 2'b11 && RELEASE_DOOR == 1'b1)
                    $display("%4d  PASS: S15, RELEASE_DOOR = 1", $time);
                else
                    $display("%4d  FAIL: State = %b, RELEASE_DOOR = %b", $time, dut.state, RELEASE_DOOR);
        end
    endtask

    initial begin
        COIN = 2'b00;
        RST_N = 1'b1;
        #10 reset_dut;

        // nickel 3개
        insert_coin(2'b01);
        insert_coin(2'b01);
        insert_coin(2'b01);
        check_s15;
        idle(3);

        // nickel -> dime
        insert_coin(2'b01);
        insert_coin(2'b10);
        check_s15;
        idle(3);

        // dime 2개
        insert_coin(2'b10);
        insert_coin(2'b10);
        check_s15;
        idle(3);

        // dime -> nickel
        insert_coin(2'b10);
        insert_coin(2'b01);
        check_s15;
        idle(3);

        // 2'b11은 사양에 없는 동전 -> 무시되고 nickel -> dime으로 S15
        insert_coin(2'b11);
        insert_coin(2'b01);
        insert_coin(2'b11);
        insert_coin(2'b10);
        check_s15;
        idle(3);

        $finish;
    end
endmodule
