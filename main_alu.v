`include "ksa.v"

module alu ( // Renamed to match the motherboard instantiation
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl, // Upgraded to 4-bit
    output wire [31:0] result,   // Renamed
    output wire        zero      // Renamed
);

    wire [31:0] signed_b, sum, anded, orred;
    wire slt, n, c, v;
    
    // In textbook RV32I, Subtraction (0110) and SLT (0111) both require a - b
    wire is_subtract = (alu_ctrl == 4'b0110) || (alu_ctrl == 4'b0111);

    // 2's Complement inversion
    assign signed_b = is_subtract ? ~b : b; 

    // Your Custom Kogge-Stone Adder
    ks_adder_param #(.WIDTH(32), .LEVELS(5)) adder0(
        .a(a),
        .b(signed_b),
        .cin(is_subtract), // Carry-in is 1 for subtraction
        .sum(sum),
        .cout(c)
    );

    assign anded = a & b;
    assign orred = a | b;

    // Flag calculations
    assign n = result[31];
    assign zero = (result == 32'b0);
    assign v = ~(a[31] ^ signed_b[31]) & (a[31] ^ sum[31]);
    assign slt = sum[31] ^ v;

    // Standard Textbook RISC-V ALU Mux
    assign result = 
        (alu_ctrl == 4'b0010) ? sum :         // ADD
        (alu_ctrl == 4'b0110) ? sum :         // SUB
        (alu_ctrl == 4'b0000) ? anded :       // AND
        (alu_ctrl == 4'b0001) ? orred :       // OR
        (alu_ctrl == 4'b0111) ? {31'b0, slt} :// SLT
        32'b0;

endmodule