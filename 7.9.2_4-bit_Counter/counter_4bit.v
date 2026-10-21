`timescale 1ns/1ps

module counter_4bit(

    output reg [3:0] Q,
    input wire clock, clear
);

    always @(posedge clock or negedge clear) begin
        if(!clear)
            Q <= 4'd0;
        else
            Q <= Q + 4'd1;
    end
    
endmodule