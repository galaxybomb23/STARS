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

// Write your code here
  
//task 2
sync_low u2(.clk(hz100), .n_rst(pb[0]), .async_in(pb[1]), .sync_out(right[1]));

  
endmodule

//2-bit synchronizer
module sync_low(
  input logic clk, n_rst, async_in,
  output logic sync_out
);
logic sync_reg;
always_ff @(posedge clk, negedge n_rst)
  if (!n_rst) begin
    sync_out <= 1'b0;
    sync_reg <= 1'b0;
  end
  else begin
    sync_reg <= async_in;
    sync_out <= sync_reg;
  end

endmodule

//synchroflop!