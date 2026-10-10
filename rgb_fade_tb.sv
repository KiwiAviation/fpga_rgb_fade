`timescale 1ns/1ps
`include "rgb_fade.sv"

module rgb_fade_tb;

    parameter CLK_FREQ = 12000000;
    parameter TICKS_PER_CYCLE = CLK_FREQ / 6;
    parameter PWM_INTERVAL = 1024;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    top #(
        .CLK_FREQ        (CLK_FREQ),
        .TICKS_PER_CYCLE (TICKS_PER_CYCLE),
        .PWM_INTERVAL    (PWM_INTERVAL)
    ) u0 (
        .clk             (clk), 
        .RGB_R           (RGB_R),
        .RGB_G           (RGB_G),
        .RGB_B           (RGB_B)
    );

    // Exact 12.0 MHz clock (83.333ns period: 41.667ns HIGH, 41.667ns LOW)
    always begin
        #41.667 clk = ~clk;
    end

    initial begin
        $dumpfile("rgb_fade.vcd");
        $dumpvars(0, rgb_fade_tb);
        
        // 1 full second in 1ns timescale = 1,000,000,000 ns (plus a bit extra to see the wrap)
        #1050000000;
        $finish;
    end

endmodule