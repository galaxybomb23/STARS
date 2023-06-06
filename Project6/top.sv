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

logic co; 
logic [15:0] s; 
bcdadd4 ba1(.a(16'h9999), .b(16'h9999), .ci(pb[0]), .co(red), .s(s)); 
ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1)); 
ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1)); 
ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1)); 
ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
assign ss4[2:1] = {red,red};
assign {left, right} = s;


endmodule

//16 bit BCD adder
module bcdadd4(
  input logic [15:0] a, b,
  input logic ci,
  output logic [15:0] s,
  output logic co
);
logic c0, c1, c2;

bcdadd1 ba0(.a(a[3:0]), .b(b[3:0]), .ci(ci), .co(c0), .s(s[3:0]));
bcdadd1 ba1(.a(a[7:4]), .b(b[7:4]), .ci(c0), .co(c1), .s(s[7:4]));
bcdadd1 ba2(.a(a[11:8]), .b(b[11:8]), .ci(c1), .co(c2), .s(s[11:8]));
bcdadd1 ba3(.a(a[15:12]), .b(b[15:12]), .ci(c2), .co(co), .s(s[15:12]));
endmodule

//4bit bcd adder
module bcdadd1(
  input logic [3:0] a, b,
  input logic ci,
  output logic [3:0] s,
  output logic co
);

logic [4:0] s0, s1;

always_comb begin : BCDA4
  //sum and carry the first digit
s0 = a[3:0] + b[3:0] + {4'b0,ci};
  if (s0 > 9)begin
    s1 = s0 - 10;
    co = 1;
  end
  else begin
    s1 = s0;
    co = 0;
  end
end
assign s = s1[3:0];

endmodule

module ssdec(
              input logic [3:0]in,
              input logic enable,
              output logic [6:0]out
);
  logic [6:0] SEG7 [15:0];
  
  assign SEG7[4'h0] = 7'b0111111;
  assign SEG7[4'h1] = 7'b0000110;
  assign SEG7[4'h2] = 7'b1011011;
  assign SEG7[4'h3] = 7'b1001111;
  assign SEG7[4'h4] = 7'b1100110;
  assign SEG7[4'h5] = 7'b1101101;
  assign SEG7[4'h6] = 7'b1111101;
  assign SEG7[4'h7] = 7'b0000111;
  assign SEG7[4'h8] = 7'b1111111;
  assign SEG7[4'h9] = 7'b1100111;
  assign SEG7[4'ha] = 7'b1110111;
  assign SEG7[4'hb] = 7'b1111100;
  assign SEG7[4'hc] = 7'b0111001;
  assign SEG7[4'hd] = 7'b1011110;
  assign SEG7[4'he] = 7'b1111001;
  assign SEG7[4'hf] = 7'b1110001;


  assign out = enable ? SEG7[in] : 7'b0000000; // enable implimentation
endmodule

//bcdadder