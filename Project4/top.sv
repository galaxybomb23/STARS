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
logic [3:0] error; // Errors [3:0] = [High Priority, Low Priority, low, low]
logic status; // high == error, low == no error
assign error[3:0] = pb[3:0];

//dataflow (the best way)
assign status = (|error[1:0] & error[2]) | error[3];

/* structual
logic ic0,ic1;

or(ic0,error[1],error[0])
and(ic1,ic0,error[2])
or(status,ic1,error[3])
*/

/* behavioral
always_comb 
  if ((|error[1:0] & error[2]) | error[3]) 
    status = 1'b1;
  else 
    status = 1'b0;
*/




//assign displays to read error
//behavioral
always_comb begin
  if(status) begin
    ss7[6:0] = 7'b1111001;//e
    ss6[6:0] = 7'b0110001;//r
    ss5[6:0] = 7'b0110001;//r
    ss4[6:0] = 7'b0111111;//0
    ss3[6:0] = 7'b0110001;//r
  end
  else begin
    ss7[6:0] = 7'b0110001; //r
    ss6[6:0] = 7'b0111110; //u
    ss5[6:0] = 7'b0110111; //n
    ss4[6:0] = 0; //blank
    ss3[6:0] = 0;
  end
end
assign red = status;
assign green = ~status;


endmodule
