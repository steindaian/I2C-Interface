module I2C_interface_top (
	inout sda,
	inout scl,
	input clk,
	input rst_,
	input rst_a,
	input sta,
	input we,
	input [7:0] data_i,
	output [7:0] data_o,
	output ack,
	output int,
	
);

wire master;
wire clk_i;

internal_reg i (
	.clk(clk),
	.rst_(rst_),
	.rst_a(rst_a),
	.data_i(data_i),
	.sta(sta),
	.we(we),
	.int(int),
	.data_o(data_o),
	.master(master),
	.ack(ack),
);

fsm fsm1(
	.scl(scl),
	.sda(sda),
	.data_i(data_i),
	.data_o(data_o),
	.master(master),
	.clk(clk_i),
	.
);

endmodule