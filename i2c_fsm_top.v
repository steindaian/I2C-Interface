module i2c_fsm_top (
	input clk,
	input rst_,
	input nReset,
	input master,
	input ena,
	input [7:0] din,
	input [7:0] cmd,
	output busy,
	output al,
	output ack,
	output transfer,
	output [7:0] dout,
	inout scl,
	inout sda,
		
);

wire scl_i;
wire scl_o;
wire scl_oen;
wire sda_o;
wire sda_i;
wire sda_oen;

wire scl_input;
wire scl_lh;
wire scl_hl;
wire sda_lh;
wire sda_hl;
wire sin;
wire sout;

assign sda_i = sda;
assign scl_i = scl;

i2c_sclk_gen gen (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.scl(scl_o)
);

assign scl_input = master ? scl_o : scl_i;

i2c_fsm_transition_detect detectSCL (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.in(scl_input),
	.low_high_trans(scl_lh),
	.high_low_trans(scl_hl)
);

i2c_fsm_transition_detect detectSDA (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.in(sda_i),
	.low_high_trans(sda_lh),
	.high_low_trans(sda_hl)
);

shift_sin_sout s1 (
	.
i2c_fsm fsm (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.scl_lh(scl_lh),
	.scl_hl(scl_hl),
	.sda_lh(sda_lh),
	.sda_hl(sda_hl),
	.master(master),
	.cmd(cmd),
	.busy(busy),
	.ack(ack),
	.al(al),
	.scl_oen(scl_oen),
	.sda_oen(sda_oen),
	.sda_o(sda_o),
	.din(din),
	.dout(dout)
);


assign scl = scl_oen & ena ? scl_o : 1'bz;
assign sda = sda_oen & ena ? sda_o : 1'bz;
endmodule