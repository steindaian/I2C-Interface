`include "i2c_defines.v"
module i2c_fsm (
	input clk,
	input rst_,
	input nReset,
	input [7:0] din, //write reg
	input master,
	input scl_i,
	input scl_gen,
	input sda_i,
	input wr_en,
	output wr_done, //write done (WB)
	input [7:0] cmd, //command reg
	output [7:0] dout, //read reg
	output [7:0] status, //status reg
	output sda_o,
	output scl_oen,
	output sda_oen,
	output rd_done //read done (this module)
);

parameter IDLE = 3'd0;
parameter START = 3'd1;
parameter STOP = 3'd2;
parameter WRITE = 3'd3;
parameter READ = 3'd4;
parameter ACK = 3'd5;

wire busy;
wire al;
wire transfer;
wire int;
wire serial_o, serial_i;
wire load, shift;
wire cmd_ack;
wire ack;
wire i2c_din;

reg [3:0] cmd_ff,cmd_d;
reg int_ff, int_d;
reg [2:0] cnt_ff, cnt_d;
reg [3:0] state_d , state_ff;
reg rd_en_d, rd_en_ff;
reg load_ff, load_d;
reg shift_ff, shift_d;
reg din_oen_d,din_oen_ff;
reg wr_done_d, wr_done_ff;

assign i2c_din = din_oen_ff ? serial_o : din[7];

shift_sin_sout s1 (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.load(load),
	.shift(shift),
	.data_load(din),
	.serial_i(serial_i),
	.serial_o(serial_o),
	.data_o(dout)
);

i2c_fsm_master master1 (
	.clk(clk),
	.rst_(rst_),
	.master(master),
	.nReset(nReset),
	.din(i2c_din),
	.cmd(cmd_ff),
	.sda_i(sda_i),
	.scl_i(scl_i),
	.scl_gen(scl_gen),
	.busy(busy),
	.cmd_ack(cmd_ack),
	.transfer(transfer),
	.al(al),
	.dout(serial_i),
	.sda_oen(sda_oen),
	.scl_oen(scl_oen),
	.sda_o(sda_o),
	.ack(ack)
);


always @(*) begin
	state_d = state_ff;
	int_d = int_ff;
	cmd_d = cmd_ff;
	cnt_d = cnt_ff;
	rd_en_d = rd_en_ff;
	load_d = load_ff;
	shift_d = shift_ff;
	din_oen_d = din_oen_ff;
	wr_done_d = wr_done_ff;
	if(master) begin
		case(state_d)
			IDLE: begin
					if(cmd[7]) begin
						cmd_d = `I2C_CMD_START;
						state_d = START;
					end
					else if(cmd[6]) begin
						cmd_d = `I2C_CMD_STOP;
					end
					else begin
						cmd_d = `I2C_CMD_NOP;
					end
			end
			START: begin
				wr_done_d = 1'b0;
				din_oen_d = 1'b1;
				rd_en_d = 1'b0;
				if(al) begin
					shift_d = 1'b0;
					cmd_d = `I2C_CMD_NOP;
					state_d = IDLE;
				end
				else if(cmd_ack) begin
					
					if(cmd[5]) begin
						cmd_d = `I2C_CMD_READ;
						//shift_d = 1'b1;
						cnt_d = 3'b0;						
						state_d = READ;
					end
					else if(cmd[4]) begin
						shift_d = 1'b0;
						if(wr_en) begin
							load_d = 1'b1;
							cnt_d = 3'b0;
							cmd_d = `I2C_CMD_WRITE;						
							state_d = WRITE;
						end
						else begin
							cmd_d = `I2C_CMD_STOP;
							state_d = IDLE;
						end
					end
					else if(cmd[6]) begin
						shift_d = 1'b0;
						cmd_d = `I2C_CMD_STOP;						
						state_d = IDLE;
					end
					else begin
						shift_d = 1'b0;
						state_d = IDLE;
					end
				end
				else begin
					if(cmd[7]) begin
						state_d = IDLE;
					end
				end
			end
			READ: begin
				din_oen_d = 1'b0;
				if(cmd_ack ) begin
					cnt_d = cnt_d +1;
					shift_d = 1'b1;
					if( (|cnt_d)) begin
						
						cmd_d = `I2C_CMD_READ;
					end
					else begin
						
						//rd_en_d = 1'b1;
						cmd_d = `I2C_CMD_NOP;
						state_d = ACK;
					end
				end
				else begin
					shift_d = 1'b0;
				end
			end
			ACK: begin
				wr_done_d = 1'b0;
				
				if(cmd_ack) begin
					rd_en_d = 1'b1;
					state_d = START;
				end
			end
			WRITE: begin
				load_d = 1'b0;
				if(cmd_ack ) begin
					cnt_d = cnt_d +1;
					if( (|cnt_d)) begin
						shift_d = 1'b1;
						cmd_d = `I2C_CMD_WRITE;
					end
					else begin
						wr_done_d = 1'b1;
						shift_d = 1'b0;
						cmd_d = `I2C_CMD_NOP;
						state_d = ACK;
					end
						
				end
				else begin
					shift_d = 1'b0;
				end
			end
			
		endcase		
	end
	else begin

	end
end

always @(posedge clk or negedge rst_) begin
	if(~rst_) begin
		state_ff <= IDLE;
		cmd_ff <= `I2C_CMD_NOP;
		shift_ff <= 1'b0;
		int_ff<= 1'b0;
		cnt_ff <= 3'b0;
		load_ff <= 1'b0;
		din_oen_ff <= 1'b1;
		rd_en_ff <= 1'b0;
		wr_done_ff <= 1'b0;
	end
	else if(nReset) begin
		state_ff <= IDLE;
		cmd_ff <= `I2C_CMD_NOP;
		shift_ff <= 1'b0;
		din_oen_ff <= 1'b1;
		int_ff <= 1'b0;
		cnt_ff <= 3'b0;
		load_ff <= 1'b0;
		rd_en_ff <= 1'b0;
		wr_done_ff <= 1'b0;
	end
	else begin
		cmd_ff <= cmd_d;
		state_ff <= state_d;
		cnt_ff <= cnt_d;
		shift_ff <= shift_d;
		int_ff <= int_d;
		load_ff <= load_d;
		din_oen_ff <= din_oen_d;
		rd_en_ff <= rd_en_d;
		wr_done_ff <= wr_done_d;
	end
end

assign shift = shift_ff;
assign load = load_ff;
assign int = ack | al ;
assign status = { ack , busy, al, cmd_ack, 2'b0, transfer, int};
assign rd_done = rd_en_ff;
assign wr_done = wr_done_ff;

endmodule