module i2c_fsm_slave(
	input clk,
	input rst_,
	input nReset,
	input [7:0] din, //write reg
	input master,
	input scl_i,
	input sda_i,
	input [7:0] cmd, //command reg
	output [7:0] dout, //read reg
	output [7:0] status, //status reg
	output sda_o,
	output sda_oen
);

parameter IDLE = 4'd0;
parameter START = 4'd1;
parameter READ = 4'd2;
parameter WRITE = 4'd3;
parameter GET_ACK = 4'd4;
parameter SEND_ACK = 4'd5;
parameter ACK = 4'd6;
parameter NACK = 4'd7;

reg [3:0] state_d, state_ff;

reg get_start_d, get_start_ff;
reg [2:0] cnt_d, cnt_ff;
reg read_d, read_ff;
reg cmd_ack_d, cmd_ack_ff;
reg rd_done_d, rd_done_ff;
reg wr_done_d, wr_done_ff;
reg sda_o_d, sda_o_ff;
reg sda_oen_d, sda_oen_ff;
reg rd_address_d , rd_address_ff;
reg transfer_d, transfer_ff;
reg busy_d , busy_ff;
reg shift_d, shift_ff;
reg load_d, load_ff;

wire scl_lh, scl_hl, sda_lh,sda_hl;


i2c_fsm_transition_detect detectSCL(
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.in(scl_i),
	.low_high_trans(scl_lh),
	.high_low_trans(scl_hl)
);

i2c_fsm_transition_detect detectSDA(
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.in(sda_i),
	.low_high_trans(sda_lh),
	.high_low_trans(sda_hl)
);

shift_sin_sout s1 (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.load(load),
	.shift(shift),
	.data_load(din),
	.serial_i(sda_i),
	.serial_o(serial_o),
	.data_o(dout)
);

always @(*) begin
	state_d = state_ff;
	cnt_d = cnt_ff;
	get_start_d = get_start_ff;
	shift_d = shift_ff;
	load_d = load_ff;
	read_d = read_ff;
	rd_done_d = rd_done_ff;
	sda_o_d = sda_o_ff;
	sda_oen_d = sda_oen_ff;
	rd_address_d = rd_address_ff;
	busy_d = busy_ff;
	transfer_d = transfer_ff;
	wr_done_d = wr_done_ff;
	cmd_ack_d = cmd_ack_ff;
	if(~master) begin
		case(state_d) 
			IDLE: begin
				sda_oen_d = 1'b0;
				if(scl_i & sda_hl) begin
					state_d = START;
					rd_address_d = 1'b1;
					get_start_d = 1'b1;
					busy_d = 1'b1;
				end
			end
			START: begin
				rd_address_d = 1'b0;
				get_start_d = 1'b0;
				cnt_d = 3'd0;
				rd_done_d = 1'b0;
				if(read_d) begin
					state_d = READ;
				end
				else begin
					state_d = WRITE;
					load_d = 1'b1;
				end
			end
			READ : begin
				sda_oen_d = 1'b0;
				if(scl_lh) begin
					cnt_d = cnt_d +1;
					if( (|cnt_d)) begin
						shift_d = 1'b1;
					end
					else begin
						rd_done_d = 1'b1;
						shift_d = 1'b0;
						state_d = SEND_ACK;
					end
				end
				else if(scl_i & sda_hl) begin
					state_d = START;
					
					get_start_d = 1'b1;
				end
				else begin
					shift_d = 1'b0;
				end
			end
			WRITE: begin
				if(scl_hl) begin
					cnt_d = cnt_d +1;
					if( (|cnt_d)) begin
						sda_o_d = serial_o;
						shift_d = 1'b1;
					end
					else begin
						shift_d =1'b0;
						wr_done_d = 1'b1;
						state_d = GET_ACK;
					end
				end
				else begin
					shift_d = 1'b0;
				end
			end
			GET_ACK: begin
				if(scl_hl) begin
					read_d = 1'b1;
					state_d = IDLE;
				end
			end
			SEND_ACK: begin
				cmd_ack_d = 1'b0;
				if(scl_hl) begin
					sda_oen_d = 1'b1;
					if(cmd[6]) begin
						sda_o_d = 1'b1;
						state_d = IDLE;
					end
					else if(cmd[7]) begin
						sda_o_d = 1'b0;
						if(read_d == 1'b1) begin
							state_d = READ;
						end
						else state_d = IDLE;
					end
				end
			end
		endcase			
	end
end

always @(posedge clk or negedge rst_) begin
	if(~rst_ | nReset) begin
		state_ff <= IDLE;
		get_start_ff <= 1'b0;
		cnt_ff <= 3'b0;
		shift_ff <= 1'b0;
		load_ff <= 1'b0;
		read_ff <= 1'b1;
		rd_done_ff <= 1'b0;
		sda_o_ff <= 1'b0;
		sda_oen_ff <= 1'b0;
		rd_address_ff <= 1'b0;
		busy_ff <= 1'b0;
		transfer_ff <= 1'b0;
		wr_done_ff <= 1'b0;
		cmd_ack_ff <= 1'b0;
	end
	else begin
		state_ff <= state_d;
		cnt_ff <= cnt_d;
		get_start_ff <= get_start_d;
		shift_ff <= shift_d;
		load_ff <= load_d;
		read_ff <= read_d;
		rd_done_ff <= rd_done_d;
		sda_o_ff <= sda_o_d;
		sda_oen_ff <= sda_oen_d;
		rd_address_ff <= rd_address_d;
		busy_ff <= busy_d;
		transfer_ff = transfer_d;
		wr_done_ff <= wr_done_d;
		cmd_ack_ff <= cmd_ack_d;
	end
end

assign shift = shift_ff;
assign load = load_ff;
assign sda_o = sda_o_ff;
assign sda_oen = sda_oen_ff;
assign status = { cmd_ack_ff, busy_ff, transfer_ff, rd_address_ff,get_start_ff , rd_done_ff, wr_done_ff, 1'b0};

endmodule