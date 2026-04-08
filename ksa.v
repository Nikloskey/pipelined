module black (
    input g_high, g_low, p_high, p_low,
    output g_merged, p_merged
);

    assign g_merged = g_high | (p_high & g_low);
    assign p_merged = p_high & p_low;

endmodule

module grey(
    input g_high, g_low, p_high,
    output g_merged
);

    assign g_merged = g_high | (p_high & g_low);

endmodule



module ks_adder_param #(
    parameter WIDTH = 16,
    parameter LEVELS = 4
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input cin,
    output [WIDTH-1:0] sum,
    output cout
);

    wire [WIDTH-1:0] g [LEVELS:0];
    wire [WIDTH-1:0] p [LEVELS-1:0];

    assign g[0] = a & b;
    assign p[0] = a ^ b;

    genvar l, i;
    generate
        for (l = 1; l <= LEVELS; l = l + 1) begin : level_loop
            localparam integer dist = 1 << (l - 1);
            if (l == LEVELS) begin
                for (i = 0; i < WIDTH; i = i + 1) begin : bit_loop
                    if (i - dist < -1) begin
                        assign g[l][i] = g[l-1][i];
                    end else if (i-dist==-1) begin
                        grey m0 (
                            .g_high(g[l-1][i]), 
                            .g_low(cin), 
                            .p_high(p[l-1][i]), 
                            .g_merged(g[l][i])
                        );
                    end
                    else begin
                        grey m1 (
                            .g_high(g[l-1][i]), 
                            .g_low(g[l-1][i-dist]), 
                            .p_high(p[l-1][i]),  
                            .g_merged(g[l][i])
                        );
                    end
                end
            end else begin
                for (i = 0; i < WIDTH; i = i + 1) begin : bit_loop
                    if (i - dist < -1) begin
                        assign g[l][i] = g[l-1][i];
                        assign p[l][i] = p[l-1][i];
                    end else if (i-dist==-1) begin
                        black m0 (
                            .g_high(g[l-1][i]), 
                            .g_low(cin), 
                            .p_high(p[l-1][i]), 
                            .p_low(1'b0), 
                            .g_merged(g[l][i]), 
                            .p_merged(p[l][i])
                        );
                    end
                    else begin
                        black m1 (
                            .g_high(g[l-1][i]), 
                            .g_low(g[l-1][i-dist]), 
                            .p_high(p[l-1][i]), 
                            .p_low(p[l-1][i-dist]), 
                            .g_merged(g[l][i]), 
                            .p_merged(p[l][i])
                        );
                    end
                end
            end
        end
    endgenerate

    wire [WIDTH:0] carry;
    assign carry[0] = cin;
    
    genvar k;
    generate
        for (k = 0; k < WIDTH; k = k + 1) begin : carry_gen
            assign carry[k+1] = g[LEVELS][k];
        end
    endgenerate

    assign sum = p[0] ^ carry[WIDTH-1:0];
    assign cout = carry[WIDTH];

endmodule