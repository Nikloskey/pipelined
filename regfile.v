module regfile (
    input  wire        clk,        // System clock
    input  wire        we,         // Renamed from we3
    input  wire [4:0]  rs1,        // Renamed from a1
    input  wire [4:0]  rs2,        // Renamed from a2
    input  wire [4:0]  rd,         // Renamed from a3
    input  wire [31:0] write_data, // Renamed from wd3
    output wire [31:0] rd1,        // Read Data 1
    output wire [31:0] rd2         // Read Data 2 
);

    // The Memory Array: 32 elements, each 32 bits wide
    reg [31:0] rf [31:0];

    // ==========================================
    // 1. SYNCHRONOUS WRITE PORT
    // ==========================================
    // Writing only happens exactly on the rising edge of the clock.
    always @(posedge clk) begin
        // The condition (rd != 5'b00000) strictly enforces the RISC-V rule 
        // that register x0 is immutable and cannot be overwritten.
        if (we && (rd != 5'b00000)) begin
            rf[rd] <= write_data;
        end
    end

    // ==========================================
    // 2. ASYNCHRONOUS READ PORTS
    // ==========================================
    // Reading is combinational. The moment the instruction decoder changes
    // rs1 or rs2, the output updates instantly so the ALU doesn't have to wait.
    
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : 
                 ((rs1 == rd) && we) ? write_data : 
                 rf[rs1];

    assign rd2 = (rs2 == 5'b0) ? 32'b0 : 
                 ((rs2 == rd) && we) ? write_data : 
                 rf[rs2];

endmodule