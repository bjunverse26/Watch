`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/25
// Design Name: 
// Module Name: top_watch_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_watch_v2 #(
    parameter P_COUNT_BIT = 30,
    parameter P_SEC_BIT = 6,
    parameter P_MIN_BIT = 6,
    parameter P_HOUR_BIT = 5
) (
    input logic                     clk,
    input logic                     reset,

    input logic [P_COUNT_BIT-1:0]   i_freq,
    input logic                     i_run_en,
    
    output logic [P_SEC_BIT-1:0]    o_sec,
    output logic [P_MIN_BIT-1:0]    o_min,
    output logic [P_HOUR_BIT-1:0]   o_hour
);

    logic w_sec_tick;
    logic w_min_tick;
    logic w_hour_tick;

    one_sec_gen #(
        .P_COUNT_BIT(P_COUNT_BIT)
    ) u_one_sec_gen (
        .clk(clk),
        .reset(reset),
        .i_freq(i_freq),
        .i_run_en(i_run_en),
        .o_sec_tick(w_sec_tick)
    );

    tick_gen #(
        .INPUT_TICK(60),
        .TICK_BIT(P_SEC_BIT),
        .DELAY(2)
    ) u_sec_tick_gen (
        .clk(clk),
        .reset(reset),
        .i_run_en(i_run_en),
        .i_tick(w_sec_tick),
        .o_tick(w_min_tick),
        .o_val(o_sec)
    );

    tick_gen #(
        .INPUT_TICK(60),
        .TICK_BIT(P_MIN_BIT),
        .DELAY(1)
    ) u_min_tick_gen (
        .clk(clk),
        .reset(reset),
        .i_run_en(i_run_en),
        .i_tick(w_min_tick),
        .o_tick(w_hour_tick),
        .o_val(o_min)
    );

    tick_gen #(
        .INPUT_TICK(24),
        .TICK_BIT(P_MIN_BIT),
        .DELAY(0)
    ) u_hour_tick_gen (
        .clk(clk),
        .reset(reset),
        .i_run_en(i_run_en),
        .i_tick(w_hour_tick),
        .o_tick(),
        .o_val(o_hour)
    );


endmodule