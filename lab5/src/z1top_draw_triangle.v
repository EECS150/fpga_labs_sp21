`timescale 1ns/1ns

module z1top_draw_triangle (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS,

  output pixel_clk,

  // video signals
  output [23:0] video_out_pData,
  output video_out_pHSync,
  output video_out_pVSync,
  output video_out_pVDE,

  input FPGA_SERIAL_RX,
  output FPGA_SERIAL_TX
);

  wire clk_in1, clk_out1;
  assign pixel_clk = clk_out1;
  assign clk_in1 = CLK_125MHZ_FPGA;

  // TODO: Reduce the PIXEL_CLK_PERIOD to test with higher pixel clock frequency
  // The goal is to meet a pixel clock of 14 ns.
  localparam PIXEL_CLK_PERIOD = 25;

  localparam PIXEL_CLK_FREQ = 1_000_000_000 / PIXEL_CLK_PERIOD;
  // Clocking wizard IP from Vivado (wrapper of the PLLE module)
  // Generate PIXEL_CLK_FREQ clock from 125 MHz clock
  // PLL FREQ = (CLKFBOUT_MULT_F * 1000 / (CLKINx_PERIOD * DIVCLK_DIVIDE) must be within (800.000 MHz - 1600.000 MHz)
  // CLKOUTx_PERIOD = CLKINx_PERIOD x DIVCLK_DIVIDE x CLKOUT0_DIVIDE / CLKFBOUT_MULT_F
  clk_wiz #(
    .CLKIN1_PERIOD(8),
    .CLKFBOUT_MULT_F(8),
    .DIVCLK_DIVIDE(1),
    .CLKOUT0_DIVIDE(PIXEL_CLK_PERIOD)
  ) clk_wiz (
    .clk_out1(clk_out1), // output
    .reset(1'b0),        // input
    .locked(),           // output, unused
    .clk_in1(clk_in1)    // input
  );

  // Button parser
  // Sample the button signal every 500us
  localparam integer B_SAMPLE_CNT_MAX = 0.0005 * PIXEL_CLK_FREQ;
  // The button is considered 'pressed' after 100ms of continuous pressing
  localparam integer B_PULSE_CNT_MAX = 0.100 / 0.0005;

  wire [3:0] buttons_pressed;
  button_parser #(
    .WIDTH(4),
    .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
    .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
  ) bp (
    .clk(pixel_clk),
    .in(BUTTONS),
    .out(buttons_pressed)
  );

  wire reset = (buttons_pressed[0] & SWITCHES[1]);

  wire [7:0] uart_rx_data_out;
  wire uart_rx_data_out_valid;
  wire uart_rx_data_out_ready;

  uart_receiver #(
    .CLOCK_FREQ(PIXEL_CLK_FREQ),
    .BAUD_RATE(115_200)
  ) uart_rx (
    .clk(pixel_clk),
    .rst(reset),
    .data_out(uart_rx_data_out),             // output
    .data_out_valid(uart_rx_data_out_valid), // output
    .data_out_ready(uart_rx_data_out_ready), // input
    .serial_in(FPGA_SERIAL_RX)               // input
  );

  wire [7:0] uart_tx_data_in;
  wire uart_tx_data_in_valid;
  wire uart_tx_data_in_ready;

  uart_transmitter #(
    .CLOCK_FREQ(PIXEL_CLK_FREQ),
    .BAUD_RATE(115_200)
  ) uart_tx (
    .clk(pixel_clk),
    .rst(reset),
    .data_in(uart_tx_data_in),             // input
    .data_in_valid(uart_tx_data_in_valid), // input
    .data_in_ready(uart_tx_data_in_ready), // output
    .serial_out(FPGA_SERIAL_TX)            // output
  );

  assign uart_tx_data_in        = uart_rx_data_out;
  assign uart_tx_data_in_valid  = uart_rx_data_out_valid;
  assign uart_rx_data_out_ready = uart_tx_data_in_ready;

  wire up_key_pressed    = uart_rx_data_out == 8'd119; // w
  wire down_key_pressed  = uart_rx_data_out == 8'd115; // s
  wire left_key_pressed  = uart_rx_data_out == 8'd97;  // a
  wire right_key_pressed = uart_rx_data_out == 8'd100; // d

  wire uart_rx_data_out_fire = uart_rx_data_out_valid & uart_rx_data_out_ready;
  wire up_enable    = up_key_pressed & uart_rx_data_out_fire;
  wire down_enable  = down_key_pressed & uart_rx_data_out_fire;
  wire left_enable  = left_key_pressed & uart_rx_data_out_fire;
  wire right_enable = right_key_pressed & uart_rx_data_out_fire;

  wire [3:0] led_test_value;
  REGISTER_CE #(.N(4)) led_test (
    .q(led_test_value),
    .d({up_enable, down_enable, left_enable, right_enable}),
    .ce(up_enable | down_enable | left_enable | right_enable),
    .clk(pixel_clk)
  );
  assign LEDS[3:0] = led_test_value;

  wire [31:0] up_cnt_value, down_cnt_value, left_cnt_value, right_cnt_value;

  // Move by 5 pixels up/down/left/right
  REGISTER_R_CE #(.N(32), .INIT(0)) up_cnt_reg (
    .q(up_cnt_value),
    .d(up_cnt_value + 5),
    .ce(up_enable),
    .rst(reset),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(32), .INIT(0)) down_cnt_reg (
    .q(down_cnt_value),
    .d(down_cnt_value + 5),
    .ce(down_enable),
    .rst(reset),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(32), .INIT(0)) left_cnt_reg (
    .q(left_cnt_value),
    .d(left_cnt_value + 5),
    .ce(left_enable),
    .rst(reset),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(32), .INIT(0)) right_cnt_reg (
    .q(right_cnt_value),
    .d(right_cnt_value + 5),
    .ce(right_enable),
    .rst(reset),
    .clk(pixel_clk)
  );

  localparam X0 = 500;
  localparam Y0 = 50;
  localparam X1 = 100;
  localparam Y1 = 400;
  localparam X2 = 700;
  localparam Y2 = 300;

  draw_triangle draw_triangle (
    .pixel_clk(pixel_clk),                  // input

    .x0(X0 + right_cnt_value - left_cnt_value), // input
    .y0(Y0 + down_cnt_value  - up_cnt_value),   // input
    .x1(X1 + right_cnt_value - left_cnt_value), // input
    .y1(Y1 + down_cnt_value  - up_cnt_value),   // input
    .x2(X2 + right_cnt_value - left_cnt_value), // input
    .y2(Y2 + down_cnt_value  - up_cnt_value),   // input

    .video_out_pData(video_out_pData),      // output
    .video_out_pHSync(video_out_pHSync),    // output
    .video_out_pVSync(video_out_pVSync),    // output
    .video_out_pVDE(video_out_pVDE)         // output
  );

endmodule
