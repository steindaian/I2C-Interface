module rgst #(
	parameter w = 8,	//register's width
	parameter iv = 'b0	//initialization vector
)(
	input clk, 
	input rst_b,	//asynchronous reset; active low
	input [w-1:0] d, 
	input ld, 
	input clr,		//synchronous reset; active high
	output reg [w-1:0] q
);

	always @ (posedge clk, negedge rst_b)
		if (!rst_b)
			q <= iv;
		else if (clr)
			q <= iv;
		else if (ld)
			q <= d;
endmodule