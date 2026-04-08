module pc_reg (
    input wire clk, 
    input wire rst,
    input wire stall,         // ADDED: The brake pedal
    input wire [31:0] pc_next,
    output reg [31:0] pc      // CLEANED: Directly output the reg
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) 
            pc <= 32'b0;
        else if (stall)       // ADDED: If stalled, hold the current address
            pc <= pc;
        else 
            pc <= pc_next;    // Normal operation
    end

endmodule