module reg_8b (
  input clk,
  input rst_b,//asynch
  input ld,
  input [7:0] d,
  output reg [7:0] q
);

  always @ (posedge clk or negedge rst_b)
    if (!rst_b) q <= 8'd0;
    else if (ld) q <= d;
endmodule