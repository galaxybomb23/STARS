`default_nettype none

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

count8du u1(.CLK(hz100), .RST(reset), .Q(right), .DIR(pb[0]), .MAX(8'd99), .E(1'b1));
  
endmodule

//countup module
module count8du(
  input logic CLK, RST, DIR, E,
  input logic [7:0] MAX,
  output logic [7:0] Q
);
logic [7:0] next_Q;

// fsm
always_ff @(posedge CLK, posedge RST)
  if (RST)
    Q <= 0;
  else if (E) begin
    Q <= next_Q;
    if (Q == MAX && DIR)
      Q <= 0;
    else if (Q == 8'd0 && ~DIR)
      Q <= 8'd99;
    else
      Q <= next_Q;
  end else begin
    Q <= Q;
  end

// next state logic
always_comb begin
  if(RST)
    next_Q = 0;
  else if (DIR) begin // count up
    next_Q[0] = ~Q[0];
    next_Q[1] = Q[1] ^ Q[0];
    next_Q[2] = Q[2] ^ &Q[1:0];
    next_Q[3] = Q[3] ^ &Q[2:0];
    next_Q[4] = Q[4] ^ &Q[3:0];
    next_Q[5] = Q[5] ^ &Q[4:0];
    next_Q[6] = Q[6] ^ &Q[5:0];
    next_Q[7] = Q[7] ^ &Q[6:0];
  end
  else begin//count down
    next_Q[0] = ~Q[0];
    next_Q[1]=Q[1]^ ~Q[0];    
    next_Q[2]=Q[2]^( ~Q[1]& ~Q[0]);     
    next_Q[3]=Q[3]^( ~Q[2]& ~Q[1]& ~Q[0]);  
    next_Q[4]=Q[4]^( ~Q[3]& ~Q[2]& ~Q[1]& ~Q[0]);    
    next_Q[5]=Q[5]^( ~Q[4]& ~Q[3]& ~Q[2]& ~Q[1]& ~Q[0]);  
    next_Q[6]=Q[6]^( ~Q[5]& ~Q[4]& ~Q[3]& ~Q[2]& ~Q[1]& ~Q[0]);  
    next_Q[7]=Q[7]^( ~Q[6]& ~Q[5]& ~Q[4]& ~Q[3]& ~Q[2]& ~Q[1]& ~Q[0]); 
    end
end  

endmodule
