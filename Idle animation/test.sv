    `default_nettype none
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
    logic [15:0] regis;
    logic [3:0]  ctr;
    logic [3:0]  next_ctr;
    logic [6:0]  reg_display;
    logic enable;

    clkdiv clkdiv_25 (
    .clk(hz100),
    .rst(reset),
    .lim(8'd4),
    .hzX(enable)
    );

    ssdec ssd3 (
        .in(ctr),
        .enable(1),
        .out(reg_display)

    );
    RingCounter #(16,8) RingCounter (
    .clk(enable),
    .reset(reset),
    .out_reg(regis)
    );

    always_ff @(posedge hz100, posedge reset) begin
    if (reset)begin
        ctr <= 4'b0;
    end
    else begin
        ctr <= next_ctr;
    end
    end


    always_comb begin
        if (enable)
            next_ctr = ctr + 1;
        else
            next_ctr = ctr;


        right= regis[7:0];
        left[7] = regis[0];
        left[6] = regis[1];
        left[5] = regis[2];
        left[4] = regis[3];
        left[3] = regis[4];
        left[2] = regis[5];
        left[1] = regis[6];
        left[0] = regis[7];
        green = regis[8];
        red = regis[9];
        blue = regis[10];
        ss0[6:0] = reg_display;
        ss1[6:0] = reg_display;
        ss2[6:0] = reg_display;
        ss3[6:0] = reg_display;
        ss4[6:0] = reg_display;
        ss5[6:0] = reg_display;
        ss6[6:0] = reg_display;
        ss7[6:0] = reg_display;
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
        input logic enable,
        output logic hzX
    );
        logic [BITLEN-1:0] next_cnt;
        logic [BITLEN-1:0] cnt;

        always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
            hzX <= 0;
        end
        else begin
            cnt <= next_cnt;
            hzX <= ~hzX;
        end
        end

        always_comb begin
            next_cnt =0;
            if (enable) begin
                next_cnt = cnt + 1;
                if (cnt == lim) begin
                    next_cnt = 0;
                end 
            else
                next_cnt = cnt;
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