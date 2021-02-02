`timescale 1ns/1ns
`define CLOCK_FREQ 125_000_000

// TODO: modify the following code to use BTN2 to run or stop your counter
module z1top_mode_counter (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);
  assign LEDS[5:4] = 2'b11;

  // Button parser test circuit
  // Sample the button signal every 500us
  localparam integer B_SAMPLE_CNT_MAX = 0.0005 * `CLOCK_FREQ;
  // The button is considered 'pressed' after 100ms of continuous pressing
  localparam integer B_PULSE_CNT_MAX = 0.100 / 0.0005;

  wire [3:0] buttons_pressed;
  button_parser #(
    .WIDTH(4),
    .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
    .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
  ) bp (
    .clk(CLK_125MHZ_FPGA),
    .in(BUTTONS),
    .out(buttons_pressed));

  wire [3:0] led_cnt_value, led_cnt_next;
  wire led_cnt_rst;

  assign LEDS[3:0] = led_cnt_value;
  assign led_cnt_next = (buttons_pressed[0] == 1) ? led_cnt_value + 1 :
                        (buttons_pressed[1] == 1) ? led_cnt_value - 1 :
                                                    led_cnt_value;
  assign led_cnt_rst = (buttons_pressed[3] == 1);

  REGISTER_R #(.N(4), .INIT(0)) led_cnt (
    .q(led_cnt_value),
    .d(led_cnt_next),
    .rst(led_cnt_rst),
    .clk(CLK_125MHZ_FPGA));

endmodule
