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

//5a
//rca_4bit u5(.A(pb[3:0]), .B(pb[7:4]), .Cin(pb[8]), .Sum(right[3:0]), .Cout(right[4]));

//5b
// half_add u1(.a(pb[0]), .b(pb[1]), .sum(right[1]), .cout(right[0]));
// full_add u2(.A(pb[4]), .B(pb[3]), .Cin(pb[2]), .Sum(left[1]), .Cout(left[0]));

full_sub u3(.A(pb[5]), .B(pb[6]), .Bin(pb[7]), .Diff(right[1]), .Bout(right[0]));
comp_4bit u1(.A(pb[3:0]), .B(pb[7:4]), .eq(green), .gr(red), .ls(blue)); 
mul4x4 u4(.A(pb[3:0]), .B(pb[7:4]), .P(left[7:0]));
endmodule

//ripple add module
// module rca_4bit(
//   input logic Cin,
//   input logic [3:0] A, B,
//   output logic Cout,
//   output logic [3:0] Sum
// );
//   logic [2:0] c; // internal carry

//   // 4 full adders
//   full_add fa0(.a(A[0]), .b(B[0]), .cin(Cin), .sum(Sum[0]), .cout(c[0]));
//   full_add fa1(.a(A[1]), .b(B[1]), .cin(c[0]), .sum(Sum[1]), .cout(c[1]));
//   full_add fa3(.a(A[3]), .b(B[3]), .cin(c[2]), .sum(Sum[3]), .cout(Cout));
//   full_add fa2(.a(A[2]), .b(B[2]), .cin(c[1]), .sum(Sum[2]), .cout(c[2]));

//endmodule

// // adder module 
// module full_add(
//   input logic a, b, cin,
//   output logic sum, cout
// );
//   logic p, g; // propagate and generate
    
//   assign p = a ^ b;
//   assign g = a & b;
//   assign sum = p ^ cin;
//   assign cout = g | (p & cin);

// endmodule

// half adder module
// module half_add(
//   input logic a, b,
//   output logic sum, cout
// );
// always_comb begin
//   if (a ^ b) begin
//     sum = 1'b1;
//   end else begin
//     sum = 1'b0;
//   end

//   if (a & b) begin
//     cout = 1'b1;
//   end else begin
//     cout = 1'b0;
//   end
  
// end
// endmodule

// //full adder with if statement
// module full_add(
//   input logic A, B, Cin,
//   output logic Sum, Cout
// );

// always_comb begin
//   if (A ^ B ^ Cin) begin
//     Sum = 1'b1;
//   end else begin
//     Sum = 1'b0;
//   end

//   if ((A & B) | (A & Cin) | (B & Cin)) begin
//     Cout = 1'b1;
//   end else begin
//     Cout = 1'b0;
//   end
// end

// endmodule

//full subtractor using if statement
module full_sub(
  input logic A, B, Bin,
  output logic Diff, Bout
);
always_comb begin
//Difference
  if ((A ^ B) ^ Bin) begin
    Diff = 1'b1;
  end else begin
    Diff = 1'b0;
  end

//Borrow
  if (~A & Bin | ~A & B | Bin & B) begin
    Bout = 1'b1;
  end else begin
    Bout = 1'b0;
  end
end
endmodule

//4 bit comparator
module comp_4bit(
  input logic [3:0] A, B,
  output logic eq, gr, ls
);
always_comb begin
  if (A == B) begin
    eq = 1'b1;
  end else begin
    eq = 1'b0;
  end

  if (A > B) begin
    gr = 1'b1;
  end else begin
    gr = 1'b0;
  end

  if (A < B) begin
    ls = 1'b1;
  end else begin
    ls = 1'b0;
  end
end

endmodule

//4bit multiplier
module mul4x4(
  input logic [3:0] A, B,
  output logic [7:0] P
);
//internal mul var
logic [7:0] PC[3:0];

//assignments
assign PC[0] = {8{B[0]}} & {4'b0,A};
assign PC[1] = {8{B[1]}} & {3'b0,A,1'b0};
assign PC[2] = {8{B[2]}} & {2'b0,A,2'b0};
assign PC[3] = {8{B[3]}} & {1'b0,A,3'b0};

//output
assign P = PC[0] + PC[1] + PC[2] + PC[3];

endmodule
