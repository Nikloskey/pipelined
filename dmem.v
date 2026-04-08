module dmem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] a,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] RAM[0:63];
    
    assign rd = (mem_read) ? RAM[a[7:2]] : 32'b0;

    always @(posedge clk) begin
        if (mem_write) begin
            RAM[a[7:2]] <= wd;
        end
    end
endmodule