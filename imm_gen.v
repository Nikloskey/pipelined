module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm
);
    // Extract the opcode directly from the instruction
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-Type (Load, addi, slli, etc.)
            // The 12-bit immediate is at the top of the instruction [31:20]
            7'b0000011, // lw
            7'b0010011, // I-type math
            7'b1100111: // jalr
                imm = {{20{instr[31]}}, instr[31:20]};

            // S-Type (Store)
            // The 12-bit immediate is split between [31:25] and [11:7]
            7'b0100011: // sw
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-Type (Branch)
            // The 12-bit immediate is split and scrambled, and we implicitly add a 0 at the end 
            // because branches must jump by multiples of 2 (half-words).
            7'b1100011: // beq, bne, etc.
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // U-Type (LUI, AUIPC)
            // 20-bit immediate is already at the top, just fill the bottom with zeros.
            7'b0110111, // lui
            7'b0010111: // auipc
                imm = {instr[31:12], 12'b0};

            // J-Type (JAL)
            // 20-bit scrambled immediate, implicitly adding a 0 at the end.
            7'b1101111: // jal
                imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            // Default fallback (R-Type instructions like 'add' don't use immediates)
            default: 
                imm = 32'b0;
        endcase
    end
endmodule