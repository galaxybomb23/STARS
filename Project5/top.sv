`default_nettype none
// Verified by Spencer

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
logic [3:0] A,B;
logic [2:0] Ctl;
logic En,Cin;


assign A = pb[7:4];
assign B = pb[3:0];
assign Ctl = pb[10:8];
assign Cin = pb[12];
// 4-bit ALU
ALU4bit alu(
  .En(En),
  .Ctrl(Ctl),
  .Cin(Cin),
  .A(A),
  .B(B),
  .M(left[3:0]),
  .S(left[6]),
  .O(ss7[7]),
  .Cout(ss6[7])
);
  
assign green = En;
assign blue = Cin;
ssdec u1(.in(left[3:0]),.enable(1),.out(ss7[6:0]));
ssdec u2(.in(A),.enable(1),.out(ss3[6:0]));
ssdec u3(.in(B),.enable(1),.out(ss1[6:0]));
ssdec u4(.in({1'b0,Ctl}),.enable(1),.out(ss5[6:0]));

always_ff @(posedge hz100) begin : blockName
  if (pb[15])
    En = ~En;
  else
    En = En;
end



endmodule

// 4 bit ALU
module ALU4bit(
  input logic En, // Enable
  input logic [2:0] Ctrl, // Control
  input logic Cin, // Carry in
  input logic [3:0] A, B, // 4bit signed input
  output logic [3:0] M, // 4-bit output [sign, 2:0]
  output logic S, // Sign
  output logic O, // Overflow
  output logic Cout // Carry out
);

always_comb begin
  if(En) begin
    case(Ctrl)
      3'b000: {M} = A + B + {3'b0,Cin}; // Addition
      3'b001: {M} = A - B + {3'b0,Cin}; // Subtraction
      3'b010: M = ~A;               // Bitwise NOT
      3'b011: M = A & B;            // Bitwise AND
      3'b100: M = A | B;            // Bitwise OR
      3'b101: M = A ^ B;            // Bitwise XOR
      3'b110: M = A << 1;           // A multiplied by 2
      3'b111: M = A >> 1;           // A divided by 2
      default: M = 4'bxxxx;
    endcase
    S = M[3];
    O = (A[3] & B[3] & ~M[3]) | (~A[3] & ~B[3] & M[3]);
    Cout = (Ctrl == 3'b000 & (A[2] & B[2] | A[2] & Cin | B[2] & Cin)) || (
           (Ctrl == 3'b110 & A[3]));
  end
  else begin
    M = 4'b0000;
    S = 1'b0;
    O = 1'b0;
    Cout = 1'b0;
  end
end


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

//al who?