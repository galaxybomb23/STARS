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

  

endmodule

// 4 bit ALU
module ALU4bit(
  input logic En, // Enable
  input logic [2:0] Ctrl, // Control
  input logic Cin, // Carry in
  input logic [3:0] A, B, // Inputs
  output logic [3:0] M, // 4-bit output
  output logic S, // Sign
  output logic O, // Overflow
  output logic Cout // Carry out
);

always_comb begin
  if(En) begin
    case(Ctrl)
      3'b000: M = A + B + {4{Cin}}; // Addition
      3'b001: M = A - B + {4{Cin}}; // Subtraction
      3'b010: M = ~A;               // Bitwise NOT
      3'b011: M = A & B;            // Bitwise AND
      3'b100: M = A | B;            // Bitwise OR
      3'b101: M = A ^ B;            // Bitwise XOR
      3'b110: M = A << 2;           // A multiplied by 2
      3'b111: M = A >> 2;           // A divided by 2
      default: M = 4'bxxxx;
    endcase
    S = M[3];
    O = (A[3] == B[3]) && (A[3] != M[3]);
    Cout = (Ctrl == 3'b101 && (A[3] & B[3])) || (Ctrl == 3'b110 && (A[3] | B[3]));
  end
  else begin
    M = 4'bxxxx;
    S = 1'bx;
    O = 1'bx;
    Cout = 1'bx;
  end
end


endmodule