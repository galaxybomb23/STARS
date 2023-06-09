`default_nettype 
///FPGA BREAKOUT BOARD TEST MODULE///
//- By Eli Jorgensen

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
logic hz25;
logic [15:0] snake_reg_3;
logic [3:0]  snake_ctr_3;
logic [6:0]  snake_reg_3_display;

clkdiv clkdiv_25 (
  .clk(hz100),
  .rst(reset),
  .lim(8'd4),
  .hzX(hz25)
);

ssdec ssd3 (
    .in(snake_ctr_3),
    .enable(1),
    .out(snake_reg_3_display)

  );
RingCounter #(16,8) RingCounter_3 (
   .clk(hz25),
   .reset(reset),
   .out_reg(snake_reg_3)
 );

always_ff @(posedge hz25, posedge reset) begin
  if (reset)begin
    snake_ctr_3 <= 4'b0;
  end
  else begin
    snake_ctr_3 <= snake_ctr_3 + 1;
  end
end


always_comb begin
    right= snake_reg_3[7:0];
    left[7] = snake_reg_3[0];
    left[6] = snake_reg_3[1];
    left[5] = snake_reg_3[2];
    left[4] = snake_reg_3[3];
    left[3] = snake_reg_3[4];
    left[2] = snake_reg_3[5];
    left[1] = snake_reg_3[6];
    left[0] = snake_reg_3[7];
    green = snake_reg_3[8];
    red = snake_reg_3[9];
    blue = snake_reg_3[10];
    ss0[6:0] = snake_reg_3_display;
    ss1[6:0] = snake_reg_3_display;
    ss2[6:0] = snake_reg_3_display;
    ss3[6:0] = snake_reg_3_display;
    ss4[6:0] = snake_reg_3_display;
    ss5[6:0] = snake_reg_3_display;
    ss6[6:0] = snake_reg_3_display;
    ss7[6:0] = snake_reg_3_display;
end

endmodule
//RING COUNTER //SEQUENCER
  module RingCounter #(
    parameter REGLEN = 60,
    parameter SNKLEN = 4
  )(
    input wire clk,
    input wire reset,
    output wire [REGLEN-1:0] out_reg
  );

    logic [REGLEN-1:0] temp_reg;
    logic [SNKLEN-1:0] temp_shift;

    always @(posedge clk or posedge reset) begin
      if (reset) begin
        temp_reg <= '0;
        temp_shift <= '1;
        end
      else begin
        if(|temp_shift) begin
          temp_reg <= {temp_reg[REGLEN-2:0],1'b1};
          temp_shift <= {temp_shift[SNKLEN-2:0],1'b0};
        end
        else begin
          temp_reg <= {temp_reg[REGLEN-2:0],temp_reg[REGLEN-1]};
        end

      end
    end

    assign out_reg = temp_reg;

  endmodule

  /// CLOCK DIVIDER ///
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


/// SSDEC ///
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