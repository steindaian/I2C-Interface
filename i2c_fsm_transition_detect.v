module i2c_fsm_transition_detect
	(
		input clk,
		input in,
		input rst_,
		input nReset,
		output low_high_trans,
		output high_low_trans
	);
	
	parameter IDLE = 2'b00;
	parameter LH   = 2'b01;
	parameter HL   = 2'b10;
	
	reg [1:0] state, state_nxt;
	reg in_delay;
	reg low_high_trans_ff, low_high_trans_nxt;
	reg high_low_trans_ff, high_low_trans_nxt;
	
	always @(*) begin
		state_nxt = state;
		low_high_trans_nxt = low_high_trans_ff;
		high_low_trans_nxt = high_low_trans_ff;
		case (state)
			IDLE:
				begin
					
					if (in != in_delay) begin
						if (in) begin
							low_high_trans_nxt = 1'b1;
							state_nxt = LH;
						end
						else begin
							high_low_trans_nxt = 1'b1;
							state_nxt = HL;
						end
					end
					else begin
						low_high_trans_nxt = 1'b0;
						high_low_trans_nxt = 1'b0;
					end
				end
			LH:
				begin
					low_high_trans_nxt = 1'b0;
					state_nxt = IDLE;
				end
			HL:
				begin
					high_low_trans_nxt = 1'b0;
					state_nxt = IDLE;
				end
		endcase
	end
	
	always @(posedge clk) begin
		if(!rst_) begin
			state <= IDLE;
			low_high_trans_ff <= 1'b0;
			high_low_trans_ff <= 1'b0;
		end
		else begin
			state <= state_nxt;
			low_high_trans_ff <= low_high_trans_nxt;
			high_low_trans_ff <= high_low_trans_nxt;
			in_delay <= in;
		end
	end
	
	assign low_high_trans = low_high_trans_ff;
	assign high_low_trans = high_low_trans_ff;
	
endmodule