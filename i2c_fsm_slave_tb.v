module i2c_fsm_slave_tb;

`define FREQ 50
`define PER 1000/`FREQ

reg clk, rst_, nReset, master, tb_sda_in;
wire scl_i, sda_o, sda_oen;

wire [7:0] status, dout;
reg [7:0] cmd, din;
 


i2c_sclk_gen gen (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.scl(scl_i)
);

i2c_fsm_slave slave (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.master(master),
	.sda_i(tb_sda_in),
	.sda_o(sda_o),
	.scl_i(scl_i),
	.sda_oen(sda_oen),
	.cmd(cmd),
	.status(status),
	.din(din),
	.dout(dout)
);

initial begin
	clk=1'b1;
	forever #50 clk = ~clk;
end

initial begin
	rst_ = 1'b0;
	nReset = 1'b0;
	master = 1'b0;
	#70 rst_ = 1'b1;
end

initial begin
	tb_sda_in = 1'b1;
	#(`PER*101) tb_sda_in = 1'd1;
	#(`PER*5) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*50) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*135) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
end

initial begin
	cmd = 8'b01000000;
end
initial begin
	#20000 $stop;
end
endmodule