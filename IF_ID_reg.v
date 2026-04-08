module IF_ID_reg(
    input clk,
    input rst,
    input stall,
    input flush,
    
    input [31:0] instr_in,
    input [31:0] pc_in,

    output reg [31:0] instr_out,
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instr_out <= 32'b0;
            pc_out <= 32'b0;
        end
        else if (flush) begin
            instr_out <= 32'h00000013;
            pc_out <= 32'b0;
        end
        else if (stall) begin
            instr_out <= instr_out;
            pc_out <= pc_out;
        end
        else begin
            instr_out <= instr_in;
            pc_out <= pc_in;
        end
    end

endmodule    