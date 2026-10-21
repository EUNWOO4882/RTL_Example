`timescale 1ns/1ps

module tb_FIFO();

    parameter FWIDTH = 32;
    parameter FDEPTH = 4;
    parameter FCWIDTH = 2;

    wire [FWIDTH-1:0] F_Data;
    wire F_Full, F_Empty, F_Last, F_SLast, F_First;
    reg [FWIDTH-1:0] Data_In;
    reg Clk, RstN;
    reg FIn, FClr, FOut;

    FIFO #(
        .FWIDTH(FWIDTH),
        .FDEPTH(FDEPTH),
        .FCWIDTH(FCWIDTH)
    ) dut (
        .F_Data(F_Data),
        .F_Full(F_Full),
        .F_Empty(F_Empty),
        .F_Last(F_Last),
        .F_SLast(F_SLast),
        .F_First(F_First),
        .Clk(Clk),
        .RstN(RstN),
        .Data_In(Data_In),
        .FIn(FIn),
        .FClr(FClr),
        .FOut(FOut)
    );

    // Reference model : words that should be stored in the FIFO.
    reg [FWIDTH-1:0] exp_mem [0:FDEPTH-1];  // Expected FIFO contents.
    integer exp_head;                       // Position of the oldest word.
    integer exp_cnt;                        // Expected number of words.
    integer err_cnt;                        // Number of failed checks.

    initial begin
        Clk = 1'b0;
        forever #10 Clk = ~Clk;
    end

    // Update the reference model with the same rules as the FIFO.
    // Clear has priority, write is ignored when full, read is ignored when empty.
    task model_update(
        input clr,
        input wr,
        input rd,
        input [FWIDTH-1:0] din);
        reg we, re;
        begin
            we = !clr && wr && (exp_cnt < FDEPTH);
            re = !clr && rd && (exp_cnt > 0);

            if(we)
                exp_mem[(exp_head + exp_cnt) % FDEPTH] = din;

            if(clr)
                exp_head = 0;
            else if(re)
                exp_head = (exp_head + 1) % FDEPTH;

            if(clr)
                exp_cnt = 0;
            else
                exp_cnt = exp_cnt + we - re;
        end
    endtask

    // Compare word count, 5 status flags and the oldest word (F_Data) with the model.
    task check_status(
        input [8*16-1:0] op);
        reg [4:0] exp_flags;
        reg ok_cnt, ok_flags, ok_data;
        begin
            exp_flags = {exp_cnt == 0,              // F_Empty
                         exp_cnt == 1,              // F_First
                         exp_cnt == FDEPTH-2,       // F_SLast
                         exp_cnt == FDEPTH-1,       // F_Last
                         exp_cnt == FDEPTH};        // F_Full

            ok_cnt   = (dut.data_cnt === exp_cnt);
            ok_flags = ({F_Empty, F_First, F_SLast, F_Last, F_Full} === exp_flags);
            ok_data  = (exp_cnt == 0) || (F_Data === exp_mem[exp_head]);

            if(!(ok_cnt && ok_flags && ok_data))
                err_cnt = err_cnt + 1;

            $display("%5d |  %b   %b   %b   %b   %b  |  %0d  | %h | %h | %s | %0s",
                     $time, F_Empty, F_First, F_SLast, F_Last, F_Full, dut.data_cnt,
                     Data_In, F_Data, (ok_cnt && ok_flags && ok_data) ? "PASS" : "FAIL", op);
        end
    endtask

    // Drive one request for one clock (at negedge), then check right after posedge.
    task fifo_op(
        input clr,
        input wr,
        input rd,
        input [FWIDTH-1:0] din,
        input [8*16-1:0] op);
        begin
            @(negedge Clk);
            FClr = clr;
            FIn = wr;
            FOut = rd;
            Data_In = din;
            model_update(clr, wr, rd, din);

            @(posedge Clk);
            #1;
            check_status(op);
        end
    endtask

    // Write only.
    task push(
        input [FWIDTH-1:0] din);
        fifo_op(1'b0, 1'b1, 1'b0, din, "write");
    endtask

    // Read only.
    task pop;
        fifo_op(1'b0, 1'b0, 1'b1, 0, "read");
    endtask

    // Write and read in the same clock.
    task push_pop(
        input [FWIDTH-1:0] din);
        fifo_op(1'b0, 1'b1, 1'b1, din, "write+read");
    endtask

    // Clear only.
    task clear;
        fifo_op(1'b1, 1'b0, 1'b0, 0, "clear");
    endtask

    // Clear and write in the same clock.
    task clear_push(
        input [FWIDTH-1:0] din);
        fifo_op(1'b1, 1'b1, 1'b0, din, "clear+write");
    endtask

    // No request for n clocks.
    task idle(
        input integer n);
        repeat(n)
            fifo_op(1'b0, 1'b0, 1'b0, 0, "idle");
    endtask

    // Asynchronous reset : the FIFO must be initialized without waiting for a clock edge.
    // All requests are dropped during reset to avoid an unintended write/read after release.
    task reset_dut;
        begin
            RstN = 1'b0;
            FIn = 1'b0;
            FOut = 1'b0;
            FClr = 1'b0;
            model_update(1'b1, 1'b0, 1'b0, 0);
            #1;
            check_status("async reset");

            repeat(2) @(negedge Clk);
            RstN = 1'b1;
        end
    endtask

    initial begin
        err_cnt = 0;
        exp_head = 0;
        exp_cnt = 0;
        RstN = 1'b1;
        FIn = 1'b0;
        FOut = 1'b0;
        FClr = 1'b0;
        Data_In = 0;

        $display(" time | Emp Fst SLs Lst Ful | cnt | Data_In  | F_Data   | chk  | op");
        $display("------+---------------------+-----+----------+----------+------+------------");

        #5 reset_dut;

        // 1. Write 4 words into an empty FIFO : Empty -> First -> SLast -> Last -> Full
        $display("[1] write x4");
        push(32'h1111_1111);
        push(32'h2222_2222);
        push(32'h3333_3333);
        push(32'h4444_4444);

        // 2. Write when full : ignored, stored words are not overwritten.
        $display("[2] write when full");
        push(32'hFFFF_FFFF);

        // 3. Write+read when full : only the read is performed (4 -> 3).
        $display("[3] write+read when full");
        push_pop(32'hEEEE_EEEE);

        // 4. Read the remaining 3 words : output in write order (2222 -> 3333 -> 4444), then Empty.
        $display("[4] read x3");
        pop;
        pop;
        pop;

        // 5. Read when empty : ignored.
        $display("[5] read when empty");
        pop;

        // 6. Write+read when empty : only the write is performed (0 -> 1).
        $display("[6] write+read when empty");
        push_pop(32'h5555_5555);

        // 7. Write+read with data : count is kept, only the oldest word changes.
        //    (After 8 writes in total, both pointers wrap around 0~3 twice.)
        $display("[7] write+read with data");
        push_pop(32'h6666_6666);
        push(32'h7777_7777);
        push_pop(32'h8888_8888);
        pop;
        pop;

        // 8. Clear with 3 words stored : Empty right after clear, then normal operation.
        $display("[8] clear");
        push(32'hAAAA_AAAA);
        push(32'hBBBB_BBBB);
        push(32'hCCCC_CCCC);
        clear;
        push(32'hDDDD_DDDD);
        pop;

        // 9. Clear and write in the same clock : clear has priority, FIFO becomes Empty.
        $display("[9] clear+write");
        push(32'h1234_5678);
        clear_push(32'h9ABC_DEF0);

        // 10. Reset in the middle of a clock with 2 words stored : Empty at once, then normal operation.
        $display("[10] async reset");
        push(32'hCAFE_0001);
        push(32'hCAFE_0002);
        reset_dut;
        push(32'hBEEF_0001);
        pop;
        idle(1);

        $display("------+---------------------+-----+----------+----------+------+------------");
        if(err_cnt == 0)
            $display("RESULT: ALL PASS");
        else
            $display("RESULT: %0d FAIL", err_cnt);
        $finish;
    end

endmodule
