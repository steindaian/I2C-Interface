module i2c_fsm_top (
	input clk,
	input rst_,
	input nReset,
	input master,
	input ena,
	input [7:0] din,
	output wr_done,
	input wr_en,
	input [7:0] cmd,
	output rd_done,
	output [7:0] status,
	output [7:0] dout,
	inout scl,
	inout sda		
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
assign scl = scl_oen & ena & master ? scl_o : 1'bz;
assign sda = sda_oen & ena ? sda_o : 1'bz;

i2c_sclk_gen gen (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.scl(scl_o)
);


i2c_fsm fsm (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.master(master),
	.cmd(cmd),
	.status(status),
	.scl_oen(scl_oen),
	.sda_oen(sda_oen),
	.sda_o(sda_o),
	.din(din),
	.dout(dout),
	.wr_en(wr_en),
	.wr_done(wr_done),
	.rd_done(rd_done),
	.scl_i(scl_i),
	.scl_gen(scl_o),
	.sda_i(sda_i)
);

endmodule