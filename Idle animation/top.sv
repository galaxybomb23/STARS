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
logic hz4; 
logic [5:0] ctr;
logic [50:0] snake_reg;
clkdiv2 clkdiv2 (
  .clk(hz100),
  .reset(reset),
  .clk2(hz4)
);
RingCounter RingCounter (
  .clk(hz4),
  .reset(reset),
  .snake_reg(snake_reg)
);
// always_ff @(posedge hz4, posedge reset) begin : iter

//   if(reset) begin
//     ctr <= 0;
//     snake_reg <= 30'b0;
//   end else begin
//   if(hz4) begin
//     if(ctr < 4 || snake_reg[29]) begin //load bits
//       snake_reg <= {snake_reg[28:0],1'b1};
//     end else begin
//       snake_reg <= {snake_reg[28:0],1'b0};
//     end
//     ctr <= ctr + 1;
//   end
//   else begin
//     snake_reg <= snake_reg;
//   end

//   //{ss0[1:3],ss1[3:0],ss2[1:3],ss3[3:0],ss4[1:3],ss5[3:0],ss6[1:3],ss7[3:0],ss7[5:4],ss7[7],ss6[7],ss5[7], ss4[7],ss3[7],ss2[7],ss1[7],ss0[7]} <= snake_reg;
//   // rewrite above line using bit refrence only

//   end
// end
assign   {
   red, green, blue, left[0], left[1], left[2],left[3], left[4], left[5], left[6], left[7],
   ss7[6], ss6[6], ss5[6], ss4[6], ss3[6], ss2[6], ss1[6], 
   ss0[6],ss0[2],ss0[3],
   ss1[2],ss1[1],ss1[0],
   ss2[1],ss2[2],ss2[3],
   ss3[2],ss3[1],ss3[0],
   ss4[1],ss4[2],ss4[3],
   ss5[2],ss5[1],ss5[0],
   ss6[1],ss6[2],ss6[3],
   ss7[2],ss7[1],ss7[0],
   ss7[5],ss7[4],ss7[7],ss6[7],ss5[7],ss4[7],ss3[7],ss2[7],ss1[7]} = snake_reg;


endmodule

// make the clock divider from 100hz to 4hz
module clkdiv2 (
  input  logic clk,
  input  logic reset,
  output logic clk2
);

  logic [7:0] counter;

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      clk2 <= 1'b0;
    end else begin
      if (counter == 8'd2) begin // 100hz / 50 = 2hz
        clk2 <= ~clk2;
        counter <= 8'd0;
      end else begin
        counter <= counter + 1;
      end
    end
  end
endmodule

//
module RingCounter (
  input wire clk,
  input wire reset,
  output wire [50:0] snake_reg
);

  reg [3:0] counter;
  reg [50:0] temp_reg;

  always @(posedge clk or posedge reset) begin
    if (reset)
      counter <= 4'b0;
    else if (counter == 4'b1111)
      counter <= 4'b0;
    else
      counter <= counter + 1;
    
    temp_reg <= {temp_reg[49:0], counter[3]};
  end

  assign snake_reg = temp_reg;

endmodule
