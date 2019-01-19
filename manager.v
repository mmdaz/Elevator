`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:28:50 12/26/2018
// Design Name:
// Module Name:    manager
// Project Name:  Elevator
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
module manager(in,
				state,prev_state,saved_username,saved_password,
				cs, pass_rw, admin_rw, lock_rw, count_rw,ram_rst,addr,pass_in,count_in,admin_in,lock_in,pass_out,count_out,admin_out,lock_out,
				,clk,rst);

	input clk,rst;
	input [3:0]in;
//   output reg enable;

	output reg [7:0] state;
	output reg [11:0] saved_username;
	output reg [15:0] saved_password;
	output reg [7:0] prev_state;


	parameter start 													= 8'b00000000,
				star_after_start										= 8'b00000001,// odd
				main_username_1										= 8'b00000010,
				main_username_2										= 8'b00000011,
				main_username_3										= 8'b00000100,
				check_main_username									= 8'b00000101,
				wait_for_star_after_main_username 				= 8'b00000110,
				star_after_main_username							= 8'b00001001,
				user_exists												= 8'b00001010,
				star_after_user_exist								= 8'b00001011,
				admin_password_1										= 8'b00001100,
				admin_password_2										= 8'b00001101,
				admin_password_3										= 8'b00001110,
				admin_password_4										= 8'b00001111,
				check_admin_password									= 8'b00010000,
				wait_for_star_after_admin_login					= 8'b00010001,
				wait_for_hash_after_admin_login 					= 8'b00010010,
				wait_again_for_star_after_admin_login			= 8'b00010011,
				get_second_username_1								= 8'b00010100,
				get_second_username_2								= 8'b00010101,
				get_second_username_3								= 8'b00010110,
				check_if_the_second_username_was_admin			= 8'b00010111,
				the_second_username_was_admin         			= 8'b00011000,
				the_second_username_was_not_admin				= 8'b00011001,
				getting_new_admin_username_1						= 8'b00011010,
				getting_new_admin_username_2						= 8'b00011011,
				getting_new_admin_username_3						= 8'b00011100,
				waiting_for_star_to_add								= 8'b00011101,
				checking_new_admin_username						= 8'b00011110,
				admin_changed_waiting_for_hash 					= 8'b00011111,
				admin_changed_waiting_for_another_hash 		= 8'b00100000,
				waiting_for_a_hash_to_remove						= 8'b00100001,

			//New username adding or locking out states
				getting_the_new_user_password_1					= 8'b00100010,
				getting_the_new_user_password_2					= 8'b00100011,
				getting_the_new_user_password_3					= 8'b00100100,
				getting_the_new_user_password_4					= 8'b00100101,
				waiting_for_a_star_to_add							= 8'b00100110,
				waiting_for_hash_to_add								= 8'b00100111,

			//Removing user states
				waiting_for_a_star_to_remove						= 8'b00101000,
				waiting_for_hash_to_remove							= 8'b00101001,

		// Admin operations ENDED
		// Typical user operations BEGINS
				waiting_for_star 										= 8'b00101010,
				waiting_for_star_after_hash						= 8'b00101011,
				getting_password_1 									= 8'b00101100,
				getting_password_2 									= 8'b00101101,
				getting_password_3 									= 8'b00101110,
				getting_password_4 									= 8'b00101111,
				check_password 										= 8'b00110000,
				locking_user											= 8'b00110001,
				getting_star_for_the_last_time					= 8'b00110010,
				getting_hash_for_the_last_time					= 8'b00110011,
				reset_saved_counter									= 8'b00110100,

				warming_ram_up                               = 8'b11111100,
				password_alarm											= 8'b11111101,
				waiting 													= 8'b11111110,
				alarm														= 8'b11111111;


	parameter star = 4'b1010,hash = 4'b1011;
	parameter valid_numbers  = 4'b1001;
	parameter max_username = 12'b000100101000,min_username = 12'b000000000000;
	parameter max_number_of_errors = 4'b0011;
	parameter waiting_time = 4'b0101;

	// RAM Component

	// RAM input and Ouputs
	output reg cs, pass_rw, admin_rw, lock_rw, count_rw,ram_rst;
	output reg [11:0] addr;
	output reg [15:0] pass_in;
	output reg [3:0] count_in;
	output reg admin_in, lock_in;
	output wire [15:0] pass_out;
	output wire [3:0] count_out;
	output wire admin_out, lock_out;

	ram RAM(clk, ram_rst, cs, pass_rw, admin_rw, lock_rw, count_rw,
                 addr, pass_in, count_in, admin_in, lock_in, pass_out,
					  count_out, admin_out, lock_out);

	// This timer is used to wait for 5 clock time
	reg rst_timer,direction;
	wire period;
	timer Timer(clk,rst_timer,direction,period);

	// The comparator gate
	reg comp1,comp2;
	wire result_of_comparison;
	comparator Comparator(comp1,comp2,result_of_comparison);

	reg [3:0] counter; // This is used to count number of times that user have had error in password input

	initial
		begin
			ram_rst = 1; // RAM reset
		end

	always @(posedge clk or posedge rst)
		begin
			if(rst)
				begin
					state = start;// We set the state to start
					// RAM is ready to work but we don't need it now
					ram_rst = 0;
					cs = 0;
				end
			else
				begin
					if(cs)
						begin
							if(state == check_main_username) begin
                                    $display("%b is lock_out",lock_out);
									if(lock_out == 0)state = user_exists;
									else state = start;// The username isn't exist so we should go to start state
								end
							else if(state == star_after_user_exist)
								begin
									if(admin_out) state = admin_password_1;
								end
							else if(state == check_admin_password)begin
								if(pass_out == saved_password)
									state = wait_for_star_after_admin_login;
								else
									state = waiting;
							end
							else if(state == check_if_the_second_username_was_admin) begin
								// We have two possibility
								// The username was admin's
								// The username was not admin's
								if(admin_out) state = the_second_username_was_admin;
								else state = the_second_username_was_not_admin;
							end

							else if(state == admin_changed_waiting_for_hash)begin
								if(in == hash) begin
									state = admin_changed_waiting_for_another_hash;
								end
							end

							// This is the final part of the adding user name
							else if(state == waiting_for_star_to_add)begin
								if(in == star) begin
									pass_rw = 0;
									state = waiting_for_hash_to_add;
								end
							end


							// This is the final part of the removing user name
							else if(state == waiting_for_hash_to_remove)begin
								if(in == hash)begin
									lock_rw = 0;
									lock_in = 0;
									state = start;
								end
							end
							else if(state == check_password) begin
								if(pass_out == saved_password)begin
									state = reset_saved_counter;
								end
								else begin
									if( (counter + count_out) < max_number_of_errors) begin
										counter = counter + 1;
										state = getting_password_1;
									end
									else begin // The user should be locked
										addr = saved_username;
										lock_in = 1;
                                        prev_state = locking_user;
                                        state = warming_ram_up;
									end
								end
						end
							else if(state == reset_saved_counter)begin
								if(in == star)begin
									count_rw = 0;
									state = getting_hash_for_the_last_time;
								end
							end
							else if(state == locking_user)begin
								cs = 0;
								lock_in = 0;
								state = start;
							end

							else if(state == password_alarm)begin
								count_rw = 0;
								state = waiting;
							end
							cs = 0;
						end
					else // else of cs == 0
						begin
                            if(state == start)begin
								if(in == star) state = main_username_1;
							end
							else if(state == main_username_1)begin
								if(in <= valid_numbers)begin
									addr[11:8] = in;
									state = main_username_2;
								end
								else begin
									state = alarm;
									prev_state = main_username_1;
								end
							end
							else if(state == main_username_2)begin
								if(in <= valid_numbers)begin
									addr[7:4] = in;
									state = main_username_3;
								end
								else begin
									state = alarm;
									prev_state = main_username_2;
								end
							end
							else if(state == main_username_3)begin
								if(in <= valid_numbers)begin
										addr[3:0] = in;
										state = check_main_username;
								end
								else begin
										state = alarm;
										prev_state = main_username_3;
								end
							end
							else if(state == check_main_username)begin
								if(addr <= max_username && addr > min_username)begin
                                    // addr = saved_username;
                                    lock_rw = 0;
                                    cs = 1;
								end
								else
									state = start;
							end
							else if(state == user_exists)
								if(in == star) state = star_after_user_exist;
							else if(state == star_after_user_exist)
								begin
									if(in == hash)
										state = waiting_for_star;
									else if(in <= valid_numbers)
                    					begin
											prev_state = state;
                                            state = warming_ram_up;
											addr = saved_username;
										end
								end

							// Admin operations code begins here
							else if(state == admin_password_1)
								if(in <=	valid_numbers) begin
									saved_password[15:12] = in;
									state = admin_password_2;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							else if(state == admin_password_2)
								if(in <= valid_numbers)begin
									saved_password[11:8] = in;
									state = admin_password_3;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							else if(state == admin_password_3)
							begin
								if(in <= valid_numbers)begin
									saved_password[7:4] = in;
									state = admin_password_4;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == admin_password_4) begin
								if(in<=valid_numbers) begin
									saved_password[3:0] = in;
									state = check_admin_password;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == check_admin_password)begin
								pass_rw = 0;
								addr = saved_username;
                                prev_state = check_admin_password;
                                state = warming_ram_up;
							end

							else if(state == wait_for_star_after_admin_login) begin
								if(in == star)
									state = wait_for_hash_after_admin_login;
							end

							else if(state == wait_for_hash_after_admin_login)begin
								if(in == hash)
									state = wait_again_for_star_after_admin_login;
							end

							else if(state == wait_again_for_star_after_admin_login )begin
								if(in == star)
									state = get_second_username_1;
							end

							else if(state == get_second_username_1)begin
								if(in <= valid_numbers)begin
									saved_username[11:8] = in;
									state = get_second_username_2;
								end
								else begin
									prev_state = state;
									state  = alarm;
								end
							end

							else if(state == get_second_username_2)begin
								if(in <= valid_numbers)begin
									saved_username[7:4] = in;
									state = get_second_username_3;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == get_second_username_3) begin
								 if(in <= valid_numbers) begin
								 	saved_username[3:0] = in;
								 	state = check_if_the_second_username_was_admin;
								 end
								 else begin
								 	prev_state = state;
								 	state = alarm;
								 end
							end
							else if(state == check_if_the_second_username_was_admin)begin
                                prev_state = state;
                                state = warming_ram_up;
								lock_rw = 0;
								addr = saved_username;
							end
							// The second username was admin's
							else if(state == the_second_username_was_admin)begin
								if(in == star) begin
									state = getting_new_admin_username_1;
								end
							end
							else if(state == getting_new_admin_username_1) begin
								if(in <= valid_numbers)begin
									saved_username[11:8] = in;
									state = getting_new_admin_username_2;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == getting_new_admin_username_2) begin
								if(in <= valid_numbers) begin
									saved_username[7:4] = in;
									state = getting_new_admin_username_3;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end

							else if(state == getting_new_admin_username_3)begin
								if(in <= valid_numbers)begin
									saved_username[3:0] = in;
									state = checking_new_admin_username;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == checking_new_admin_username)begin
								if(saved_username <= max_username)begin
									state = admin_changed_waiting_for_hash;
								end
								else begin
									state = getting_new_admin_username_1;
								end
							end
							else if(state == admin_changed_waiting_for_hash)begin
						        prev_state = state;
                                state = warming_ram_up;
								addr = saved_username;
								admin_in = 1;
								lock_in = 0;
							end
							else if(state == admin_changed_waiting_for_another_hash)begin
								if(in == hash)begin
									state = start;
								end
							end
							// The second Username wasn't admin's
							else if(state == the_second_username_was_not_admin)begin
								if(in == hash)
									state = getting_the_new_user_password_1;
								else if(state == star)
									state = waiting_for_a_hash_to_remove;
							end
							// we are going to add a new user for the system or lock him out
							else if(state == getting_the_new_user_password_1)begin
								if(in <= valid_numbers)begin
									state = getting_the_new_user_password_2;
									saved_password[15:12] = in;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == getting_the_new_user_password_2)begin
								if(in <= valid_numbers)begin
									state = getting_the_new_user_password_3;
									saved_password[11:8] = in;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == getting_the_new_user_password_3) begin
								if(in <= valid_numbers)begin
									state = getting_the_new_user_password_4;
									saved_password[7:4] = in;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == getting_the_new_user_password_4)begin
								if(in <= valid_numbers)begin
									state = waiting_for_star_to_add;
									saved_password[3:0] = in;
								end
								else begin
									prev_state = state;
									state = alarm;
								end
							end
							else if(state == waiting_for_star_to_add)begin
								    prev_state = state;
                                    state = warming_ram_up;
									pass_rw = 1; // we are going to write a password
									addr = saved_username;
									lock_in = 0; // if the user was locked we should lock out him
							end

							else if(state == waiting_for_hash_to_add)begin
								if(in == hash)begin
									state = start;
								end
							end

							// end of adding a new user or locking him out
							// now we are going to remove a user
							else if(state == waiting_for_hash_to_remove)begin
									prev_state = state;
                                    state = warming_ram_up;
									lock_rw = 1;
									addr = saved_username;
									lock_in = 1;
							end
							// Admin oprations Ended
							// We are going to code the typical user operations
							else if(state == waiting_for_star) begin
								if(in == star) begin
									state = getting_password_1;
								end
							end
							else if(state == getting_password_1)begin
								if(in <= valid_numbers)begin
									saved_password[15:12] = in;
									state = getting_password_2;
								end
								else begin
									prev_state = state;
									state = password_alarm;
								end
							end
							else if(state == getting_password_2) begin
								if(in <= valid_numbers)begin
									saved_password[11:8] = in;
									state = getting_password_3;
								end
								else begin
									prev_state = state;
									state = password_alarm;
								end
							end
							else if(state == getting_password_3) begin
								if(in <= valid_numbers)begin
									saved_password[7:4] = in;
									state = getting_password_4;
								end
								else begin
									prev_state = state;
									state = password_alarm;
								end
							end
							else if(state == getting_password_4)begin
								if(in <= valid_numbers)begin
									saved_password[3:0] = in;
									state = check_password;
								end
								else begin
									prev_state = state;
									state = password_alarm;
								end
							end
							else if(state == check_password)begin
								prev_state = state;
                                state = warming_ram_up;
								addr = saved_username;
								pass_rw = 0;
							end
							else if(state == reset_saved_counter)begin
								prev_state = state;
                                state = warming_ram_up;
								addr = saved_username;
								count_rw = 1;
								count_in = 0000;
							end
							else if(state == getting_hash_for_the_last_time)begin
								if(in == hash);
//									  enable = 1;// Finally elevator stars to work
							end
							// End of user operations

							// Special states
							if(state == warming_ram_up)begin
                                state = prev_state;
                                cs = 1;
                            end
							else if(state == password_alarm)begin
								prev_state = state;
                                state = warming_ram_up;
								count_rw = 1;
								count_in = counter;
								addr = saved_username;
							end

							else if(state == waiting)begin
								if(~rst_timer)begin
									rst_timer = 1;
									direction = 0;
								end
								else begin
									rst_timer = 0;
									comp1 = period;
									comp2 = waiting_time;
									if(result_of_comparison)begin
										state = start;
									end
								end
							end

							else if(state == alarm)begin
								if(~rst_timer)begin
									rst_timer = 1;
									direction = 0;
								end
								else begin
									rst_timer = 0;
									comp1 = period;
									comp2 = waiting_time;
									if(result_of_comparison)begin
										state = prev_state;
									end
								end
							end
						end
				end
		end
endmodule
