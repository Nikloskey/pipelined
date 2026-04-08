`include "riscv_core.v"

`timescale 1ns / 1ns

module tb_riscv_core();

    reg clk;
    reg rst;

    riscv_core uut (
        .clk(clk),
        .rst(rst)
    );

    // Generate 100 MHz clock
    always begin
        #5 clk = ~clk; 
    end

    initial begin
        $dumpfile("pipeline_wave.vcd");
        $dumpvars(0, tb_riscv_core);

        clk = 0;
        rst = 1;

        #20 rst = 0;
        #1000;

        $display("Simulation Complete.");
        $finish;
    end

    // Pipeline monitor
    always @(negedge clk) begin
        if (!rst) begin
            if (uut.mem_write_ctrl) begin
                $display("Time: %0t | [MEM] -> Wrote Data %0d to RAM Address 0x%0h", 
                         $time, uut.mem_rs2_data, uut.mem_alu_result);
            end
            if (uut.wb_reg_write && uut.wb_rd_addr != 5'b0) begin
                $display("Time: %0t | [WB]  -> Wrote Data %0d to Register x%0d", 
                         $time, uut.wb_write_data, uut.wb_rd_addr);
            end
        end
    end

endmodule