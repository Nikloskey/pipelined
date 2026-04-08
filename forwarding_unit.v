module forwarding_unit (
    input  wire [4:0] ex_rs1,
    input  wire [4:0] ex_rs2,
    
    // Snoop the EX/MEM Wall (1 cycle ahead)
    input  wire [4:0] mem_rd,
    input  wire       mem_reg_write,
    
    // Snoop the MEM/WB Wall (2 cycles ahead)
    input  wire [4:0] wb_rd,
    input  wire       wb_reg_write,
    
    // Multiplexer Controls
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b
);

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX/MEM forwarding (1 cycle old)
        if (mem_reg_write && (mem_rd != 5'b00000)) begin
            if (mem_rd == ex_rs1) forward_a = 2'b10;
            if (mem_rd == ex_rs2) forward_b = 2'b10;
        end

        // MEM/WB forwarding (2 cycles old, only if not already forwarded)
        if (wb_reg_write && (wb_rd != 5'b00000)) begin
            if ((wb_rd == ex_rs1) && ~(mem_reg_write && (mem_rd != 5'b00000) && (mem_rd == ex_rs1))) begin
                forward_a = 2'b01;
            end
            if ((wb_rd == ex_rs2) && ~(mem_reg_write && (mem_rd != 5'b00000) && (mem_rd == ex_rs2))) begin
                forward_b = 2'b01;
            end
        end
    end

endmodule