//==============================================================================
// File Name   : TopWatchV1.sv
// Project     : Watch
// Author      : Beomjun Kim
// Description : First watch implementation with direct second, minute, and hour
//               counters.
// Notes       : This version is kept as a readable reference beside the reusable
//               TickGen-based TopWatchV2 implementation.
//==============================================================================

`timescale 1ns / 1ps

module TopWatchV1 #(
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
    logic w_sec_rollover;
    logic w_min_rollover;
    logic w_hour_rollover;

    logic [MIN_WIDTH-1:0]   r_min_shadow;
    logic [11:0]            r_hour_shadow;

    assign w_sec_rollover  = (o_sec == 60 - 1);
    assign w_min_rollover  = (o_min == 60 - 1);
    assign w_hour_rollover = (o_hour == 24 - 1);

    OneSecGen #(
        .COUNT_WIDTH (COUNT_WIDTH)
    ) u_one_sec_gen (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_freq     (i_freq),
        .i_run_en   (i_run_en),
        .o_sec_tick (w_sec_tick)
    );

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            o_sec <= '0;
        end else if (w_sec_tick) begin
            if (w_sec_rollover) begin
                o_sec <= '0;
            end else begin
                o_sec <= o_sec + 1'b1;
            end
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            o_min        <= '0;
            r_min_shadow <= '0;
        end else if (w_sec_tick) begin
            if (w_min_rollover && w_sec_rollover) begin
                o_min        <= '0;
                r_min_shadow <= '0;
            end else if (r_min_shadow == 60 - 1) begin
                o_min        <= o_min + 1'b1;
                r_min_shadow <= '0;
            end else begin
                r_min_shadow <= r_min_shadow + 1'b1;
            end
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            o_hour        <= '0;
            r_hour_shadow <= '0;
        end else if (w_sec_tick) begin
            if (w_hour_rollover && w_min_rollover && w_sec_rollover) begin
                o_hour        <= '0;
                r_hour_shadow <= '0;
            end else if (r_hour_shadow == 60 * 60 - 1) begin
                o_hour        <= o_hour + 1'b1;
                r_hour_shadow <= '0;
            end else begin
                r_hour_shadow <= r_hour_shadow + 1'b1;
            end
        end
    end

endmodule
