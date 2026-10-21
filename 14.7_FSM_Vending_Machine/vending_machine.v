`timescale 1ns/1ps

module vending_machine(

    output release_door,
    input [1:0] coin,
    input clk, rst_n
);
    localparam S0 = 2'b00;
    localparam S5 = 2'b01;
    localparam S10 = 2'b10;
    localparam S15 = 2'b11;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case(state)
            S0:
                if(coin == 2'b01)
                    next_state = S5;
                else if(coin == 2'b10)
                    next_state = S10;
            S5:
                if(coin == 2'b01)
                    next_state = S10;
                else if(coin == 2'b10)
                    next_state = S15;
            S10:
                if(coin == 2'b01 || coin == 2'b10)
                    next_state = S15;
            S15:
                next_state = S0;
        endcase
    end

    assign release_door = (state == S15);

endmodule