module ID_EX_reg (
    input wire clk,
    input wire rst,
    input wire flush, // Injects a bubble for Load-Use or Branch mispredict

    // --- DATAPATH INPUTS (From ID) ---
    input wire [31:0] pc_in,
    input wire [31:0] rs1_data_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] imm_in,
    
    // --- METADATA INPUTS ---
    input wire [4:0] rs1_addr_in,
    input wire [4:0] rs2_addr_in,
    input wire [4:0] rd_addr_in,

    // --- CONTROL INPUTS (From Control Unit) ---
    input wire alu_src_in,
    input wire [3:0] alu_funct_in,
    input wire [1:0] alu_op_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire branch_in,
    input wire reg_write_in,
    input wire mem_to_reg_in,

    // ==========================================
    // --- DATAPATH OUTPUTS (To EX) ---
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,

    // --- METADATA OUTPUTS ---
    output reg [4:0] rs1_addr_out,
    output reg [4:0] rs2_addr_out,
    output reg [4:0] rd_addr_out,

    // --- CONTROL OUTPUTS ---
    output reg alu_src_out,
    output reg [1:0] alu_op_out,
    output reg [3:0] alu_funct_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg branch_out,
    output reg reg_write_out,
    output reg mem_to_reg_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Hardware reset: absolute zero.
            pc_out <= 32'b0;
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_addr_out <= 5'b0;
            rs2_addr_out <= 5'b0;
            rd_addr_out <= 5'b0;
            alu_src_out <= 1'b0;
            alu_funct_out <= 4'b0;
            alu_op_out <= 2'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            branch_out <= 1'b0;
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end
        else if (flush) begin
            // Tactical flush: Zero out control signals to create a bubble.
            // The data wires don't actually matter if RegWrite and MemWrite are 0.
            pc_out <= 32'b0;
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_addr_out <= 5'b0;
            rs2_addr_out <= 5'b0;
            rd_addr_out <= 5'b0;
            alu_src_out <= 1'b0;
            alu_funct_out <= 4'b0;
            alu_op_out <= 2'b0;

            
            // CRITICAL: Disable all writes
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            branch_out <= 1'b0;
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end
        else begin
            // Normal operation: latch everything.
            pc_out <= pc_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out <= imm_in;
            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            alu_src_out <= alu_src_in;
            alu_funct_out <= alu_funct_in;
            alu_op_out <= alu_op_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            branch_out <= branch_in;
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end

endmodule