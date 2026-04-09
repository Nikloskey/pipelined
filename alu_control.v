module alu_control (
    input wire [1:0] alu_op,
    input wire [3:0] alu_funct, // {instr[30], instr[14:12]}
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // Load/Store: Force Add
            2'b01: alu_ctrl = 4'b0110; // Branch: Force Subtract (for equality check)
            2'b10: begin // R-Type 
                case (alu_funct)
                    4'b0000: alu_ctrl = 4'b0010; // add
                    4'b1000: alu_ctrl = 4'b0110; // sub
                    4'b0111: alu_ctrl = 4'b0000; // and
                    4'b0110: alu_ctrl = 4'b0001; // or
                    4'b0010: alu_ctrl = 4'b0111; // slt
                    default: alu_ctrl = 4'b0000; // Default fallback
                endcase
            end
            2'b11: begin // I-Type
                case (alu_funct[2:0]) // funct3 for I-Type
                    3'b000: alu_ctrl = 4'b0010; // addi -> Force Add
                    3'b111: alu_ctrl = 4'b0000; // andi
                    3'b110: alu_ctrl = 4'b0001; // ori
                    3'b010: alu_ctrl = 4'b0111; // slti
                    default: alu_ctrl = 4'b0000; // Default fallback
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule