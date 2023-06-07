`timescale 1ms/10us
module lab_testbench ();
//make clock signal

always begin
    clk = #5 ~clk; //invert clock every 5ns
end

logic clk, hz4, hz12, hz25, reset;

//instance of the clock generator
  //100hz to 13hz /div 8
  clkdiv u2(
    .clk(clk),
    .rst(reset),
    .lim(8'd3),
    .hzX(hz12)
  );

  // 100hz to 10hz div  10
  clkdiv u1(
    .clk(clk),
    .rst(reset),
    .lim(8'd4),
    .hzX(hz10)
  );

  //100hz to 4hz /div 25
  clkdiv u3(
    .clk(clk),
    .rst(reset),
    .lim(8'd12),
    .hzX(hz25)
  );


initial begin
    $dumpfile("lab_testbench.vcd");
    $dumpvars(0,lab_testbench);
    reset = 1;
    #10 reset = 0;
    #1000 $finish;
end

endmodule