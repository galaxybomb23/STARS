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
logic [7:0] pbin = pb[7:0];
logic [2:0] prienc, enc8to3; 


mux8to1 u1(.I(pbin), .S(pb[10:8]), .Y(red));
pri_enc u2(.I(pbin), .Y(prienc), .G(green));
encoder8to3 u3(.I(pbin), .Y(enc8to3));

decode3to8 u6(.in(pb[2:0]), .out({ss7[7],ss6[7],ss5[7],ss4[7],ss3[7],ss2[7],ss1[7],ss0[7]}));


//show the number on the 7-segment display
ssdec u4(.in({1'b0,prienc}), .enable(1), .out(ss7[6:0]));
ssdec u5(.in({1'b0,enc8to3[2:0]}), .enable(1), .out(ss6[6:0]));
ssdec u7(.in(pb[3:0]), .enable(1), .out(ss5[6:0]));


endmodule

//8 to 1 mux
module mux8to1(
  input logic [7:0] I,
  input logic [2:0] S,
  output logic Y
);
 assign Y = I[S];
// ternary operator
// assign Y = S[3] ? I[7] : S[2] ? I[6] : S[1] ? I[5] : S[0] ? I[4] : S[3] ? I[3] : S[2] ? I[2] : S[1] ? I[1] : I[0];
endmodule

//task2 8:3 encoder and 8:3 priority encoder with strobe

module encoder8to3(
  input logic [7:0] I,
  output logic [2:0] Y
);
assign Y[0] = I[1] | I[3] | I[5] | I[7];
assign Y[1] = I[2] | I[3] | I[6] | I[7];
assign Y[2] = I[4] | I[5] | I[6] | I[7];

endmodule

//decoder
module decode3to8(
  input logic [2:0] in,
  output logic [7:0] out
);
always_comb
    case(in)
    3'b001: out = 8'b00000010;
    3'b000: out = 8'b00000001;
    3'b010: out = 8'b00000100;
    3'b011: out = 8'b00001000;
    3'b100: out = 8'b00010000;
    3'b101: out = 8'b00100000;
    3'b110: out = 8'b01000000;
    3'b111: out = 8'b10000000;
    default: out = 8'b00000000;
  endcase


endmodule


module pri_enc(
  input logic [7:0] I,
  output logic [2:0] Y,
  output logic G
);
assign Y =  I[7] ? 3'b111:
            I[6] ? 3'b110:
            I[5] ? 3'b101:
            I[4] ? 3'b100:
            I[3] ? 3'b011:
            I[2] ? 3'b010:
            I[1] ? 3'b001:
            I[0] ? 3'b000:
            3'b000; //nothing
assign G = |I;
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