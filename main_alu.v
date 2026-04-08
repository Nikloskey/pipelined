`include "ksa.v"

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output wire [31:0] result,
    output wire        zero
);

    wire [31:0] signed_b, sum, anded, orred;
    wire slt, n, c, v;
    
    wire is_subtract = (alu_ctrl == 4'b0110) || (alu_ctrl == 4'b0111);

    assign signed_b = is_subtract ? ~b : b; 

    ks_adder_param #(.WIDTH(32), .LEVELS(5)) adder0(
        .a(a),
        .b(signed_b),
        .cin(is_subtract),
        .sum(sum),
        .cout(c)
    );

    assign anded = a & b;
    assign orred = a | b;

    assign n = result[31];
    assign zero = (result == 32'b0);
    assign v = ~(a[31] ^ signed_b[31]) & (a[31] ^ sum[31]);
    assign slt = sum[31] ^ v;

    assign result = 
        (alu_ctrl == 4'b0010) ? sum :    // ADD
        (alu_ctrl == 4'b0110) ? sum :    // SUB
        (alu_ctrl == 4'b0000) ? anded :  // AND
        (alu_ctrl == 4'b0001) ? orred :  // OR
        (alu_ctrl == 4'b0111) ? {31'b0, slt} : // SLT
        32'b0;

endmodule