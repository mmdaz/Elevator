`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:26:05 01/04/2019 
// Design Name: 
// Module Name:    timer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module timer(clk,rst, direction,period);

input clk, rst, direction;
output [3:0] period;

counter DUT(
    .clk(clk),
    .rst(rst),
    .direction(direction),
    .count(period));
    
endmodule
