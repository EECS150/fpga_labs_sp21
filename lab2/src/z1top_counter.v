`timescale 1ns/1ns

module z1top_counter (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  output [5:0] LEDS
);
  assign LEDS[5:4] = 0;

  // Some initial code has been provided for you
  wire [3:0] led_cnt_value;
  wire [3:0] led_cnt_next;
  wire led_cnt_ce;

  assign LEDS[3:0] = led_cnt_value;

  // This register will be updated every one second,
  // and the value will be displayed on the LEDs
  REGISTER_CE #(.N(4)) led_cnt (
    .clk(CLK_125MHZ_FPGA),
    .ce(led_cnt_ce),
    .d(led_cnt_next),
    .q(led_cnt_value));

  assign led_cnt_next = led_cnt_value + 1;

  // TODO: Instantiate another REGISTER module to count the number of cycles
  // required to reach one second. Note that our clock period is 8ns.
  // You also need to think of how many bits are needed for your register

  // TODO: Correct the following assignment
  assign led_cnt_ce = 1'b0;

endmodule
