module shift_sin_pout #(
	parameter w = 8
) (
	input clk,
	input serial_i,
	output [w-1:0] paralel_o
);

reg [w-1:0] tmp;

always @(posedge clk) begin
	tmp = {tmp[w-2:0],sin}
end

assign paralel_o = tmp;

endmoodule