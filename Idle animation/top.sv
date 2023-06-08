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
  logic hzX, hz2;
  logic [7:0] divider;
  logic [1:0] green_reg;
  logic [2:0] ctrl;


  //snake registers
  logic [59:0] snake_reg_0;
  logic [43:0] snake_reg_1;
  logic [7:0]  snake_reg_2;
  

  //clock divider X
  clkdiv u1 (
    .clk(hz100),
    .rst(reset),
    .lim(divider),
    .hzX(hzX)
  );
  //clock divider 2
  clkdiv u2 (
    .clk(hzX),
    .rst(reset),
    .lim(8'd1),
    .hzX(hz2)
  );

  //snake 1 60reg,4bit
  RingCounter RingCounter (
    .clk(hzX),
    .reset(reset),
    .snake_reg(snake_reg_0)
  );

  //snake 2 44reg,4bit
  RingCounter #(44,6)RingCounter_1 (
    .clk(hzX),
    .reset(reset),
    .snake_reg(snake_reg_1)
  );

  //snake 3 4reg,2bit
  RingCounter #(8,4) RingCounter_2 (
    .clk(hzX),
    .reset(reset),
    .snake_reg(snake_reg_2)
  );

  //snake multiplexer
  always_ff @ (posedge hz2, posedge reset) begin
    if (reset) begin
      ctrl <= 3'b0;
      divider <= 8'd2;
    end
    else if (pb[8])
      if (divider >= 8'd19)
        divider <= 8'd20;
      else
        divider <= divider + 2;
    else if (pb[11])
      if (divider <= 8'b00000010)
        divider <= 8'b00000000;
      else
        divider <= divider - 2;
    else 
      case ({pb[7:0]})
        8'b00000001: ctrl <= 3'b000;
        8'b00000010: ctrl <= 3'b001;
        8'b00000100: ctrl <= 3'b010;
        8'b00001000: ctrl <= 3'b011;
        8'b00010000: ctrl <= 3'b100;
        8'b00100000: ctrl <= 3'b101;
        8'b01000000: ctrl <= 3'b110;
        8'b10000000: ctrl <= 3'b111;
        default: ctrl <= ctrl;
      endcase

    
  end 
  always_comb begin
    {ss0, ss1, ss2, ss3, ss4, ss5, ss6, ss7, left, right, red, green_reg, blue} = 0;
    case (ctrl)
      0: { //design 1
          ss0[7],
          right[0], right[1], right[2], right[3], right[4], right[5], right[6], right[7],
          red, green_reg[0], blue, left[0], left[1], left[2],left[3], left[4], left[5], left[6], left[7],
          ss7[6], ss6[6], ss5[6], ss4[6], ss3[6], ss2[6], ss1[6], 
          ss0[6],ss0[2],ss0[3],
          ss1[2],ss1[1],ss1[0],
          ss2[1],ss2[2],ss2[3],
          ss3[2],ss3[1],ss3[0],
          ss4[1],ss4[2],ss4[3],
          ss5[2],ss5[1],ss5[0],
          ss6[1],ss6[2],ss6[3],
          ss7[2],ss7[1],ss7[0],
          ss7[5],ss7[4],ss7[7],ss6[7],ss5[7],ss4[7],ss3[7],ss2[7],ss1[7]} = snake_reg_0;
      1:  // design 2
        {
          //snake
          ss0[2], ss7[4],
          ss0[1], ss7[5],
          ss0[0], ss7[0],
          ss1[0], ss6[0],
          ss1[5], ss6[1],
          ss1[4], ss6[2],
          ss2[3], ss5[3],
          ss2[4], ss5[2],
          ss2[5], ss5[1],
          ss3[0], ss4[0],
          ss3[5], ss4[1],
          ss3[4], ss4[2],
          green_reg[1], green_reg[0],
          blue, red,
          left[0], right[7],
          left[1], right[6],
          left[2], right[5],
          left[3], right[4],
          left[4], right[3],
          left[5], right[2],
          left[6], right[1],
          left[7], right[0]
                            } = snake_reg_1;
      2: begin
          {right,left,red} = snake_reg_2[0] ? 17'b11111111111111111: 0;
          {ss0[7], ss0[3], ss1[7], ss1[3],  ss2[7], ss2[3], ss3[7], ss3[3], ss4[7], ss4[3], ss5[7], ss5[3], ss6[7], ss6[3], ss7[7], ss7[3]} = snake_reg_2[1] ? 16'b1111111111111111: 0;
          {ss0[6], ss1[6], ss2[6], ss3[6], ss4[6], ss5[6], ss6[6], ss7[6]} = snake_reg_2[2] ? 8'b11111111: 0;
          {ss0[0], ss1[0], ss2[0], ss3[0], ss4[0], ss5[0], ss6[0], ss7[0]} = snake_reg_2[3] ? 8'b11111111: 0;

        end
          
        default: red = 1;
    endcase
  end

 assign green = (|green_reg);

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

  //
  module RingCounter #(
    parameter REGLEN = 60,
    parameter SNKLEN = 4
  )(
    input wire clk,
    input wire reset,
    output wire [REGLEN-1:0] snake_reg
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

    assign snake_reg = temp_reg;

  endmodule

// module pwm #(
//     parameter int CTRVAL = 256,
//     parameter int CTRLEN = $clog2(CTRVAL)
// )
// (
//     input logic clk, rst, enable,
//     input logic [CTRLEN-1:0] duty_cycle,
//     //output logic [CTRLEN-1:0] counter,
//     output logic pwm_out
// );

//   // Internal register to hold the counter value
//   logic [CTRLEN-1:0] counter_reg;

//   always_ff @ (posedge clk, posedge rst)
//   begin
//     if (rst) // Asynchronous reset
//       counter_reg <= 0;
//     else if (enable) // Only increment if enable is high
//       counter_reg <= counter_reg + 1;
//   end
  
//   // Assign the counter output
//  // assign counter = counter_reg;
  
//   // Assign the PWM output
//   assign pwm_out = (counter_reg <= duty_cycle);

// endmodule


// Add more modules down here...