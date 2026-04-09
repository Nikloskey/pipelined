module id_forwarding_unit (
    input  wire [4:0] id_rs1,
    input  wire [4:0] id_rs2,
    input  wire [4:0] mem_rd,
    input  wire       mem_reg_write,
    input  wire [4:0] wb_rd,
    input  wire       wb_reg_write,
    
    output reg  [1:0] forward_branch_a,
    output reg  [1:0] forward_branch_b
);

    // 00: Default (Read from Register File)
    // 10: Forward from MEM stage (mem_alu_result)
    // 01: Forward from WB stage (wb_write_data)

    always @(*) begin
        // --- Operand A Forwarding ---
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == id_rs1)) begin
            forward_branch_a = 2'b10; 
        end
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == id_rs1)) begin
            forward_branch_a = 2'b01;
        end
        else begin
            forward_branch_a = 2'b00;
        end

        // --- Operand B Forwarding ---
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == id_rs2)) begin
            forward_branch_b = 2'b10;
        end
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == id_rs2)) begin
            forward_branch_b = 2'b01;
        end
        else begin
            forward_branch_b = 2'b00;
        end
    end

endmodule