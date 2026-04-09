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
        // Default to 0 to prevent latches
        alu_src    = 1'b0;
        alu_op     = 2'b00;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        reg_write  = 1'b0;
        mem_to_reg = 1'b0;

        case (opcode)
            7'b0110011: begin // R-Type: add, sub, and, or
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end
            7'b0010011: begin // I-Type: addi, ori, slli
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b11;
            end
            7'b0000011: begin // lw (load)
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = 2'b00;
            end
            7'b0100011: begin // sw (store)
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 2'b00;
            end
            7'b1100011: begin // beq (branch)
                branch = 1'b1;
                alu_op = 2'b01;
            end
        endcase
    end
endmodule