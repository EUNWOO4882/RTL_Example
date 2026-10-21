`timescale 1ns/1ps

module sig_control#(

    parameter G2Y_DELAY = 3,
    parameter Y2R_DELAY = 4,
    parameter R2G_DELAY = 2
        
)(
    output reg [1:0] hwy, cntry,
    input X, clk, rst_n
);

    localparam S0 = 3'd0;
    localparam S1 = 3'd1;
    localparam S2 = 3'd2;
    localparam S3 = 3'd3;
    localparam S4 = 3'd4;
    localparam S5 = 3'd5;

    localparam GREEN = 2'd0;
    localparam YELLOW = 2'd1;
    localparam RED = 2'd2;

    reg [2:0] state, next_state;
    reg [1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S0;
            cnt <= 2'd0;
        end
        else begin
            state <= next_state;
            cnt <= (next_state != state) ? 2'd0 : cnt + 2'd1;
        end
    end

    always @(*) begin
        case(state)
            S0: if(X && cnt == G2Y_DELAY - 2'd1)
                    next_state = S1;
                else
                    next_state = S0;
            S1: if(cnt == Y2R_DELAY - 2'd1)
                    next_state = S2;
                else
                    next_state = S1;
            S2: if(cnt == R2G_DELAY - 2'd1)
                    next_state = S3;
                else
                    next_state = S2;
            S3: if(cnt == G2Y_DELAY - 2'd1)
                    next_state = S4;
                else
                    next_state = S3;
            S4: if(!X && cnt == Y2R_DELAY - 2'd1)
                    next_state = S5;
                else
                    next_state = S4;
            S5: if(cnt == R2G_DELAY - 2'd1)
                    next_state = S0;
                else
                    next_state = S5;
            default: next_state = S0;
        endcase
    end

    always @(*) begin
        case(state) 
            S0:begin
                hwy = GREEN;
                cntry = RED;
            end
            S1: begin
                 hwy = YELLOW;
                 cntry = RED;
            end
            S2:begin
                hwy = RED;
                cntry = RED;
            end
            S3:begin
                hwy = RED;
                cntry = GREEN;
            end
            S4: begin
                 hwy = RED;
                 cntry = YELLOW;
            end
            S5:begin
                hwy = RED;
                cntry = RED;
            end
            default : begin
                    hwy = GREEN;
                    cntry = RED;
            end
        endcase
    end

endmodule
