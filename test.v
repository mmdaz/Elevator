`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:34:07 01/04/2019
// Design Name:
// Module Name:    Test
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
module Test;
	reg [3:0] in;
	wire enable;
	reg clk,rst;
	wire cs,pass_rw,admin_rw,lock_rw,count_rw,ram_rst,admin_in,lock_in,admin_out,lock_out,result_of_comparison,rst_timer,direction;
	wire [11:0]addr,saved_username;
	wire [15:0] pass_in,pass_out,saved_password,comp1,comp2;
	wire [3:0] count_in,count_out,period,counter;
	wire [7:0] state,prev_state;
	
	
    parameter
            zero         = 4'b0000,
            one          = 4'b0001,
            two          = 4'b0010,
            three        = 4'b0011,
            four         = 4'b0100,
            five         = 4'b0101,
            six          = 4'b0110,
            seven        = 4'b0111,
            eight        = 4'b1000,
            nine         = 4'b1001,
            star         = 4'b1010,
            hash         = 4'b1011;

// manager manager_smpl(in,enable,
//				state,prev_state,saved_username,saved_password,
//				cs, pass_rw, admin_rw, lock_rw, count_rw,ram_rst,addr,pass_in,count_in,admin_in,lock_in,pass_out,count_out,admin_out,lock_out,
//				rst_timer,direction,period,
//				comp1,comp2,result_of_comparison,
//				counter,
//				,clk,rst);
				
				 manager smple(in,
				state,prev_state,saved_username,saved_password,
				cs, pass_rw, admin_rw, lock_rw, count_rw,ram_rst,addr,pass_in,count_in,admin_in,lock_in,pass_out,count_out,admin_out,lock_out,
				,clk,rst);

				
	initial 
		begin
			clk = 1'b0;
			repeat (300)
			#10 clk = ~clk;
	end 
	
   initial 
		begin
		  rst = 0;
		  #100
        rst = 1;
		  #20
        rst = 0;
        #20
        // First test check whether at first a random user exist or no
        in = star;
        #20
        in = zero;
        #15
        in = zero;
        #20
        in = two;
		  
        // End of test one we shall be in start state
        // Second test check whether the first user can use the Elevator
        #50
        in = star;
        #20
        in = zero;
        #20
        in = zero;
        #20
        in = one; // We have logged in
        #20
        in = star;
        #20
        in = hash;
        #20
        in = star;
        #20
        // sub test we try to log in with a wrong password
        in = zero;
        #20
        in = two;
        #20
        in = zero;
        #20
        in = three;
			
    end
	
endmodule
