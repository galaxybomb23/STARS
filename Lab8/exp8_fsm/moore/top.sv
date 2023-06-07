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

  // Your code goes here...
  
endmodule

//moore machine for 1101 pattern
module moore1101(
  input logic clk, n_rst, i,
  output logic o
);

//states
typedef enum logic [2:0] {S0, S1, S2, S3, S4} state_t;
state_t state;

//next state logic
always_ff @(posedge clk, negedge n_rst)
  if(!n_rst)
    state <= S0;
  else
    case(state)
      S0: state <= i ? S1 : S0;
      S1: state <= i ? S2 : S0;
      S2: state <= i ? S2 : S3;
      S3: state <= i ? S4 : S0;
      S4: state <= i ? S2 : S0;
      default state <= S0;
    endcase

//output logic
assign o = (state == S4);
endmodule
