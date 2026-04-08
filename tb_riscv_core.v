`include "riscv_core.v"

`timescale 1ns / 1ns

module tb_riscv_core();

    // 1. Declare signals to drive the CPU
    reg clk;
    reg rst;

    // 2. Instantiate the Processor
    riscv_core uut (
        .clk(clk),
        .rst(rst)
    );

    // 3. Generate the Clock (10ns period = 100 MHz)
    always begin
        #5 clk = ~clk; 
    end

    // 4. Drive the Simulation
    initial begin
        $dumpfile("pipeline_wave.vcd");
        $dumpvars(0, tb_riscv_core);

        clk = 0;
        rst = 1;

        // Hold reset high to clear the pipeline
        #20;
        rst = 0;

        // Run for 200 nanoseconds (20 clock cycles)
        #1000;

        $display("Simulation Complete.");
        $finish;
    end

    // ==========================================
    // PIPELINE SNOOPER (Console Output)
    // ==========================================
    always @(negedge clk) begin
        if (!rst) begin
            // 1. Snoop the Memory Stage
            if (uut.mem_write_ctrl) begin
                $display("Time: %0t | [MEM] -> Wrote Data %0d to RAM Address 0x%0h", 
                         $time, uut.mem_rs2_data, uut.mem_alu_result);
            end

            // 2. Snoop the Write-Back Stage
            if (uut.wb_reg_write && uut.wb_rd_addr != 5'b0) begin
                $display("Time: %0t | [WB]  -> Wrote Data %0d to Register x%0d", 
                         $time, uut.wb_write_data, uut.wb_rd_addr);
            end
        end
    end

endmodule