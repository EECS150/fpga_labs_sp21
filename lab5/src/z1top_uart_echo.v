`timescale 1ns/1ns
`define CLOCK_FREQ 125_000_000

// You should not need to change this file
module z1top_uart_echo (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS,

  input  FPGA_SERIAL_RX,
  output FPGA_SERIAL_TX
);

  // Button parser
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
    .out(buttons_pressed)
  );

  wire rst = (buttons_pressed[0] & SWITCHES[1]);

  uart #(
    .CLOCK_FREQ(`CLOCK_FREQ),
    .BAUD_RATE(115_200)
  ) UART (
    .clk(CLK_125MHZ_FPGA),
    .rst(rst),
    .serial_in(FPGA_SERIAL_RX), // input
    .serial_out(FPGA_SERIAL_TX) // output
  );

  assign LEDS[5:4] = 2'b11;

endmodule
