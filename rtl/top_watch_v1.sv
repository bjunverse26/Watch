`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/24
// Design Name: 
// Module Name: top_watch
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

module top_watch #(
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

    one_sec_gen #(
        .P_COUNT_BIT(P_COUNT_BIT)
    ) u_one_sec_gen (
        .clk(clk),
        .reset(reset),
        .i_freq(i_freq),
        .i_run_en(i_run_en),
        .o_sec_tick(w_sec_tick)
    );

    logic [6-1:0] r_min;
    logic [12-1:0] r_hour;

    logic sec_tick; 
    assign sec_tick = o_sec == 60 - 1;
    logic min_tick;
    assign min_tick = o_min == 60 - 1;
    logic hour_tick;
    assign hour_tick = o_hour == 24 - 1;

    always_ff @(posedge clk) begin
        if (reset) begin
            o_sec <= '0;
        end else if (w_sec_tick) begin
            if (sec_tick) begin
                o_sec <= '0;
            end else begin
                o_sec <= o_sec + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            o_min <= '0;
            r_min <= '0;
        end else if (w_sec_tick) begin
            if (min_tick && sec_tick) begin
                o_min <= '0;
                r_min <= '0;
            end else if (r_min == 60 - 1) begin
                o_min <= o_min + 1;
                r_min <= '0;
            end else begin
                r_min <= r_min + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            o_hour <= '0;
            r_hour <= '0;
        end else if (w_sec_tick) begin
            if (hour_tick && min_tick && sec_tick) begin
                o_hour <= '0;
                r_hour <= '0;
            end else if (r_hour == 60*60 - 1) begin
                o_hour <= o_hour + 1;
                r_hour <= '0;
            end else begin
                r_hour <= r_hour + 1;
            end
        end
    end

endmodule