`include "pwm.sv"

// RGB Fade

module top #(
    parameter CLK_FREQ = 12000000, // number of ticks in one second
    parameter TICKS_PER_CYCLE = CLK_FREQ / 6,
    parameter PWM_INTERVAL = 1024
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_red_value;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_green_value;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_blue_value;
    logic pwm_red_out;
    logic pwm_green_out;
    logic pwm_blue_out;

    
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_red (
        .clk            (clk), 
        .pwm_value      (pwm_red_value), 
        .pwm_out        (pwm_red_out)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_green (
        .clk            (clk), 
        .pwm_value      (pwm_green_value), 
        .pwm_out        (pwm_green_out)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_blue (
        .clk            (clk), 
        .pwm_value      (pwm_blue_value), 
        .pwm_out        (pwm_blue_out)
    );
    
    logic [$clog2(CLK_FREQ) - 1:0] count = '0;
    localparam PWM_MAX = TICKS_PER_CYCLE >> 11;
    localparam PWM_MIN = '0;
    
    initial begin
        // Start with red
        pwm_red_value = PWM_MAX; // full brightness (on)
        pwm_green_value = PWM_MIN; // min brightness (off)
        pwm_blue_value = PWM_MIN; // min brightness (off)
    end

    always_ff @(posedge clk) begin
        if (count >= CLK_FREQ - 1) begin
            count <= 1'b0;
        end else begin
            count <= count + 1'b1;
        end

        if (count <= (1 * TICKS_PER_CYCLE)) begin
            pwm_red_value <= PWM_MAX;
            pwm_green_value <= (count - (TICKS_PER_CYCLE * 0)) >> 11; // ramp up
            pwm_blue_value <= PWM_MIN;
        end
        else if (count <= (2 * TICKS_PER_CYCLE)) begin
            pwm_red_value <= ((2 * TICKS_PER_CYCLE) - count) >> 11; // ramp down
            pwm_green_value <= PWM_MAX;
            pwm_blue_value <= PWM_MIN; 
        end
        else if (count <= (3 * TICKS_PER_CYCLE)) begin
            pwm_red_value <= PWM_MIN;
            pwm_green_value <= PWM_MAX;
            pwm_blue_value <= (count - (TICKS_PER_CYCLE * 2)) >> 11; // ramp up
        end
        else if (count <= (4 * TICKS_PER_CYCLE)) begin
            pwm_red_value <= PWM_MIN;
            pwm_green_value <= ((4 * TICKS_PER_CYCLE) - count) >> 11; // ramp down
            pwm_blue_value <= PWM_MAX;
        end
        else if (count <= (5 * TICKS_PER_CYCLE)) begin
            pwm_red_value <= (count - (TICKS_PER_CYCLE * 4)) >> 11; // ramp up
            pwm_green_value <= PWM_MIN;
            pwm_blue_value <= PWM_MAX;
        end
        else begin
            pwm_red_value <= PWM_MAX;
            pwm_green_value <= PWM_MIN;
            pwm_blue_value <= ((6 * TICKS_PER_CYCLE) - count) >> 11; // ramp down
        end
    end

    // Update outputs, invert since active low LEDs
    assign RGB_R = ~pwm_red_out;
    assign RGB_G = ~pwm_green_out;
    assign RGB_B = ~pwm_blue_out;

endmodule