`timescale 1ns/1ps

module top();
    
    function automatic integer factorial(
        input [31:0] oper    
    );
        begin
            if(oper >= 32'd2)
                factorial = factorial(oper - 32'd1) * oper;
            else
                factorial = 32'd1;
        end
    endfunction

    integer result;
    initial begin
        result = factorial(32'd4);
        $display("Factorial of 4 is %0d", result);
    end
endmodule