`timescale 1ns/1ns
`define CLOCK_FREQ 125_000_000

// You should not need to change this file
module z1top_uart_tx (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS,

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

  wire input_A = (buttons_pressed[0] &  SWITCHES[0] & ~SWITCHES[1]);
  wire input_B = (buttons_pressed[1] &  SWITCHES[0] & ~SWITCHES[1]);
  wire input_C = (buttons_pressed[2] &  SWITCHES[0] & ~SWITCHES[1]);
  wire input_D = (buttons_pressed[3] &  SWITCHES[0] & ~SWITCHES[1]);
  wire input_a = (buttons_pressed[0] & ~SWITCHES[0] & ~SWITCHES[1]);
  wire input_b = (buttons_pressed[1] & ~SWITCHES[0] & ~SWITCHES[1]);
  wire input_c = (buttons_pressed[2] & ~SWITCHES[0] & ~SWITCHES[1]);
  wire input_d = (buttons_pressed[3] & ~SWITCHES[0] & ~SWITCHES[1]);

  wire [7:0] button_data = (input_A) ? 8'd65  :
                           (input_B) ? 8'd66  :
                           (input_C) ? 8'd67  :
                           (input_D) ? 8'd68  :
                           (input_a) ? 8'd97  :
                           (input_b) ? 8'd98  :
                           (input_c) ? 8'd99  :
                           (input_d) ? 8'd100 : 8'd0;
  wire button_data_valid = input_A | input_B | input_C | input_D |
                           input_a | input_b | input_c | input_d;

  // Remember the button_data for LEDS display
  wire [7:0] button_data_value;
  REGISTER_CE #(.N(8)) button_data_reg (
    .q(button_data_value),
    .d(button_data),
    .ce(button_data_valid),
    .clk(CLK_125MHZ_FPGA)
  );

  wire [7:0] rdata_out;
  wire rdata_out_valid, rdata_out_ready;

  read_rom read_rom (
    .clk(CLK_125MHZ_FPGA),
    .rst(rst),
    .read_en(SWITCHES[1]),

    .rdata_out(rdata_out),             // output
    .rdata_out_valid(rdata_out_valid), // output
    .rdata_out_ready(rdata_out_ready)  // input
  );

  wire [7:0] uart_tx_data_in;
  wire uart_tx_data_in_valid;
  wire uart_tx_data_in_ready;

  uart_transmitter #(
    .CLOCK_FREQ(`CLOCK_FREQ),
    .BAUD_RATE(115_200)
  ) uart_tx (
    .clk(CLK_125MHZ_FPGA),
    .rst(rst),
    .data_in(uart_tx_data_in),             // input
    .data_in_valid(uart_tx_data_in_valid), // input
    .data_in_ready(uart_tx_data_in_ready), // output

    .serial_out(FPGA_SERIAL_TX)            // output
  );

  assign uart_tx_data_in       = (SWITCHES[1]) ? rdata_out       : button_data;
  assign uart_tx_data_in_valid = (SWITCHES[1]) ? rdata_out_valid : button_data_valid;
  assign rdata_out_ready       = uart_tx_data_in_ready;

  assign LEDS[3:0] = (~SWITCHES[0]) ? button_data_value[3:0] : button_data_value[7:4];
  assign LEDS[5:4] = 2'b11;

endmodule
