module shift_sin_sout #(
	parameter w = 8
) (
	input clk, 
	input load, 
	input serial_i, 
	input [w-1:0] data_load, 
	output serial_o
);
reg [w-1:0] tmp; 
 
always @(posedge clk) begin 
    if (load) 
      tmp = data_load; 
    else 
      begin 
        tmp = {tmp[w-2:0], serial_i}; 
      end 
  end 
  assign serial_o  = tmp[w-1]; 
endmodule 