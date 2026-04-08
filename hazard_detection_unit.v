module hazard_detection_unit (
    input  wire [4:0] id_rs1,
    input  wire [4:0] id_rs2,
    input  wire [4:0] ex_rd,
    input  wire       ex_mem_read, // High only for 'lw' instructions
    output reg        stall
);

    always @(*) begin
        // Default: No stall
        stall = 1'b0;

        if (ex_mem_read && (ex_rd != 5'b0) && ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
            stall = 1'b1;
        end
    end
endmodule