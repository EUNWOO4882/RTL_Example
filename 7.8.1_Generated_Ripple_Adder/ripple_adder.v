`timescale 1ns/1ps

module ripple_adder #(

    parameter N = 4
)(
    output wire [N-1:0] sum,
    output wire co,
    input wire [N-1:0] a0, a1,
    input wire ci
);

    wire [N:0] carry;
    assign carry[0] = ci;

    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: r_loop
            wire t1, t2, t3;
            xor g1 (t1, a0[i], a1[i]);
            xor g2 (sum[i], t1, carry[i]);
            and g3(t2, a0[i], a1[i]);
            and g4 (t3, t1, carry[i]); 
            or  g5 (carry[i+1], t2, t3);
        end
    endgenerate

    assign co = carry[N];
endmodule