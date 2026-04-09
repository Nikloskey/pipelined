module imem(
            input clk,
            input  [31:0] a,
            input stall,
            output reg [31:0] rd);
    reg [31:0] RAM[0:63];
    initial $readmemh("program.hex", RAM);
    // assign rd = RAM[a[7:2]];
    always @(posedge clk) begin
        if (!stall) begin
            rd <= RAM[a[7:2]];
        end
    end
endmodule