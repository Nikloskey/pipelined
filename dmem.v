module dmem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] a,
    input  wire [31:0] wd,
    output reg [31:0] rd
);
    reg [31:0] RAM[0:63];
    
    // assign rd = (mem_read) ? RAM[a[7:2]] : 32'b0;

    always @(posedge clk) begin
        if (mem_write) begin
            RAM[a[7:2]] <= wd;
        end
        else begin
            if (mem_read) begin
                rd <= RAM[a[7:2]];
            end
            else begin
                rd <= 32'b0;
            end
        end
    end
endmodule