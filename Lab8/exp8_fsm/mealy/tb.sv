//ADD YOUR TESTCASES AT BOTTOM

module lab_testbench ();

logic CLK, N_RST, I, O;

mealy u1 (.clk(CLK), .n_rst(N_RST), .i(I), .o(O));
logic [1023:0] testname;

task automatic clock(integer n);
    while (n != 0) begin
        CLK = 1'b1;
        #1;
        CLK = 1'b0;
        #1;
        n--;
    end
endtask //automatic clk

initial begin
    $dumpfile ("mealy.vcd");
    $dumpvars (0, lab_testbench);
    
    testname="first test with N_RST value 0";
    I = 1'b1; N_RST = 1'b0; CLK = 1'b0;
clock(1);
    #0.25;
    testname="random test1 with N_RST high";
    I = 1'b0; N_RST = 1'b1; CLK=1'b1;
clock(1);
    #0.25;
    testname="random test2 with N_RST high";
    I = 1'b1; N_RST = 1'b1;
clock(1);
    #0.25;
    testname="random test3 with N_RST high";
   I = 1'b1; N_RST = 1'b1;
clock(1);
    #0.25;
   testname="random test4 with N_RST high";
    I = 1'b0; N_RST = 1'b1;
clock(1);
    #0.25;
    testname="random test5 with N_RST high";
    I = 1'b1; N_RST = 1'b1;
clock(1);
// add test case for 11011011010
    testname="test case for 11011011010";
    // set N_RST to high
    N_RST = 1'b1;

    //feed in 11011011010
    I = 1'b1; #0.25; clock(1);
    I = 1'b1; #0.25; clock(1);
    I = 1'b0; #0.25; clock(1);
    I = 1'b1; #0.25; clock(1);
    I = 1'b1; #0.25; clock(1);
    I = 1'b0; #0.25; clock(1);
    I = 1'b1; #0.25; clock(1);
    I = 1'b1; #0.25; clock(1);
    I = 1'b0; #0.25; clock(1);
    I = 1'b1; #0.25; clock(1);
    I = 1'b0; #0.25; clock(1);


end
endmodule
