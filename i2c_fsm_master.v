`include "i2c_defines.v"

module i2c_fsm_master(
	input clk,
	input rst_,
	input nReset,
	input [3:0] cmd,
	input din,
	input scl_i,
	input sda_i,
	input scl_lh,
	input scl_hl,
	input sda_lh,
	input sda_hl,
	output busy,
	output transfer,
	output cmd_ack,
	output al,
	output sda_o,
	output scl_oen,
	output sda_oen,
	output reg dout
);

parameter IDLE = 3'd0;
parameter START = 3'd1;
parameter STOP = 3'd2;
parameter WRITE = 3'd3;
parameter WAIT_ACK = 3'd4;
parameter READ = 3'd5;

reg busy_ff, busy_d;
reg transfer_ff, transfer_d;
reg al_ff, al_d;
reg cmd_ack_ff,cmd_ack_d;
reg sda_o_ff,sda_o_d;
reg sda_oen_ff, sda_oen_d;
reg scl_oen_ff, scl_oen_d;
reg [3:0] state_d, state_ff;

always @(*) begin
	busy_d = busy_ff;
	cmd_ack_d = 1'b0;
	transfer_d = transfer_ff;
	al_d = al_ff;
	sda_o_d = sda_o_ff;
	sda_oen_d = sda_oen_ff;
	scl_oen_d = scl_oen_ff;
	state_d = state_ff;
	case(state_d) 
		IDLE: begin
			if(cmd == I2C_CMD_START) begin
				if(~sda_i) begin
					al_d = 1'b1;
					scl_oen_d = 1'b0;
					sda_oen_d = 1'b0;
					state_d = IDLE;
				end
				else begin
					busy_d = 1'b1;
					sda_oen_d = 1'b1;
					sda_o_d = 1'b0;
					if(scl_hl) begin
						scl_oen_d = 1'b1;
						state_d = START;
					end
					else begin
						cmd_ack_d = 1'b1;
						scl_oen_d = 1'b0;
						state_d = IDLE;
					end
				end
			end
			else 
				state_d = IDLE;
		end
		START: begin
			
			if(cmd == I2C_CMD_WRITE & scl_hl) begin //wait 1 scl bit go write
				cmd_ack_d = 1'b1;
				transfer = 1'b1;
				state_d = WRITE;
			end
			else if(cmd == I2C_CMD_READ & scl_lh) begin //wait 1 scl bit go read
				cmd_ack_d = 1'b1;
				transfer = 1'b1;
				state_d = READ;
			end
			else begin
				state_d = START; //wait untill 1 scl bit passed
			end
		end
		STOP: begin
			busy_d = 1'b0;
			if(cmd == I2C_CMD_STOP & scl_lh) begin //stop scl and sda, go idle
				cmd_ack_d = 1'b1;
				sda_oen_d = 1'b0;
				scl_oen_d = 1'b0;
				state_d = IDLE;
			end
		end
		WRITE: begin
			if(scl_hl) begin //negedge scl
				sda_o_d = din;
				if(cmd == I2C_CMD_WRITE) begin
					cmd_ack_d = 1'b1;
					state_d = WRITE;
				end
				else if(cmd == I2C_CMD_STOP) begin //exception case; should edit
					cmd_ack_d = 1'b0;
					state_d = STOP;
				end
				else if(cmd == I2C_CMD_NOP) begin
					cmd_ack_d = 1'b1;
					state_d = WAIT_ACK;
				end
			end
			else begin
				state_d = WRITE;
			end
		end
		READ: begin
			if(scl_lh) begin //posedge scl
				dout = sda_o;
				if(cmd == I2C_CMD_READ) begin //keep reading
					cmd_ack_d = 1'b1;
					state_d = READ;
				end
				else if(cmd == I2C_CMD_STOP) begin //exception case; should edit
					cmd_ack_d = 1'b0;
					state_d = STOP;
				end
				else if(cmd == I2C_CMD_NOP) begin //sending ack
					cmd_ack_d = 1'b1;
					state_d = START;
				end
			end
			else begin
				state_d = READ;
			end
		end
		WAIT_ACK: begin
			if(scl_hl & sda_i) begin
				cmd_ack_d = 1'b0;
				state_d = IDLE;
			end
			else begin
				cmd_ack_d = 1'b1;
				state_d = START;
			end
		end
	endcase
			
end

assign busy = busy_d;
assign transfer = transfer_d;
assign cmd_ack = cmd_ack_d;
assign al = al_d;
assign scl_oen = scl_oen_d;
assign sda_oen = sda_oen_d;
assign sda_o = sda_o_d


always @(posedge clk or negedge rst_) begin
	if(~rst_) begin
		state_ff <= IDLE;
		busy_ff <= 1'b0;
		cmd_ack_ff <= 1'b0;
		transfer_ff <= 1'b0;
		al_ff <= 1'b0;
		sda_oen_ff <= 1'b0;
		sda_o_ff <= 1'b0;
		scl_oen_ff <= 1'b0;
	end
	if(nReset) begin
		state_ff <= IDLE;
		busy_ff <= 1'b0;
		cmd_ack_ff <= 1'b0;
		transfer_ff <= 1'b0;
		al_ff <= 1'b0;
		sda_oen_ff <= 1'b0;
		sda_o_ff <= 1'b0;
		scl_oen_ff <= 1'b0;
	end
	else begin
		state_ff <= state_d;
		busy_ff <= busy_d;
		cmd_ack_ff <= cmd_ack_d;
		transfer_ff <= transfer_d
		al_ff <= al_d;
		sda_oen_ff <= sda_oen_d;
		sda_o_ff <= sda_o_d;
		scl_oen_ff <= scl_oen_d;
	end
end

endmodule
