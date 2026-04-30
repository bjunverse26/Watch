//==============================================================================
// File Name   : TickGen.sv
// Project     : Watch
// Author      : Beomjun Kim
// Description : Reusable modulo-N counter with carry tick output.
// Notes       : DELAY can align the visible count with downstream carry timing
//               without changing the counter logic itself.
//==============================================================================

`timescale 1ns / 1ps

module TickGen #(
    parameter int INPUT_TICK = 60,
    parameter int TICK_WIDTH = 6,
    parameter int DELAY      = 0
) (
    input  logic                    i_clk,
    input  logic                    i_reset,
    input  logic                    i_run_en,
    input  logic                    i_tick,
    output logic                    o_tick,
    output logic [TICK_WIDTH-1:0]   o_val
);

    logic [TICK_WIDTH-1:0] r_val;

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            r_val  <= '0;
            o_tick <= 1'b0;
        end else if (i_run_en && i_tick) begin
            if (r_val == INPUT_TICK - 1) begin
                r_val  <= '0;
                o_tick <= 1'b1;
            end else begin
                r_val  <= r_val + 1'b1;
                o_tick <= 1'b0;
            end
        end else begin
            o_tick <= 1'b0;
        end
    end

    genvar gi;

    generate
        if (DELAY == 0) begin : gen_no_delay
            assign o_val = r_val;
        end else if (DELAY == 1) begin : gen_one_cycle_delay
            logic [TICK_WIDTH-1:0] r_val_d;

            always_ff @(posedge i_clk) begin
                if (i_reset) begin
                    r_val_d <= '0;
                end else begin
                    r_val_d <= r_val;
                end
            end

            assign o_val = r_val_d;
        end else begin : gen_multi_cycle_delay
            logic [TICK_WIDTH-1:0] r_val_d [0:DELAY-1];

            always_ff @(posedge i_clk) begin
                if (i_reset) begin
                    r_val_d[0] <= '0;
                end else begin
                    r_val_d[0] <= r_val;
                end
            end

            for (gi = 1; gi < DELAY; gi = gi + 1) begin : gen_delay
                always_ff @(posedge i_clk) begin
                    if (i_reset) begin
                        r_val_d[gi] <= '0;
                    end else begin
                        r_val_d[gi] <= r_val_d[gi-1];
                    end
                end
            end

            assign o_val = r_val_d[DELAY-1];
        end
    endgenerate

endmodule
