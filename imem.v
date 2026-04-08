module imem(input  [31:0] a,
            output [31:0] rd);
    reg [31:0] RAM[0:63];
    initial $readmemh("program.hex", RAM); // Loads your code from a text file
    assign rd = RAM[a[7:2]]; // Word aligned access
endmodule