module alu_control (
    input wire [1:0] alu_op,
    input wire [3:0] alu_funct, // {instr[30], instr[14:12]}
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // Load/Store: Force Add
            2'b01: alu_ctrl = 4'b0110; // Branch: Force Subtract (for equality check)
            2'b10: begin // R-Type / I-Type: Decode the funct bits
                case (alu_funct)
                    4'b0000: alu_ctrl = 4'b0010; // add
                    4'b1000: alu_ctrl = 4'b0110; // sub
                    4'b0111: alu_ctrl = 4'b0000; // and
                    4'b0110: alu_ctrl = 4'b0001; // or
                    default: alu_ctrl = 4'b0000; // Default fallback
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule