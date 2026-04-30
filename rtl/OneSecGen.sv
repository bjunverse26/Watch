//==============================================================================
// File Name   : OneSecGen.sv
// Project     : Watch
// Author      : Beomjun Kim
// Description : Programmable one-second tick generator.
// Notes       : The divisor is provided through i_freq so simulation can use a
//               small value while hardware can use the board clock frequency.
//==============================================================================

`timescale 1ns / 1ps

module OneSecGen #(
    parameter int COUNT_WIDTH = 30
) (
    input  logic                     i_clk,
    input  logic                     i_reset,
    input  logic [COUNT_WIDTH-1:0]   i_freq,
    input  logic                     i_run_en,
    output logic                     o_sec_tick
);

    logic [COUNT_WIDTH-1:0] r_counter;

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            r_counter  <= '0;
            o_sec_tick <= 1'b0;
        end else if (i_run_en) begin
            if (r_counter == i_freq - 1'b1) begin
                r_counter  <= '0;
                o_sec_tick <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1'b1;
                o_sec_tick <= 1'b0;
            end
        end else begin
            o_sec_tick <= 1'b0;
        end
    end

endmodule
