`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2023 07:20:57 PM
// Design Name: 
// Module Name: Testbench
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

module Testbench();
    reg clk = 1,clrn = 1;

    wire [31:0] pc;
    wire [31:0] aluout;
    wire [31:0] memout;
    sccomputer Testbench(clk,clrn,pc,aluout,memout);
   
    always
    #10 clk = ~clk;
    
    initial begin
        #20 clrn = 0;
    end
endmodule
