`include "colors.vh"

// Source: https://www.ibm.com/support/knowledgecenter/P8DEA/p8egb/p8egb_supportedresolution.htm
module display_controller #(

  // Video resolution parameters for 800x600 @60Hz -- pixel_freq = 40 MHz
  parameter H_ACTIVE_VIDEO = 800,
  parameter H_FRONT_PORCH  = 40,
  parameter H_SYNC_WIDTH   = 128,
  parameter H_BACK_PORCH   = 88,

  parameter V_ACTIVE_VIDEO = 600,
  parameter V_FRONT_PORCH  = 1,
  parameter V_SYNC_WIDTH   = 4,
  parameter V_BACK_PORCH   = 23

//  // Video resolution parameters for 1024x768 @60Hz -- pixel_freq = 65 MHz
//  parameter H_ACTIVE_VIDEO = 1024,
//  parameter H_FRONT_PORCH  = 24,
//  parameter H_SYNC_WIDTH   = 136,
//  parameter H_BACK_PORCH   = 160,
//
//  parameter V_ACTIVE_VIDEO = 768,
//  parameter V_FRONT_PORCH  = 3,
//  parameter V_SYNC_WIDTH   = 6,
//  parameter V_BACK_PORCH   = 29
//
//  // Video resolution parameters for 1280x720 @60Hz -- pixel_freq = 74.25 MHz
//  parameter H_ACTIVE_VIDEO = 1280,
//  parameter H_FRONT_PORCH  = 110,
//  parameter H_SYNC_WIDTH   = 40,
//  parameter H_BACK_PORCH   = 220,
//
//  parameter V_ACTIVE_VIDEO = 720,
//  parameter V_FRONT_PORCH  = 5,
//  parameter V_SYNC_WIDTH   = 5,
//  parameter V_BACK_PORCH   = 20
) (
  input pixel_clk,
  input rst,

  input [23:0] pixel_stream_din,
  input pixel_stream_din_valid,
  output pixel_stream_din_ready,

  // video signals
  output [23:0] video_out_pData,
  output video_out_pHSync,
  output video_out_pVSync,
  output video_out_pVDE
);

  // Some hints for you to get started
  localparam H_FRAME = H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH;
  localparam V_FRAME = V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH;
  localparam H_SYNC_START = H_ACTIVE_VIDEO + H_FRONT_PORCH;
  localparam H_SYNC_END   = H_SYNC_START + H_SYNC_WIDTH;
  localparam V_SYNC_START = V_ACTIVE_VIDEO + V_FRONT_PORCH;
  localparam V_SYNC_END   = V_SYNC_START + V_SYNC_WIDTH;

  wire [31:0] pixel_x_value, pixel_x_next;
  wire pixel_x_ce, pixel_x_rst;
  wire [31:0] pixel_y_value, pixel_y_next;
  wire pixel_y_ce, pixel_y_rst;

  // pixel_x: 0 ---> H_FRAME - 1
  // pixel_y: 0 ---> V_FRAME - 1
  REGISTER_R_CE #(.N(32), .INIT(0)) pixel_x (
    .q(pixel_x_value),
    .d(pixel_x_next),
    .ce(pixel_x_ce),
    .rst(pixel_x_rst),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(32), .INIT(0)) pixel_y (
    .q(pixel_y_value),
    .d(pixel_y_next),
    .ce(pixel_y_ce),
    .rst(pixel_y_rst),
    .clk(pixel_clk)
  );

  // TODO: fill in the remaining logic to implement the display controller
  // Make sure your signals meet the timing specification for HSync, VSync, and Video Active
  // For task 1, do not worry about the 'pixel_stream_din', just set 'video_out_pData'
  // to some constant value to test if your code works with a monitor
  // After you finish task 1, simulate with the testbench 'sim/display_controller_tb.v'
  // For task 2, you need to implement proper control logic to read the 'pixel_stream_din'
  // After you finish task 2, simulate with the testbench 'sim/fifo_display_tb.v'

  assign video_out_pHSync = 0;
  assign video_out_pVSync = 0;
  assign video_out_pVDE   = 0;

  assign pixel_x_next = 0;
  assign pixel_x_ce   = 0;
  assign pixel_x_rst  = 0;

  assign pixel_y_next = 0;
  assign pixel_y_ce   = 0;
  assign pixel_y_rst  = 0;

  assign pixel_stream_din_ready = 0;

  assign video_out_pData = `GREEN; // task 1
  //assign video_out_pData = pixel_stream_din; // task 2

endmodule
