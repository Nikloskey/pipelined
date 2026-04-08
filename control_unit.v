module control_unit (
    input  wire [6:0] opcode,
    
    // EX Stage Controls
    output reg        alu_src,
    output reg [1:0]  alu_op,
    
    // MEM Stage Controls
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    
    // WB Stage Controls
    output reg        reg_write,
    output reg        mem_to_reg
);

    always @(*) begin
        // Default all signals to 0 to prevent inferred latches 
        // and accidental memory/register corruption.
        alu_src    = 1'b0;
        alu_op     = 2'b00;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        reg_write  = 1'b0;
        mem_to_reg = 1'b0;

        case (opcode)
            7'b0110011: begin // R-Type (add, sub, and, or)
                reg_write = 1'b1;
                alu_op    = 2'b10; // Tell ALU Control to look at funct3/7
            end
            
            7'b0010011: begin // I-Type (addi, ori, slli)
                alu_src   = 1'b1;  // Use Immediate instead of rs2
                reg_write = 1'b1;
                alu_op    = 2'b10; // Custom code for I-Type math
            end
            
            7'b0000011: begin // Load (lw)
                alu_src    = 1'b1; // Add Immediate to rs1 for memory address
                mem_read   = 1'b1; // Turn on SRAM read port
                reg_write  = 1'b1; // Save SRAM data to register
                mem_to_reg = 1'b1; // Flip final WB mux to memory output
                alu_op     = 2'b00; // Force ALU to ADD
            end
            
            7'b0100011: begin // Store (sw)
                alu_src   = 1'b1; // Add Immediate to rs1 for memory address
                mem_write = 1'b1; // Turn on SRAM write port
                alu_op    = 2'b00; // Force ALU to ADD
            end
            
            7'b1100011: begin // Branch (beq)
                branch = 1'b1; // Alert the branch AND gate
                alu_op = 2'b01; // Force ALU to SUBTRACT (rs1 - rs2)
            end
            
            default: begin
                // If it's a NOP or unknown opcode, everything stays 0.
            end
        endcase
    end
endmodule