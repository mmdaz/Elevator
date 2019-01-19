`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:26:40 01/04/2019 
// Design Name: 
// Module Name:    comparator 
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
module comparator(comp1, comp2, result_of_comparison);

parameter compare_width = 4;
input [compare_width:1]comp1, comp2;
output result_of_comparison;

compare #(.W(compare_width)) DUT(
    .a(comp1),
    .b(comp2),
    .result(result_of_comparison));
endmodule

