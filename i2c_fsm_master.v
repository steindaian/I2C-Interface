`include "i2c_defines.v"

module i2c_fsm_master(
	input clk,
	input rst_,
	input nReset,
	input [3:0] cmd,
	input master,
	input din,
	input scl_i,
	input scl_gen,
	input sda_i,
	output busy,
	output transfer,
	output cmd_ack,
	output al,
	output sda_o,
	output scl_oen,
	output sda_oen,
	output dout,
	output ack
);

parameter IDLE = 3'b000;
parameter START = 3'b001;
parameter STOP = 3'b010;
parameter WRITE = 3'b011;
parameter WAIT_ACK = 3'b100;
parameter READ = 3'b101;
parameter GEN_ACK = 3'b110;

wire scl_lh, scl_hl,sda_hl,sda_lh;

i2c_fsm_transition_detect detectSCL(
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.in(scl_gen),
	.low_high_trans(scl_lh),
	.high_low_trans(scl_hl)
);

i2c_fsm_transition_detect detectSDL(
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.in(sda_i),
	.low_high_trans(sda_lh),
	.high_low_trans(sda_hl)
);


reg busy_ff, busy_d;
reg transfer_ff, transfer_d;
reg al_ff, al_d;
reg cmd_ack_ff,cmd_ack_d;
reg sda_o_ff,sda_o_d;
reg sda_oen_ff, sda_oen_d;
reg scl_oen_ff, scl_oen_d;
reg [2:0] state_d, state_ff;
reg dout_d , dout_ff;
reg ack_d,ack_ff;

always @(*) begin
	busy_d = busy_ff;
	cmd_ack_d = cmd_ack_ff;
	transfer_d = transfer_ff;
	al_d = al_ff;
	sda_o_d = sda_o_ff;
	sda_oen_d = sda_oen_ff;
	scl_oen_d = scl_oen_ff;
	dout_d = dout_ff;
	state_d = state_ff;
	ack_d = ack_ff;
	if(master) begin
	case(state_d) 
		IDLE: begin
			if(cmd == `I2C_CMD_START) begin
				if(~sda_i & ~busy_d) begin
					al_d = 1'b1;
				end
				else begin
					busy_d = 1'b1;
					if(scl_gen & ~scl_i) begin //clock streching
						scl_oen_d = 1'b0;
						state_d = IDLE;
					end
					else begin 
						scl_oen_d = 1'b1;
						if(scl_gen) begin
							sda_oen_d = 1'b1;
							sda_o_d = 1'b0;
						end
						
						if(scl_hl) begin
							cmd_ack_d = 1'b1;
							state_d = START;
						end
					end
				end
			end
		end
		START: begin
			ack_d = 1'b0;
			scl_oen_d = 1'b1;
			if(cmd == `I2C_CMD_WRITE & scl_hl) begin //wait 1 scl bit go write
				cmd_ack_d = 1'b1;
				sda_o_d = din;
				sda_oen_d = 1'b1;
				transfer_d = 1'b1;
				state_d = WRITE;
			end
			else if(cmd == `I2C_CMD_READ & scl_hl) begin //wait 1 scl bit go read
				cmd_ack_d = 1'b1;
				sda_oen_d = 1'b0;
				dout_d = sda_i;
				transfer_d = 1'b1;
				state_d = READ;
			end
			else if(cmd == `I2C_CMD_START & scl_hl) begin
				cmd_ack_d = 1'b0;
				sda_o_d = 1'b1;
				sda_oen_d = 1'b1;
				scl_oen_d = 1'b1;
				transfer_d = 1'b0;
				state_d = IDLE;
			end
			else if(cmd == `I2C_CMD_STOP & scl_hl) begin
				cmd_ack_d = 1'b1;
				sda_o_d = 1'b0;
				sda_oen_d = 1'b1;
				transfer_d = 1'b0;
				state_d = STOP;
			end
			else begin
				cmd_ack_d = 1'b0;
				transfer_d = 1'b0;
			end
		end
		STOP: begin
			ack_d = 1'b0;
			if(scl_lh) begin
				scl_oen_d = 1'b0;
				sda_oen_d = 1'b0;
				busy_d = 1'b0;
				state_d = IDLE;
			end
			else if(~scl_gen) begin
				cmd_ack_d = 1'b1;
				transfer_d = 1'b0;
				sda_oen_d = 1'b1;
				sda_o_d = 1'b0;
			end
			else if(scl_gen) begin
				cmd_ack_d = 1'b0;
				sda_oen_d = 1'b1;
				sda_o_d = 1'b1;
			end
		end
		WRITE: begin
			ack_d = 1'b0;
			if(scl_hl) begin //negedge scl
				if(cmd == `I2C_CMD_WRITE) begin
					cmd_ack_d = 1'b1;
					sda_o_d = din;
					state_d = WRITE;
				end
				else if(cmd == `I2C_CMD_NOP) begin
					cmd_ack_d = 1'b1;
					sda_oen_d = 1'b0;
					state_d = WAIT_ACK;
				end
				else if(cmd == `I2C_CMD_STOP) begin
					cmd_ack_d = 1'b1;
					state_d = STOP;
				end
			end
			else begin
				cmd_ack_d = 1'b0;
			end
		end
		READ: begin
			
			if(scl_hl) begin //posedge scl
				if(cmd == `I2C_CMD_READ) begin //keep reading
					cmd_ack_d = 1'b1;
					dout_d = sda_i;
					state_d = READ;
				end
				else if(cmd == `I2C_CMD_NOP) begin //sending ack
					transfer_d = 1'b0;
					cmd_ack_d = 1'b1;
					sda_oen_d = 1'b1;
					sda_o_d = din;
					state_d = GEN_ACK;
				end
			end
			else begin
				cmd_ack_d = 1'b0;
			end
		end
		WAIT_ACK: begin
			ack_d = ~sda_i;
			cmd_ack_d = 1'b1;
			state_d = START;
		end
		GEN_ACK: begin
			cmd_ack_d = 1'b1;
			state_d = START;	
		end
	endcase	
	end
end

assign busy = busy_ff;
assign transfer = transfer_ff;
assign cmd_ack = cmd_ack_ff;
assign al = al_ff;
assign scl_oen = scl_oen_ff;
assign sda_oen = sda_oen_ff;
assign sda_o = sda_o_ff;
assign dout = dout_ff;
assign ack = ack_ff;

always @(posedge clk or negedge rst_) begin
	if(~rst_ || nReset) begin
		state_ff <= IDLE;
		busy_ff <= 1'b0;
		cmd_ack_ff <= 1'b0;
		transfer_ff <= 1'b0;
		al_ff <= 1'b0;
		sda_oen_ff <= 1'b0;
		sda_o_ff <= 1'b1;
		scl_oen_ff <= 1'b0;
		dout_ff <= 1'b0;
		ack_ff <= 1'b0;
	end
	else begin
		state_ff <= state_d;
		busy_ff <= busy_d;
		cmd_ack_ff <= cmd_ack_d;
		transfer_ff <= transfer_d;
		al_ff <= al_d;
		sda_oen_ff <= sda_oen_d;
		sda_o_ff <= sda_o_d;
		scl_oen_ff <= scl_oen_d;
		dout_ff <= dout_d;
		ack_ff <= ack_d;
	end
end

assign state = state_ff;
endmodule
