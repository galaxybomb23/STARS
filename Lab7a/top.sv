`default_nettype none

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

//task 1
d_ff u1(.clk(hz100), .n_rst(pb[0]), .d_in(pb[1]), .d_out(right[0]));

//task 1.5
jk_ff u3(.clk(hz100), .n_rst(pb[0]), .j_in(pb[1]), .k_in(pb[2]), .q_out(right[2]));

endmodule

//dflipflop
module d_ff(
  input logic clk, n_rst, d_in,
  output logic d_out
);

always_ff @(posedge clk, negedge n_rst)
  if (!n_rst)
    d_out <= 1'b0;
  else
    d_out <= d_in;
endmodule


  
//jk flipflop
module jk_ff(
  input logic clk, n_rst, j_in, k_in,
  output logic q_out
);

always_ff @(posedge clk, negedge n_rst)
  if (!n_rst)
    q_out <= 1'b0;
  else if (j_in && k_in)
    q_out <= ~q_out;
  else if (j_in)
    q_out <= 1'b1;
  else if (k_in)
    q_out <= 1'b0;

endmodule