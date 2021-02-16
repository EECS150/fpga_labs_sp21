`timescale 1ns/1ns

module z1top_fifo_display (
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS,

  output pixel_clk,

  // video signals
  output [23:0] video_out_pData,
  output video_out_pHSync,
  output video_out_pVSync,
  output video_out_pVDE
);

  wire clk_in1, clk_out1;
  assign pixel_clk = clk_out1;
  assign clk_in1 = CLK_125MHZ_FPGA;

  // Clocking wizard IP from Vivado (wrapper of the PLLE module)
  // Generate 40 MHz clock from 125 MHz clock
  // The 40 MHz clock is used as pixel clock
  clk_wiz clk_wiz (
    .clk_out1(clk_out1), // output
    .reset(1'b0),        // input
    .locked(),           // output, unused
    .clk_in1(clk_in1)    // input
  );

  // Button parser
  // Sample the button signal every 500us
  localparam integer B_SAMPLE_CNT_MAX = 0.0005 * 40_000_000;
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

  wire gray_enable, red_enable, green_enable, blue_enable;
  wire gray_select  = (SWITCHES[1:0] == 2'b00) & buttons_pressed[3];
  wire red_select   = (SWITCHES[1:0] == 2'b00) & buttons_pressed[2];
  wire green_select = (SWITCHES[1:0] == 2'b00) & buttons_pressed[1];
  wire blue_select  = (SWITCHES[1:0] == 2'b00) & buttons_pressed[0];

  REGISTER_R_CE #(.N(1)) gray_enable_r (
    .q(gray_enable),
    .d(1'b1), 
    .ce(gray_select),
    .rst(red_select | green_select | blue_select),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(1)) red_enable_r (
    .q(red_enable),
    .d(1'b1), 
    .ce(red_select),
    .rst(gray_select | green_select | blue_select),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(1)) green_enable_r (
    .q(green_enable),
    .d(1'b1), 
    .ce(green_select),
    .rst(gray_select | red_select | blue_select),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(1)) blue_enable_r (
    .q(blue_enable),
    .d(1'b1), 
    .ce(blue_select),
    .rst(gray_select | red_select | green_select),
    .clk(pixel_clk)
  );

  wire rst = (SWITCHES[1:0] == 2'b11) & buttons_pressed[3];

  wire play;
  REGISTER_R_CE #(.N(1), .INIT(0)) play_reg (
    .clk(pixel_clk),
    .d(~play),
    .q(play),
    .ce((SWITCHES[1:0] == 2'b11) & buttons_pressed[2]),
    .rst(rst)
  );

  wire [23:0] video_out_pData_tmp;
  wire [23:0] video_data;

  fifo_display (
    .pixel_clk(pixel_clk),
    .rst(rst),
    .play(play),
    .video_out_pData(video_data),
    .video_out_pHSync(video_out_pHSync),
    .video_out_pVSync(video_out_pVSync),
    .video_out_pVDE(video_out_pVDE)
  );

  assign video_out_pData_tmp = (red_enable)   ? {video_data[7:0], 8'b0, 8'b0} :
                               (green_enable) ? {8'b0, video_data[7:0], 8'b0} :
                               (blue_enable)  ? {8'b0, 8'b0, video_data[7:0]} : video_data;

  // The Digilent video IP actually swaps the G and B channels
  assign video_out_pData = {video_out_pData_tmp[23:16], 
                            video_out_pData_tmp[7:0],
                            video_out_pData_tmp[15:8]};

  assign LEDS[3:0] = {gray_enable, red_enable, green_enable, blue_enable};
endmodule
