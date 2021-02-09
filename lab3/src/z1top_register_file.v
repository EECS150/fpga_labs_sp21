`timescale 1ns/1ns
`define CLOCK_FREQ 125_000_000

module z1top_register_file (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
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
    .out(buttons_pressed));

  localparam AWIDTH = 5;
  localparam DWIDTH = 6;

  wire [AWIDTH-1:0] addr;
  wire [DWIDTH-1:0] din, dout;
  wire we;

  register_file #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH)
  ) RF (
    .clk(CLK_125MHZ_FPGA),
    .addr(addr),
    .din(din),
    .dout(dout),
    .we(we)
  );

  wire [DWIDTH-1:0] data_next, data_value;
  wire data_ce, data_rst;

  REGISTER_R_CE #(.N(DWIDTH), .INIT(0)) data_reg (
    .clk(CLK_125MHZ_FPGA),
    .rst(data_rst),
    .ce(data_ce),
    .d(data_next),
    .q(data_value)
  );

  wire [AWIDTH-1:0] addr_next, addr_value;
  wire addr_ce, addr_rst;

  REGISTER_R_CE #(.N(AWIDTH), .INIT(0)) addr_reg (
    .clk(CLK_125MHZ_FPGA),
    .rst(addr_rst),
    .ce(addr_ce),
    .d(addr_next),
    .q(addr_value)
  );

  // SWITCHES[1:0] == 2'b00 & BTN[0](++)/BTN[1](--) --> input addr
  // SWITCHES[1:0] == 2'b01 & BTN[0](++)/BTN[1](--) --> input data
  // SWITCHES[1:0] == 2'b11 & BTN[2]                --> write data_value to RF[addr_value]
  assign addr_next = (buttons_pressed[0] == 1'b1) ? addr_value + 1 :
                     (buttons_pressed[1] == 1'b1) ? addr_value - 1 : addr_value;
  assign addr_ce   = (SWITCHES == 2'b00);
  assign addr_rst  = (SWITCHES == 2'b00 && buttons_pressed[3]);

  assign data_next = (buttons_pressed[0] == 1'b1) ? data_value + 1 :
                     (buttons_pressed[1] == 1'b1) ? data_value - 1 : data_value;
  assign data_ce   = (SWITCHES == 2'b01);
  assign data_rst  = (SWITCHES == 2'b01 && buttons_pressed[3]);

  assign addr = addr_value;
  assign din  = data_value;
  assign we   = (SWITCHES == 2'b11 && buttons_pressed[2]);

  // LEDs display
  // SWITCHES[1:0] == 2'b00 --> display current input addr
  // SWITCHES[1:0] == 2'b01 --> display current input data
  // SWITCHES[1:0] == 2'b1x --> display dout
  assign LEDS = (SWITCHES == 2'b00) ? addr_value :
                (SWITCHES == 2'b01) ? data_value :
                                      dout[5:0];

endmodule
