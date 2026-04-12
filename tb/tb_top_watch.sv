`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/27
// Design Name: 
// Module Name: tb_top_watch
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

module tb_top_watch;

    localparam P_COUNT_BIT = 30;
    localparam P_SEC_BIT = 6;
    localparam P_MIN_BIT = 6;
    localparam P_HOUR_BIT = 5;

    logic                       clk;
    logic                       reset;

    logic [P_COUNT_BIT-1:0]     i_freq;
    logic                       i_run_en;
    
    logic [P_SEC_BIT-1:0]       o_sec;
    logic [P_MIN_BIT-1:0]       o_min;
    logic [P_HOUR_BIT-1:0]      o_hour;

    top_watch_v2 #(
        .P_COUNT_BIT(P_COUNT_BIT),
        .P_SEC_BIT(P_SEC_BIT),
        .P_MIN_BIT(P_MIN_BIT),
        .P_HOUR_BIT(P_HOUR_BIT)
    ) dut (
        .clk(clk),
        .reset(reset),
        .i_freq(i_freq),
        .i_run_en(i_run_en),
        .o_sec(o_sec),
        .o_min(o_min),
        .o_hour(o_hour)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Initialize Value [%d]", $time);
        reset <= 0;
        i_run_en <= 0;
        #100
        $display("Reset! [%d]", $time);
        reset <= 1;
        #10
        reset <= 0;
        i_run_en <= 1;
        i_freq <= 10;

        @(posedge clk)
        $display("Start! [%d]", $time);
        #10000000
        i_run_en <= 0;
        #30
        $display("Finish! [%d]", $time);
        
        $finish;
    end

endmodule