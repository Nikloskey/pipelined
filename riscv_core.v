`include "pc_reg.v"
`include "imem.v"
`include "IF_ID_reg.v"
`include "control_unit.v"
`include "regfile.v"
`include "imm_gen.v"
`include "hazard_detection_unit.v"
`include "ID_EX_reg.v"
`include "alu_control.v"
`include "main_alu.v"
`include "forwarding_unit.v"
`include "EX_MEM_reg.v"
`include "dmem.v"
`include "MEM_WB_reg.v"

module riscv_core (
    input wire clk,
    input wire rst
);

    // Stubs
    wire        pc_src;  
    wire [31:0] branch_target; 
    wire        if_stall;  
    wire        if_id_flush;  
    wire        id_ex_flush;

    // IF Stage
    wire [31:0] if_pc_current;
    wire [31:0] if_pc_plus_4;
    wire [31:0] if_pc_next;
    wire [31:0] if_instr;

    // ID Stage
    wire [31:0] id_pc;
    wire [31:0] id_instr;

    // MEM Stage
    wire [31:0] mem_alu_result, mem_rs2_data;
    wire [4:0]  mem_rd_addr;
    wire        mem_read_ctrl, mem_write_ctrl, mem_reg_write, mem_to_reg;

    // PC logic
    assign if_pc_next   = (pc_src) ? branch_target : if_pc_plus_4;
    assign if_pc_plus_4 = if_pc_current + 32'd4;
    pc_reg pc_register (
        .clk     (clk),
        .rst     (rst),
        .stall   (if_stall),
        .pc_next (if_pc_next),
        .pc      (if_pc_current)
    );

    imem instruction_memory (
        .a  (if_pc_current),
        .rd (if_instr)
    );

    // IF/ID pipeline register
    IF_ID_reg if_id_wall (
        .clk       (clk),
        .rst       (rst),
        .flush     (if_id_flush), 
        .stall     (if_stall),    
        
        .pc_in     (if_pc_current),
        .instr_in  (if_instr),
        
        .pc_out    (id_pc),
        .instr_out (id_instr)
    );

    // ID Stage - extract fields
    wire [6:0] id_opcode    = id_instr[6:0];
    wire [4:0] id_rd_addr   = id_instr[11:7];
    wire [4:0] id_rs1_addr  = id_instr[19:15];
    wire [4:0] id_rs2_addr  = id_instr[24:20];
    wire [3:0] id_alu_funct = {id_instr[30], id_instr[14:12]}; 

    // WB Stubs
    wire        wb_reg_write;
    wire [4:0]  wb_rd_addr;
    wire [31:0] wb_write_data;

    wire id_branch, id_mem_read, id_mem_to_reg, id_mem_write, id_alu_src, id_reg_write;
    wire [1:0] id_alu_op;

    control_unit main_ctrl (
        .opcode     (id_opcode),
        .alu_src    (id_alu_src),
        .alu_op     (id_alu_op),
        .mem_read   (id_mem_read),
        .mem_write  (id_mem_write),
        .branch     (id_branch),
        .reg_write  (id_reg_write),
        .mem_to_reg (id_mem_to_reg)
    );

    // --- Register File ---
    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;

    regfile register_file (
        .clk        (clk),
        .we         (wb_reg_write),
        .rs1        (id_rs1_addr),
        .rs2        (id_rs2_addr),
        .rd         (wb_rd_addr),
        .write_data (wb_write_data),
        .rd1        (id_rs1_data),
        .rd2        (id_rs2_data)
    );

    wire [31:0] id_imm;
    
    imm_gen immediate_generator (
        .instr (id_instr),
        .imm   (id_imm)
    );

    hazard_detection_unit hdu (
        .id_rs1      (id_rs1_addr),
        .id_rs2      (id_rs2_addr),
        .ex_rd       (ex_rd_addr),
        .ex_mem_read (ex_mem_read),
        .stall       (if_stall)
    );

    // ID/EX pipeline register
    wire [31:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm;
    wire [4:0]  ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    wire        ex_alu_src, ex_mem_read, ex_mem_write, ex_branch, ex_reg_write, ex_mem_to_reg;
    wire [1:0]  ex_alu_op;
    wire [3:0]  ex_alu_funct;

    ID_EX_reg id_ex_wall (
        .clk            (clk),
        .rst            (rst),
        .flush          (id_ex_flush),
        
        // --- Datapath In ---
        .pc_in          (id_pc),
        .rs1_data_in    (id_rs1_data),
        .rs2_data_in    (id_rs2_data),
        .imm_in         (id_imm),
        
        .rs1_addr_in    (id_rs1_addr),
        .rs2_addr_in    (id_rs2_addr),
        .rd_addr_in     (id_rd_addr),
        .alu_src_in     (id_alu_src),
        .alu_funct_in   (id_alu_funct),
        .alu_op_in      (id_alu_op),
        .mem_read_in    (id_mem_read),
        .mem_write_in   (id_mem_write),
        .branch_in      (id_branch),
        .reg_write_in   (id_reg_write),
        .mem_to_reg_in  (id_mem_to_reg),
        
        .pc_out         (ex_pc),
        .rs1_data_out   (ex_rs1_data),
        .rs2_data_out   (ex_rs2_data),
        .imm_out        (ex_imm),
        .rs1_addr_out   (ex_rs1_addr),
        .rs2_addr_out   (ex_rs2_addr),
        .rd_addr_out    (ex_rd_addr),
        .alu_src_out    (ex_alu_src),
        .alu_op_out     (ex_alu_op),
        .alu_funct_out  (ex_alu_funct),
        .mem_read_out   (ex_mem_read),
        .mem_write_out  (ex_mem_write),
        .branch_out     (ex_branch),
        .reg_write_out  (ex_reg_write),
        .mem_to_reg_out (ex_mem_to_reg)
    );

    // Forwarding Unit
    wire [1:0] forward_a_ctrl;
    wire [1:0] forward_b_ctrl;

    forwarding_unit fwd_unit (
        .ex_rs1        (ex_rs1_addr),
        .ex_rs2        (ex_rs2_addr),
        .mem_rd        (mem_rd_addr),
        .mem_reg_write (mem_reg_write),
        .wb_rd         (wb_rd_addr),
        .wb_reg_write  (wb_reg_write),
        .forward_a     (forward_a_ctrl),
        .forward_b     (forward_b_ctrl)
    );

    // Forwarding mux for ALU operand A
    wire [31:0] forward_a_data;
    assign forward_a_data = (forward_a_ctrl == 2'b10) ? mem_alu_result :
                            (forward_a_ctrl == 2'b01) ? wb_write_data  : 
                            ex_rs1_data;

    // Forwarding mux for ALU operand B
    wire [31:0] forward_b_data;
    assign forward_b_data = (forward_b_ctrl == 2'b10) ? mem_alu_result :
                            (forward_b_ctrl == 2'b01) ? wb_write_data  : 
                            ex_rs2_data;

    // ALU Control
    wire [3:0] alu_cmd;
    
    alu_control alu_ctrl_unit (
        .alu_op    (ex_alu_op),
        .alu_funct (ex_alu_funct),
        .alu_ctrl  (alu_cmd)
    );

    // ALUSrc mux: select between register or immediate
    wire [31:0] alu_operand_b;
    assign alu_operand_b = (ex_alu_src) ? ex_imm : forward_b_data;

    // Main ALU
    wire [31:0] ex_alu_result;
    wire        ex_zero_flag;

    alu main_alu (
        .a        (forward_a_data),
        .b        (alu_operand_b),
        .alu_ctrl (alu_cmd),
        .result   (ex_alu_result),
        .zero     (ex_zero_flag)
    );

    // Branch target calculation
    wire [31:0] ex_branch_target;
    assign ex_branch_target = ex_pc + ex_imm;

    // Branch feedback to IF stage
    assign pc_src = ex_branch & ex_zero_flag;
    assign branch_target = ex_branch_target;

    // Flush control
    assign if_id_flush = pc_src; 
    assign id_ex_flush = pc_src | if_stall;

    // EX/MEM pipeline register
    EX_MEM_reg ex_mem_wall (
        .clk            (clk),
        .rst            (rst),
        
        .alu_result_in  (ex_alu_result),
        .rs2_data_in    (forward_b_data),
        .rd_addr_in     (ex_rd_addr),
        .mem_read_in    (ex_mem_read),
        .mem_write_in   (ex_mem_write),
        .reg_write_in   (ex_reg_write),
        .mem_to_reg_in  (ex_mem_to_reg),
        .alu_result_out (mem_alu_result),
        .rs2_data_out   (mem_rs2_data),
        .rd_addr_out    (mem_rd_addr),
        .mem_read_out   (mem_read_ctrl),
        .mem_write_out  (mem_write_ctrl),
        .reg_write_out  (mem_reg_write),
        .mem_to_reg_out (mem_to_reg)
    );

    // Memory stage
    wire [31:0] mem_read_data;
    dmem data_memory (
        .clk       (clk),
        .mem_read  (mem_read_ctrl),
        .mem_write (mem_write_ctrl),
        .a         (mem_alu_result), // Address from ALU
        .wd        (mem_rs2_data),   // Data from rs2
        .rd        (mem_read_data)
    );

    // MEM/WB pipeline register
    wire [31:0] wb_alu_result;
    wire [31:0] wb_dmem_data;
    wire        wb_mem_to_reg;
    MEM_WB_reg mem_wb_wall (
        .clk            (clk),
        .rst            (rst),
        
        .alu_result_in  (mem_alu_result),
        .dmem_data_in   (mem_read_data),
        .rd_addr_in     (mem_rd_addr),
        .reg_write_in   (mem_reg_write),
        .mem_to_reg_in  (mem_to_reg),
        .alu_result_out (wb_alu_result),
        .dmem_data_out  (wb_dmem_data),
        .rd_addr_out    (wb_rd_addr),
        .reg_write_out  (wb_reg_write),
        .mem_to_reg_out (wb_mem_to_reg)
    );

    // Write-back: select between ALU result or memory data
    assign wb_write_data = (wb_mem_to_reg) ? wb_dmem_data : wb_alu_result;

endmodule