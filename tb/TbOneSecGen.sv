//==============================================================================
// File Name   : TbOneSecGen.sv
// Project     : Watch
// Author      : Beomjun Kim
// Description : Self-checking directed testbench for OneSecGen.
// Notes       : The test uses a small programmable divisor so tick timing can be
//               checked quickly without board-frequency simulation.
//==============================================================================

`timescale 1ns / 1ps

interface OneSecGenIf #(
    parameter int COUNT_WIDTH = 30
) (
    input logic i_clk
);
    logic                   i_reset;
    logic [COUNT_WIDTH-1:0] i_freq;
    logic                   i_run_en;
    logic                   o_sec_tick;
endinterface

module TbOneSecGen;

    localparam int COUNT_WIDTH = 30;
    localparam int CLK_PERIOD  = 10;
    localparam int TEST_FREQ   = 5;

    logic w_clk;
    int unsigned r_error_count;
    int unsigned r_tick_count;

    OneSecGenIf #(
        .COUNT_WIDTH (COUNT_WIDTH)
    ) dut_if (
        .i_clk (w_clk)
    );

    OneSecGen #(
        .COUNT_WIDTH (COUNT_WIDTH)
    ) u_dut (
        .i_clk      (dut_if.i_clk),
        .i_reset    (dut_if.i_reset),
        .i_freq     (dut_if.i_freq),
        .i_run_en   (dut_if.i_run_en),
        .o_sec_tick (dut_if.o_sec_tick)
    );

    initial begin
        w_clk = 1'b0;
        forever #(CLK_PERIOD / 2) w_clk = ~w_clk;
    end

    initial begin
        init_interface();
        apply_reset();
        run_tick_period_case();
        run_pause_case();
        report_summary();
    end

    task automatic init_interface();
        begin
            dut_if.i_reset  = 1'b0;
            dut_if.i_freq   = TEST_FREQ[COUNT_WIDTH-1:0];
            dut_if.i_run_en = 1'b0;
            r_error_count   = 0;
            r_tick_count    = 0;
        end
    endtask

    task automatic apply_reset();
        begin
            dut_if.i_reset = 1'b1;
            repeat (3) @(posedge w_clk);
            dut_if.i_reset = 1'b0;
            repeat (2) @(posedge w_clk);
        end
    endtask

    task automatic expect_no_tick(input int unsigned cycle_count);
        begin
            repeat (cycle_count) begin
                @(posedge w_clk);
                if (dut_if.o_sec_tick) begin
                    $display("[FAIL] Unexpected tick at time %0t", $time);
                    r_error_count++;
                end
            end
        end
    endtask

    task automatic wait_and_check_tick(input int unsigned expected_gap);
        int unsigned cycle_count;

        begin
            cycle_count = 0;
            while (!dut_if.o_sec_tick && (cycle_count < expected_gap + 2)) begin
                @(posedge w_clk);
                cycle_count++;
            end

            if (!dut_if.o_sec_tick || (cycle_count != expected_gap)) begin
                $display("[FAIL] Tick gap mismatch expected=%0d actual=%0d tick=%0b",
                         expected_gap,
                         cycle_count,
                         dut_if.o_sec_tick);
                r_error_count++;
            end else begin
                $display("[PASS] Tick observed after %0d cycles", cycle_count);
                r_tick_count++;
            end
        end
    endtask

    task automatic run_tick_period_case();
        begin
            dut_if.i_run_en = 1'b1;
            wait_and_check_tick(TEST_FREQ);
            wait_and_check_tick(TEST_FREQ);
            wait_and_check_tick(TEST_FREQ);
        end
    endtask

    task automatic run_pause_case();
        begin
            dut_if.i_run_en = 1'b0;
            expect_no_tick(TEST_FREQ * 2);
            dut_if.i_run_en = 1'b1;
            wait_and_check_tick(TEST_FREQ);
        end
    endtask

    task automatic report_summary();
        begin
            if ((r_error_count == 0) && (r_tick_count == 4)) begin
                $display("PASS: OneSecGen generated all expected ticks");
                $finish(0);
            end else begin
                $display("FAIL: error_count=%0d tick_count=%0d", r_error_count, r_tick_count);
                $finish(1);
            end
        end
    endtask

endmodule
