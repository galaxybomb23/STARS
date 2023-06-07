
//DO NOT MODIFY THIS FILE. YOU MAY ADD TESTCASES AT THE BOTTOM
//The testbench is a system verilog file that will run tests on what you write in your top module and show the results as a waveform on GTKWave. 
//Testbenches are used for "verification" or check the functional correctness of your circuit.
`timescale 1ms/100us
`default_nettype none

module lab_testbench ();

logic CLK, N_RST, ASYNC_IN, SYNC_OUT; //a testbench has no inputs or outputs, the DUT has.
logic [1023:0] testname;

localparam time CLK_PERIOD = 10; // 100Hz clock

sync_low u1(.clk(CLK), .n_rst(N_RST), .async_in(ASYNC_IN), .sync_out(SYNC_OUT)); //create instance of your module and map its inputs and outputs to the tb 

always begin
    CLK = 1'b0; 
    #(CLK_PERIOD / 2); 
    CLK = 1'b1; 
    #(CLK_PERIOD / 2); 
end



initial begin
    $dumpfile ("Lab7b.vcd");
    $dumpvars(0, lab_testbench);

    testname="first test with N_RST value 0";
    ASYNC_IN = 1'b1; N_RST = 1'b0;
    @(posedge CLK); 
    
    
    testname="random test1 with N_RST high";
    @(negedge CLK); 
    ASYNC_IN = 1'b0; N_RST = 1'b1;
    @(posedge CLK);     

    
    testname="random test2 with N_RST high";
    @(negedge CLK); 
    ASYNC_IN = 1'b1; N_RST = 1'b1;
    @(posedge CLK); 
    
    testname="random test3 with N_RST high";
    @(negedge CLK); 
    ASYNC_IN = 1'b0; N_RST = 1'b1;
    @(posedge CLK); 
    
   testname="random test4 with N_RST high";
   @(negedge CLK); 
    ASYNC_IN = 1'b1; N_RST = 1'b1;
    @(posedge CLK); 
    
    testname="random test5 with N_RST high";
    @(negedge CLK); 
    ASYNC_IN = 1'b1; N_RST = 1'b1;
    @(posedge CLK); 
    

    testname="random test6 with N_RST high";
    @(negedge CLK); 
    ASYNC_IN = 1'b0; N_RST = 1'b1;
    @(posedge CLK); 
    
   testname="random test7 with N_RST high";
   @(negedge CLK);
    ASYNC_IN = 1'b1; N_RST = 1'b1;
    @(posedge CLK); 

    
    $finish; 
// add your test cases here
end
endmodule
