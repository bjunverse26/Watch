`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/25
// Design Name: 
// Module Name: tick_gen
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

module tick_gen #(
    parameter INPUT_TICK = 60,
    parameter TICK_BIT = 6,
    parameter DELAY = 0
    ) (
    input logic                     clk,
    input logic                     reset,

    input logic                     i_run_en,
    input logic                     i_tick,

    output logic                    o_tick,
    output logic [TICK_BIT-1:0]     o_val
);

    logic [TICK_BIT-1:0] r_val;

    always_ff @(posedge clk) begin
        if (reset) begin
            r_val <= '0;
            o_tick <= 1'b0;
        end else if (i_run_en && i_tick) begin
            if (r_val == INPUT_TICK - 1) begin
                r_val <= '0;
                o_tick <= 1'b1;
            end else begin
                r_val <= r_val + 1;
            end
        end else begin
            o_tick <= 1'b0;
        end
    end

    genvar gi;

    generate
        if (DELAY == 0) begin
            assign o_val = r_val;
        end else if (DELAY == 1) begin
            logic [TICK_BIT-1:0] r_val_d;
            always_ff @(posedge clk) begin
                r_val_d <= r_val;
            end
            assign o_val = r_val_d;
        end else begin
            logic [TICK_BIT-1:0] r_val_d [DELAY-1:0];
            always_ff @(posedge clk) begin
                r_val_d[0] <= r_val;
            end
            for(gi = 1; gi < DELAY; gi = gi + 1) begin : gen_delay
                always_ff @(posedge clk) begin
                    r_val_d[gi] <= r_val_d[gi-1];
                end
            end
            assign o_val = r_val_d[DELAY-1];
        end
    endgenerate

endmodule