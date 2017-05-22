module i2c_fsm (
	input clk,
	input rst_,
	input nReset,
	input [7:0] din,
	input master,
	input scl_lh,
	input scl_hl,
	input sda_hl,
	input sda_lh,
	input [7:0] cmd,
	input [7:0] din,
	output al,
	output ack,
	output transfer,
	output [7:0] dout,
	output sda_o,
	output scl_oen,
	output sda_oen
);

`define I2C_CMD_NOP   4'b0000
`define I2C_CMD_START 4'b0001
`define I2C_CMD_STOP  4'b0010
`define I2C_CMD_WRITE 4'b0100
`define I2C_CMD_READ  4'b1000

reg [3:0] command;

always @(*) begin
	if(cmd[7]) command = I2C_CMD_START;
	else if(cmd[6]) command = I2C_CMD_STOP;
	else if(cmd[5]) command = I2C_CMD_WRITE;
	else if(cmd[4]) command = I2C_CMD_READ;
	else command = I2C_CMD_NOP;
end

i2c_fsm fsm (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.scl_lh(scl_lh),
	.scl_hl(scl_hl),
	.sda_lh(sda_lh),
	.sda_hl(sda_hl),
	.master(master),
	.busy(busy),
	.ack(ack),
	.al(al),
	.scl_oen(scl_oen),
	.sda_oen(sda_oen),
	.sda_o(sda_o),
	.din(din),
	.dout(dout)
);
i2c_fsm fsm (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.scl_lh(scl_lh),
	.scl_hl(scl_hl),
	.sda_lh(sda_lh),
	.sda_hl(sda_hl),
	.master(master),
	.busy(busy),
	.ack(ack),
	.al(al),
	.scl_oen(scl_oen),
	.sda_oen(sda_oen),
	.sda_o(sda_o),
	.din(din),
	.dout(dout)
);
endmodule