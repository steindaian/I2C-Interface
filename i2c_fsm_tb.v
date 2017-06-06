module i2c_fsm_tb (
	output reg clk,
	output reg rst_,
	output reg nReset,
	output reg master,
	output reg ena,
	output wr_done,
	output rd_done,
	output reg wr_en,
	output reg [7:0] cmd,
	output reg [7:0] din,
	output [7:0] status,
	output [7:0] dout
);

wire scl;
wire sda;

i2c_fsm_top top (
	.clk(clk),
	.rst_(rst_),
	.nReset(nReset),
	.cmd(cmd),
	.din(din),
	.status(status),
	.dout(dout),
	.master(master),
	.ena(ena),
	.scl(scl),
	.sda(sda),
	.wr_done(wr_done),
	.rd_done(rd_done),
	.wr_en(wr_en)
);

pullup(scl);
pullup(sda);

initial begin
	ena = 1'b1;
	master = 1'b1;
	clk = 1'b1;
	forever #50 clk = ~clk;
end

initial begin
	rst_ = 1'b0;
	nReset = 1'b0;
	#70 rst_ = 1'b1;
end

initial begin
	cmd = 8'b10000000;
	wr_en = 1'b1;
	#100 begin
		cmd = 8'b00010000;
		din = 8'b10011010;
	end 
	#8900 begin
		cmd = 8'b00010000;
		din = 8'b10101010;
	end
	#9800 begin
		cmd = 8'b10000000;
	end
	#200 begin
		cmd = 8'b00100000;
	end
	#4500 begin
		cmd = 8'b01000000;
	end
end

initial begin
	#200000 begin
		$dumpfile("write-write-start-read-stop.vcd");
		$stop;
	end
end

endmodule
