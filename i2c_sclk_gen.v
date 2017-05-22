module i2c_sclk_gen (
	input clk,
	input rst_,
	output scl
);

reg scl_ff, scl_d;
reg [15:0] cnt_d, cnt_ff;

always @(*) begin
	scl_d=scl_ff;
	cnt_d = cnt_ff + 16'd1;
	if(~rst_) begin
		scl_d = 1'b0;
		cnt_d = 16'd0;
	end
	else if(cnt_d == 16'd49) begin
		cnt_d = 16'd0;
		scl_d = ~scl_d;
	end
end

always @(posedge clk or negedge rst_) begin
	if(~rst_) begin
		scl_ff <= 1'b0;
		cnt_ff <= 15'd1;
	end
	else begin
		scl_ff <= scl_d;
		cnt_ff <= cnt_d;
	end
end

assign scl = scl_ff;

endmodule 
	