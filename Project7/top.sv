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
//CLAhybrid16bit CLAh(.a(16'h9999), .b(16'h9999), .Cin(pb[0]), .Cout(red), .s(s));
CLA16b CLA(.a(16'h9999), .b(16'h9999), .Cin(pb[0]), .Cout(red), .s(s)); 
ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1)); 
ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1)); 
ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1)); 
ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
assign ss4[2:1] = {red,red};
assign {left, right} = s;

endmodule

// // 16bit CLA Adder
module CLA16b (
  input logic [15:0] a, b,
  input logic Cin,
  output logic [15:0] s,
  output logic Cout
);

  logic [15:0] P, G, C; // Propagate, Generate, Carry
  logic [15:0] C_propagate, C_generate; // Carry Propagate, Carry Generate
  genvar i;

  // initialize generate and propagate initals
  assign P = a ^ b; 
  assign G = a & b;



  // initialize carry generate and propagate
  assign C_propagate[0] = Cin;
  assign C_generate[0] = G[0];

  generate //fill in the rest of the carry generate and propagate
    for (i = 1; i < 16; i = i + 1) begin : gen_carry
      assign C_propagate[i] = G[i-1] | (P[i-1] & C_propagate[i-1]);
      assign C_generate[i] = G[i] | (P[i] & C_propagate[i]);
    end
  endgenerate

  // assign  carry out
  assign Cout = C_generate[15];

  // Calculate sum
  assign s[0] = a[0] ^ b[0] ^ Cin; // initialize sum
  generate //fill in the rest of the sum
    for (i = 1; i < 16; i = i + 1) begin : gen_sum
      assign s[i] = P[i] ^ C_propagate[i];
    end
  endgenerate

endmodule



// //16bit hybrid CLA Adder
// module CLAhybrid16bit(
//   input logic [15:0] a, b,
//   input logic Cin,
//   output logic [15:0] s,
//   output logic Cout
// );

// // generate c
// logic [2:0] c;

// //instance 4bit CLA
// CLA4bit CLA0(
//   .a(a[3:0]), .b(b[3:0]),
//   .s(s[3:0]), .Cin(Cin),
//   .Cout(c[0])
// );
// CLA4bit CLA1(
//   .a(a[7:4]), .b(b[7:4]),
//   .s(s[7:4]), .Cin(c[0]),
//   .Cout(c[1])
// );
// CLA4bit CLA2(
//   .a(a[11:8]), .b(b[11:8]),
//   .s(s[11:8]), .Cin(c[1]),
//   .Cout(c[2])
// );
// CLA4bit CLA3(
//   .a(a[15:12]), .b(b[15:12]),
//   .s(s[15:12]), .Cin(c[2]),
//   .Cout(Cout)
// );

// endmodule

// // 4bit CLA Adder
// module CLA4bit(
//   input logic [3:0] a, b,
//   input logic Cin,
//   output logic [3:0] s,
//   output logic Cout
// );
// logic [3:0] p, g;
// logic [3:0] c;

// // generate p and g
// assign p = a ^ b;
// assign g = a & b;

// // generate c
// assign c[0] = Cin;
// assign c[1] = g[0] | (p[0] & Cin);
// assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & Cin);
// assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & Cin);

// // // Sum output
// assign s = a ^ b ^ c;

// // generate Cout
// assign Cout = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & Cin);

// endmodule



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

//