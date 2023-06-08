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
  ); // design a combinational lock looking for 101011

    //init states
    logic in, clk, rst;
    logic [5:0] password, buffer;
    assign rst = pb[3];
    

    typedef enum logic [3:0] {S0,S1,S2,S3,S4,S5,S6} state_t;
    state_t state, next_state;

    typedef enum logic [1:0] {EDIT,LOCK} mode_t;
    mode_t mode, next_mode;

    //Register input
    always_ff @(posedge hz100, posedge rst) begin
      if (rst) begin
        in <= 0;
        clk <= 0;
      end else begin
        //input logic
        if (pb[0]) begin //0
          in <= 0;
          clk <= 1;
        end else if (pb[1]) begin //1
          in <= 1;
          clk <= 1;
        end
        else if (pb[4]) begin//lock mode
          clk <= 1;
        end
        else if (pb[2]) begin //clk
          clk <= 1;
        end
        else
          clk <= 0;
      end
    end

    //buffer and password ff
    always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
        password <= 6'b000000;
        buffer <= 6'b000000;

      end else begin
        if (mode == EDIT) begin
          password <= {password[4:0], in};
          buffer <= 6'b000000;
        end
        else begin 
          buffer <= {buffer[4:0], in};
          end
      end
    end

    //state logic
    always_ff @( posedge clk, posedge rst ) begin : state_logic
      if (rst)
        mode<= EDIT;
      else 
        if (pb[4])
          mode <= LOCK;
        else
          mode <= next_mode;
      
    end

    //next state logic
    always_comb begin : next_state_logic
      if (mode == LOCK && buffer == password) begin
        next_mode = EDIT;
      end
      else
        next_mode = mode;

      green = mode == EDIT;
      red = mode == LOCK;
    end

  //show password
  disp1 disp0(.pass(password), .buff(buffer), .mode(mode), .rst(rst), .out0(ss0), .out1(ss1), .out2(ss2), .out3(ss3), .out4(ss4), .out5(ss5));
  assign ss7[7] = in;
  assign ss6[7] = clk;
  assign ss7[6:0] = (mode == EDIT) ? 7'b0111111 : 7'b0111000;

  endmodule

  module disp1(
    input logic [5:0] pass, buff,
    input logic [1:0] mode,
    input logic rst,
    output logic [7:0] out0, out1, out2, out3, out4, out5
  );

  always_comb begin
    if(rst) begin
      out0 = 8'b00000000;
      out1 = 8'b00000000;
      out2 = 8'b00000000;
      out3 = 8'b00000000;
      out4 = 8'b00000000;
      out5 = 8'b00000000;
    end
    else begin
     if (|mode) begin //lock
      out0 = buff[0] ? 8'b00000110 : 8'b00111111;
      out1 = buff[1] ? 8'b00000110 : 8'b00111111;
      out2 = buff[2] ? 8'b00000110 : 8'b00111111;
      out3 = buff[3] ? 8'b00000110 : 8'b00111111;
      out4 = buff[4] ? 8'b00000110 : 8'b00111111;
      out5 = buff[5] ? 8'b00000110 : 8'b00111111;
    end
    else begin
      out0 = pass[0] ? 8'b00000110 : 8'b00111111;
      out1 = pass[1] ? 8'b00000110 : 8'b00111111;
      out2 = pass[2] ? 8'b00000110 : 8'b00111111;
      out3 = pass[3] ? 8'b00000110 : 8'b00111111;
      out4 = pass[4] ? 8'b00000110 : 8'b00111111;
      out5 = pass[5] ? 8'b00000110 : 8'b00111111;
    end
    end
    
  end
  endmodule