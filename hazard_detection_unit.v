module hazard_detection_unit (
    input  wire [4:0] id_rs1,
    input  wire [4:0] id_rs2,
    input  wire [4:0] ex_rd,
    input  wire [4:0] mem_rd,
    input  wire       ex_mem_read, // High only for 'lw' instructions
    input  wire       id_branch, // High for branch instructions in ID stage
    input  wire       ex_reg_write, // High if EX stage instruction writes to a register
    input  wire       mem_read_ctrl, // High if MEM stage instruction is a load
    output reg        stall
);

    always @(*) begin
        stall = 1'b0;
        if (ex_mem_read && (ex_rd != 5'b0) && ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
            stall = 1'b1;
        end
        else if (id_branch && ex_reg_write && (ex_rd != 5'b0) && ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
            stall = 1'b1;
        end
        else if (id_branch && mem_read_ctrl && (mem_rd != 5'b0) && ((mem_rd == id_rs1) || (mem_rd == id_rs2))) begin
            stall = 1'b1;
        end
    end
endmodule