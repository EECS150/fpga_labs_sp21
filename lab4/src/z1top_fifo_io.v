`timescale 1ns/1ns
`define CLOCK_FREQ 125_000_000

module z1top_fifo_io (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);

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

  localparam FIFO_WIDTH = 4;
  localparam FIFO_LOGDEPTH = 3; // 8 entries

  wire [FIFO_WIDTH-1:0] fifo_enq_data, fifo_deq_data;
  wire fifo_enq_valid, fifo_enq_ready, fifo_deq_valid, fifo_deq_ready;
  fifo #(
    .WIDTH(FIFO_WIDTH),
    .LOGDEPTH (FIFO_LOGDEPTH)
  ) FIFO (
    .clk(CLK_125MHZ_FPGA),
    .rst(SWITCHES[1] & buttons_pressed[3]),

    .enq_valid(fifo_enq_valid), // input
    .enq_data(fifo_enq_data),   // input
    .enq_ready(fifo_enq_ready), // output

    .deq_valid(fifo_deq_valid), // output
    .deq_data(fifo_deq_data),   // output
    .deq_ready(fifo_deq_ready)  // input
  );

  localparam integer TIME_CNT = 1 * `CLOCK_FREQ;
  wire [31:0] timer_cnt_value, timer_cnt_next;
  wire timer_cnt_rst;
  REGISTER_R #(.N(32), .INIT(0)) timer_cnt (
    .q(timer_cnt_value),
    .d(timer_cnt_next),
    .rst(timer_cnt_rst),
    .clk(CLK_125MHZ_FPGA)
  );

  wire [3:0] led_status_value, led_status_next;
  wire led_status_ce;
  REGISTER_CE #(.N(4)) led_status (
    .q(led_status_value),
    .d(led_status_next),
    .ce(led_status_ce),
    .clk(CLK_125MHZ_FPGA)
  );

  assign fifo_enq_valid = (~SWITCHES[1]) & (|(buttons_pressed));
  assign fifo_enq_data = (buttons_pressed[0] == 1) ? 4'b0001 :
	                       (buttons_pressed[1] == 1) ? 4'b0010 :
	                       (buttons_pressed[2] == 1) ? 4'b0100 :
	                       (buttons_pressed[3] == 1) ? 4'b1000 : 0;

  assign timer_cnt_next = timer_cnt_value + 1;
  assign timer_cnt_rst  = timer_cnt_value == TIME_CNT;

  // read from the FIFO every sec when SWITCHES[0] is ON
  assign fifo_deq_ready = (timer_cnt_value == TIME_CNT) & (~SWITCHES[0]);

  assign led_status_next = fifo_deq_data;
  assign led_status_ce   = fifo_deq_valid & fifo_deq_ready;

  assign LEDS[3:0] = led_status_value;

endmodule
