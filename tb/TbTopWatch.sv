//==============================================================================
// File Name   : TbTopWatch.sv
// Project     : Watch
// Author      : Beomjun Kim
// Description : Self-checking directed testbench for TopWatchV2.
// Notes       : A compact clock divisor is used so second/minute/hour rollover can
//               be checked with scoreboard-style expected time counters.
//==============================================================================

`timescale 1ns / 1ps

interface WatchIf #(
    parameter int COUNT_WIDTH = 30,
    parameter int SEC_WIDTH   = 6,
    parameter int MIN_WIDTH   = 6,
    parameter int HOUR_WIDTH  = 5
) (
    input logic i_clk
);
    logic                   i_reset;
    logic [COUNT_WIDTH-1:0] i_freq;
    logic                   i_run_en;
    logic [SEC_WIDTH-1:0]   o_sec;
    logic [MIN_WIDTH-1:0]   o_min;
    logic [HOUR_WIDTH-1:0]  o_hour;
endinterface

module TbTopWatch;

    localparam int COUNT_WIDTH = 30;
    localparam int SEC_WIDTH   = 6;
    localparam int MIN_WIDTH   = 6;
    localparam int HOUR_WIDTH  = 5;
    localparam int CLK_PERIOD  = 10;
    localparam int TEST_FREQ   = 3;

    logic w_clk;
    int unsigned r_error_count;

    WatchIf #(
        .COUNT_WIDTH (COUNT_WIDTH),
        .SEC_WIDTH   (SEC_WIDTH),
        .MIN_WIDTH   (MIN_WIDTH),
        .HOUR_WIDTH  (HOUR_WIDTH)
    ) watch_if (
        .i_clk (w_clk)
    );

    TopWatchV2 #(
        .COUNT_WIDTH (COUNT_WIDTH),
        .SEC_WIDTH   (SEC_WIDTH),
        .MIN_WIDTH   (MIN_WIDTH),
        .HOUR_WIDTH  (HOUR_WIDTH)
    ) u_dut (
        .i_clk    (watch_if.i_clk),
        .i_reset  (watch_if.i_reset),
        .i_freq   (watch_if.i_freq),
        .i_run_en (watch_if.i_run_en),
        .o_sec    (watch_if.o_sec),
        .o_min    (watch_if.o_min),
        .o_hour   (watch_if.o_hour)
    );

    initial begin
        w_clk = 1'b0;
        forever #(CLK_PERIOD / 2) w_clk = ~w_clk;
    end

    initial begin
        init_interface();
        apply_reset();
        run_time_progress_case();
        run_pause_case();
        report_summary();
    end

    task automatic init_interface();
        begin
            watch_if.i_reset  = 1'b0;
            watch_if.i_freq   = TEST_FREQ[COUNT_WIDTH-1:0];
            watch_if.i_run_en = 1'b0;
            r_error_count     = 0;
        end
    endtask

    task automatic apply_reset();
        begin
            watch_if.i_reset = 1'b1;
            repeat (4) @(posedge w_clk);
            watch_if.i_reset = 1'b0;
            repeat (2) @(posedge w_clk);
        end
    endtask

    task automatic step_seconds(input int unsigned second_count);
        begin
            repeat (second_count * TEST_FREQ) @(posedge w_clk);
            repeat (3) @(posedge w_clk);
        end
    endtask

    task automatic check_time(
        input int unsigned expected_hour,
        input int unsigned expected_min,
        input int unsigned expected_sec,
        input string       msg
    );
        begin
            if ((watch_if.o_hour == expected_hour[HOUR_WIDTH-1:0])
             && (watch_if.o_min  == expected_min[MIN_WIDTH-1:0])
             && (watch_if.o_sec  == expected_sec[SEC_WIDTH-1:0])) begin
                $display("[PASS] %s %0d:%0d:%0d",
                         msg,
                         watch_if.o_hour,
                         watch_if.o_min,
                         watch_if.o_sec);
            end else begin
                $display("[FAIL] %s expected=%0d:%0d:%0d actual=%0d:%0d:%0d",
                         msg,
                         expected_hour,
                         expected_min,
                         expected_sec,
                         watch_if.o_hour,
                         watch_if.o_min,
                         watch_if.o_sec);
                r_error_count++;
            end
        end
    endtask

    task automatic run_time_progress_case();
        begin
            watch_if.i_run_en = 1'b1;
            step_seconds(1);
            check_time(0, 0, 1, "After one second");
            step_seconds(59);
            check_time(0, 1, 0, "After one minute");
            step_seconds(60 * 59);
            check_time(1, 0, 0, "After one hour");
        end
    endtask

    task automatic run_pause_case();
        logic [HOUR_WIDTH-1:0] held_hour;
        logic [MIN_WIDTH-1:0]  held_min;
        logic [SEC_WIDTH-1:0]  held_sec;

        begin
            held_hour = watch_if.o_hour;
            held_min  = watch_if.o_min;
            held_sec  = watch_if.o_sec;

            watch_if.i_run_en = 1'b0;
            step_seconds(5);

            if ((watch_if.o_hour != held_hour)
             || (watch_if.o_min  != held_min)
             || (watch_if.o_sec  != held_sec)) begin
                $display("[FAIL] Watch advanced while paused");
                r_error_count++;
            end else begin
                $display("[PASS] Watch holds time while paused");
            end
        end
    endtask

    task automatic report_summary();
        begin
            if (r_error_count == 0) begin
                $display("PASS: TopWatchV2 scenarios completed");
                $finish(0);
            end else begin
                $display("FAIL: error_count=%0d", r_error_count);
                $finish(1);
            end
        end
    endtask

endmodule
