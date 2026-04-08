module dmem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] a,      // Address
    input  wire [31:0] wd,     // Write Data
    output wire [31:0] rd      // Read Data
);
    // 64 words of Data Memory
    reg [31:0] RAM[0:63];
    
    // Read asynchronously (or you can make it synchronous depending on your FPGA target)
    // We truncate the address to 6 bits [7:2] because we have 64 words (2^6).
    assign rd = (mem_read) ? RAM[a[7:2]] : 32'b0;

    always @(posedge clk) begin
        if (mem_write) begin
            RAM[a[7:2]] <= wd;
        end
    end
endmodule