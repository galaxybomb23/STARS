
//DO NOT MODIFY THIS FILE. YOU MAY ADD TESTCASES AT THE BOTTOM
//The testbench is a system verilog file that will run tests on what you write in your top module and show the results as a waveform on GTKWave. 
//Testbenches are used for "verification" or check the functional correctness of your circuit.

module lab_testbench ();

logic CLK, N_RST, D_IN, D_OUT; //a testbench has no inputs or outputs, the DUT has.
logic [1023:0] testname;

d_ff u1(.clk(CLK), .n_rst(N_RST), .d_in(D_IN), .d_out(D_OUT)); //create instance of your module and map its inputs and outputs to the tb 

task automatic clock(integer n);
    while (n != 0) begin
        CLK = 1'b1;
        #1;
        CLK = 1'b0;
        #1;
        n--;
    end
endtask //automatic clk generation

initial begin
    $dumpfile ("Lab7a.vcd");
    $dumpvars (0, lab_testbench);
    
    testname="first test with N_RST value 0";
    D_IN = 1'b1; N_RST = 1'b0; CLK = 1'b0;
clock(1);
    #0.25;
    testname="random test1 with N_RST high";
    D_IN = 1'b0; N_RST = 1'b1; CLK=1'b1;
clock(1);
    #0.25;
    testname="random test2 with N_RST high";
    D_IN = 1'b1; N_RST = 1'b1;
clock(1);
    #0.25;
    testname="random test3 with N_RST high";
    D_IN = 1'b0; N_RST = 1'b1;
clock(1);
    #0.25;
   testname="random test4 with N_RST high";
    D_IN = 1'b1; N_RST = 1'b1;
clock(1);
    #0.25;
    testname="random test5 with N_RST high";
    D_IN = 1'b1; N_RST = 1'b1;
clock(1);
    #0.25;
    testname="random test6 with N_RST high";
    D_IN = 1'b0; N_RST = 1'b1;
clock(1);
    #0.25;
   testname="random test7 with N_RST high";
    D_IN = 1'b1; N_RST = 1'b1;
clock(1);

// add your test cases here
end
endmodule
