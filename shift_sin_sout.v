module shift_sin_sout #(
	parameter w = 8
) (
	input clk, 
	input rst_,
	input nReset,
	input load, 
	input shift,
	input serial_i, 
	input [w-1:0] data_load, 
	output serial_o,
	output [w-1:0] data_o
);
reg [w-1:0] tmp_d,tmp_ff; 
 
always @(*) begin
	tmp_d = tmp_ff;
	if(load) begin
		tmp_d = data_load;
	end
	else if(shift) begin
		tmp_d = {tmp_ff[6:0],serial_i};
	end
end
always @(posedge clk or negedge rst_) begin 
	if(~rst_ || nReset) begin
		tmp_ff <= 'h0;
	end
	else begin
		tmp_ff <= tmp_d;
	end
end 
  assign serial_o  = tmp_ff[w-1]; 
  assign data_o = tmp_ff;
endmodule 