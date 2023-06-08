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
    assign rst = pb[3];
    

    typedef enum logic [3:0] {S0,S1,S2,S3,S4,S5,S6} state_t;
    state_t state, next_state;

    //Register input
    always_ff @(posedge hz100, posedge rst) begin
      if (rst) begin
        in <= 0;
      end else begin
        if (pb[0]) begin
          in <= 0;
        end else if (pb[1]) begin
          in <= 1;
        end
        else if( pb[2])
          clk <= 1;
        else
          clk <= 0;
      end
    end

    //update state
    always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
        state <= S0;
      end else begin
        state <= next_state;
      end
    end


    //next state logic
    always_comb begin : next_state_logic
      case(state)
        S0: next_state = in ? S1 : S0;
        S1: next_state = in ? S1 : S2;
        S2: next_state = in ? S3 : S0;
        S3: next_state = in ? S1 : S4;
        S4: next_state = in ? S5 : S4;
        S5: next_state = in ? S6 : S2;
        S6: next_state = in ? S1 : S2;
        default: next_state = S0;
      endcase
    end

    //output logic
    always_comb begin : output_logic
      if (state == S6) begin
        green = 1;
        red = 0;
        //show open
        ss5 = 8'b00111111; //O
        ss4 = 8'b01110011; //P
        ss3 = 8'b01111001; //E
        ss2 = 8'b00110111; //N

      end
      else begin
        green = 0;
        red = 1;
        //show lock
        ss5 = 8'b00111000; //L
        ss4 = 8'b00111111;; //O
        ss3 = 8'b00111001; //C
        ss2 = 8'b01110000; //K
      end
    end

  //show state and next state
  ssdec ssdec0(.in(state), .enable(1'b1), .out(ss7[6:0]));
  ssdec ssdec1(.in(next_state), .enable(1'b1), .out(ss0[6:0]));
  assign ss7[7] = in;
    

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