module i2c_sclk_gen_tb(
	output reg tb_clk,
	output reg tb_rst_,
	output tb_scl_out
);
   // define system frequency in MHz
`define FREQ 500
`define PER 1000/`FREQ
   
   //testbench variables
   

   //instantiate DUT

  i2c_sclk_gen test1
    (
     .clk(tb_clk),
     .rst_(tb_rst_),
     .scl(tb_scl_out)
     );

   //generate
   initial 
     begin
	tb_clk = 1'b0;
	forever
	  begin
	     #(`PER/2) tb_clk = !tb_clk;
	  end
     end

   // initialize simulation
   initial
     begin
	tb_rst_ = 1'b1;
	#(`PER/2*7) tb_rst_ = 1'b0;
	#(`PER) tb_rst_ = 1'b1;
     end
   // finish
	initial begin
	   #2000;
	   $stop;
	end   


endmodule