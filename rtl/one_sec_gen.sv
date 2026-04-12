`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: BeomJun
// 
// Create Date: 2026/03/24
// Design Name: 
// Module Name: one_sec_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: To generate one sec
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module one_sec_gen #(
    parameter                           P_COUNT_BIT = 30
) (
    input logic                         clk,
    input logic                         reset,

    input logic [P_COUNT_BIT-1:0]       i_freq,
    input logic                         i_run_en,

    output logic                        o_sec_tick
);

    logic [P_COUNT_BIT-1:0] r_counter;

    always_ff @(posedge clk) begin
        if (reset) begin
            r_counter <= '0;
            o_sec_tick <= '0;
        end else if (i_run_en) begin
            if (r_counter == i_freq - 1) begin
                r_counter <= '0;
                o_sec_tick <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                o_sec_tick <= 1'b0;
            end
        end else begin
            o_sec_tick <= 1'b0;
        end
    end

endmodule