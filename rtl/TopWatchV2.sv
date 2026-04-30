//==============================================================================
// File Name   : TopWatchV2.sv
// Project     : Watch
// Author      : Beomjun Kim
// Description : Modular 24-hour watch top using OneSecGen and cascaded TickGen
//               counters.
// Notes       : Second, minute, and hour counters are implemented by the same
//               reusable modulo counter to keep rollover behavior consistent.
//==============================================================================

`timescale 1ns / 1ps

module TopWatchV2 #(
    parameter int COUNT_WIDTH = 30,
    parameter int SEC_WIDTH   = 6,
    parameter int MIN_WIDTH   = 6,
    parameter int HOUR_WIDTH  = 5
) (
    input  logic                    i_clk,
    input  logic                    i_reset,
    input  logic [COUNT_WIDTH-1:0]  i_freq,
    input  logic                    i_run_en,
    output logic [SEC_WIDTH-1:0]    o_sec,
    output logic [MIN_WIDTH-1:0]    o_min,
    output logic [HOUR_WIDTH-1:0]   o_hour
);

    logic w_sec_tick;
    logic w_min_tick;
    logic w_hour_tick;

    OneSecGen #(
        .COUNT_WIDTH (COUNT_WIDTH)
    ) u_one_sec_gen (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_freq     (i_freq),
        .i_run_en   (i_run_en),
        .o_sec_tick (w_sec_tick)
    );

    TickGen #(
        .INPUT_TICK (60),
        .TICK_WIDTH (SEC_WIDTH),
        .DELAY      (2)
    ) u_sec_tick_gen (
        .i_clk    (i_clk),
        .i_reset  (i_reset),
        .i_run_en (i_run_en),
        .i_tick   (w_sec_tick),
        .o_tick   (w_min_tick),
        .o_val    (o_sec)
    );

    TickGen #(
        .INPUT_TICK (60),
        .TICK_WIDTH (MIN_WIDTH),
        .DELAY      (1)
    ) u_min_tick_gen (
        .i_clk    (i_clk),
        .i_reset  (i_reset),
        .i_run_en (i_run_en),
        .i_tick   (w_min_tick),
        .o_tick   (w_hour_tick),
        .o_val    (o_min)
    );

    TickGen #(
        .INPUT_TICK (24),
        .TICK_WIDTH (HOUR_WIDTH),
        .DELAY      (0)
    ) u_hour_tick_gen (
        .i_clk    (i_clk),
        .i_reset  (i_reset),
        .i_run_en (i_run_en),
        .i_tick   (w_hour_tick),
        .o_tick   (),
        .o_val    (o_hour)
    );

endmodule
