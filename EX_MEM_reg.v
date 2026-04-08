module EX_MEM_reg (
    input wire clk,
    input wire rst,

    // --- DATAPATH INPUTS (From EX) ---
    input wire [31:0] alu_result_in,
    input wire [31:0] rs2_data_in,
    
    // --- METADATA INPUTS ---
    input wire [4:0]  rd_addr_in,

    // --- CONTROL INPUTS (Survivors) ---
    input wire mem_read_in,
    input wire mem_write_in,
    input wire reg_write_in,
    input wire mem_to_reg_in,

    // ==========================================
    // --- DATAPATH OUTPUTS (To MEM) ---
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,

    // --- METADATA OUTPUTS ---
    output reg [4:0]  rd_addr_out,

    // --- CONTROL OUTPUTS ---
    output reg mem_read_out,
    output reg mem_write_out,
    output reg reg_write_out,
    output reg mem_to_reg_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 32'b0;
            rs2_data_out   <= 32'b0;
            rd_addr_out    <= 5'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end else begin
            // Normal operation: latch everything.
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            rd_addr_out    <= rd_addr_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end

endmodule