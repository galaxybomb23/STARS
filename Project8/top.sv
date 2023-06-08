`default_nettype none
// Empty top module

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

  //100hz to 13hz /div 8
  clkdiv u2(
    .clk(hz100),
    .rst(reset),
    .lim(8'd3),
    .hzX(right[1])
  );

  // 100hz to 10hz div  10
  clkdiv u1(
    .clk(hz100),
    .rst(reset),
    .lim(8'd4),
    .hzX(right[0])
  );

  //100hz to 4hz /div 25
  clkdiv u3(
    .clk(hz100),
    .rst(reset),
    .lim(8'd12),
    .hzX(right[2])
  );

endmodule

module clkdiv #(
    parameter BITLEN = 8
) (
    input logic clk, rst, 
    input logic [BITLEN-1:0] lim,
    output logic hzX
);

  logic [BITLEN-1:0] cnt;

  always_ff @ (posedge clk, posedge rst) begin
    if (rst) begin
      cnt <= 0;
      hzX <= 0;
    end
    else begin
      cnt <= cnt + 1;
      if (cnt == lim) begin
        cnt <= 0;
        hzX <= ~hzX;
      end
    end
  end

endmodule

//clocking