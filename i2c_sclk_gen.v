module i2c_sclk_gen (
	input clk,
	input rst_,
	input nReset,
	output scl
);

reg [5:0]  cnt_ff,cnt_d;
reg scl_d, scl_ff;

assign scl = scl_ff;

always @ (*)
     begin
	scl_d = scl_ff;
	cnt_d = cnt_ff + 1;
	if (cnt_d == 6'd5)
	  begin
	     scl_d = ~scl_d;
	     cnt_d = 6'd0;	  
	  end
     end

always @ (posedge clk, negedge rst_)
     begin
	if(!rst_)
	  begin
	     scl_ff <= 1'b1;
	     cnt_ff <= 6'd0;
	  end
	else
	  begin
	     scl_ff <= scl_d;
	     cnt_ff <= cnt_d;
	  end
     end
endmodule 
	