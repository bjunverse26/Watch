`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: BeomJun
// 
// Create Date: 2026/03/26
// Design Name: 
// Module Name: tb_one_sec_gen
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


module tb_one_sec_gen;

    localparam P_COUNT_BIT = 30;
    
    logic                   clk;
    logic                   reset;
    logic [P_COUNT_BIT-1:0] i_freq;
    logic                   i_run_en;
    
    logic                   o_sec_tick;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    one_sec_gen #(
        .P_COUNT_BIT(P_COUNT_BIT)
    ) u_one_sec_gen (
        .clk(clk),
        .reset(reset),
        .i_freq(i_freq),
        .i_run_en(i_run_en),
        .o_sec_tick(o_sec_tick)
    );

    initial begin
        $display("Initialize value [%d]", $time);
        reset <= 0;
        clk <= 0;
        i_run_en <= 0;

        $display("Reset! [%d]", $time);
        #100
        reset <= 1;
        #10
        reset <= 0;
        i_run_en <= 1;
        i_freq <= 100;
        
        @(posedge clk)
        $display("Start! [%d]", $time);
        #10000
        i_run_en <= 0;
        #30
        $display("Finish! [%d]", $time);
        
        $finish;
    end

endmodule