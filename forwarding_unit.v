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
        // Default: No hazard detected, read normally from the ID/EX wall
        forward_a = 2'b00;
        forward_b = 2'b00;

        // 1. EX/MEM Hazard (Data is sitting right behind the ALU)
        // This takes priority because it is the most recent instruction.
        if (mem_reg_write && (mem_rd != 5'b00000)) begin
            if (mem_rd == ex_rs1) forward_a = 2'b10;
            if (mem_rd == ex_rs2) forward_b = 2'b10;
        end

        // 2. MEM/WB Hazard (Data has reached the end of the pipeline)
        // We only forward from here if the EX/MEM stage isn't ALREADY forwarding it.
        // (This protects against code like: add x1,x2,x3 -> add x1,x1,x4 -> add x5,x1,x1)
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