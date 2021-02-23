`include "colors.vh"

module draw_triangle #(
//  // Video resolution parameters for 800x600 @60Hz -- pixel_freq = 40 MHz
//  parameter H_ACTIVE_VIDEO = 800,
//  parameter H_FRONT_PORCH  = 40,
//  parameter H_SYNC_WIDTH   = 128,
//  parameter H_BACK_PORCH   = 88,
//
//  parameter V_ACTIVE_VIDEO = 600,
//  parameter V_FRONT_PORCH  = 1,
//  parameter V_SYNC_WIDTH   = 4,
//  parameter V_BACK_PORCH   = 23

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

  // Video resolution parameters for 1280x720 @60Hz -- pixel_freq = 74.25 MHz
  parameter H_ACTIVE_VIDEO = 1280,
  parameter H_FRONT_PORCH  = 110,
  parameter H_SYNC_WIDTH   = 40,
  parameter H_BACK_PORCH   = 220,

  parameter V_ACTIVE_VIDEO = 720,
  parameter V_FRONT_PORCH  = 5,
  parameter V_SYNC_WIDTH   = 5,
  parameter V_BACK_PORCH   = 20
) (
  input pixel_clk,

  // Pixel coordinates of the three vertices of the triangle
  input [31:0] x0,
  input [31:0] y0,
  input [31:0] x1,
  input [31:0] y1,
  input [31:0] x2,
  input [31:0] y2,

  // video signals
  output [23:0] video_out_pData,
  output video_out_pHSync,
  output video_out_pVSync,
  output video_out_pVDE
);

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

  REGISTER_R_CE #(.N(32), .INIT(0)) pixel_x_reg (
    .q(pixel_x_value),
    .d(pixel_x_next),
    .ce(pixel_x_ce),
    .rst(pixel_x_rst),
    .clk(pixel_clk)
  );

  REGISTER_R_CE #(.N(32), .INIT(0)) pixel_y_reg (
    .q(pixel_y_value),
    .d(pixel_y_next),
    .ce(pixel_y_ce),
    .rst(pixel_y_rst),
    .clk(pixel_clk)
  );

  wire [31:0] pixel_x_out, pixel_y_out;
  wire is_inside;

  // The inside_test module is essentially a pipeline
  // Depending on how many pipeline stages you added, it will take
  // some cycles from when a pixel enters the pipeline to when the test result
  // is available
  inside_test inside_test (
    // Inputs
    .pixel_clk(pixel_clk),
    .pixel_x(pixel_x_value),
    .pixel_y(pixel_y_value),
    .x0(x0),
    .y0(y0),
    .x1(x1),
    .y1(y1),
    .x2(x2),
    .y2(y2),

    // Outputs
    .pixel_x_out(pixel_x_out),
    .pixel_y_out(pixel_y_out),
    .is_inside(is_inside)
  );

  wire [23:0] pixel_color = (is_inside) ? `MAGENTA : `BLACK;
  // For rgb2dvi IP, G and B are actually swapped
  assign video_out_pData = {pixel_color[23:16], pixel_color[7:0], pixel_color[15:8]};

  // TODO: Correct the following assign statements
  // The logic is similar to the display_controller module.
  // However, for video signals, you need to use pixel_x_out and pixel_y_out

  assign pixel_x_next = 0;
  assign pixel_x_ce   = 0;
  assign pixel_x_rst  = 0;

  assign pixel_y_next = 0;
  assign pixel_y_ce   = 0;
  assign pixel_y_rst  = 0;

  assign video_out_pHSync = 0;
  assign video_out_pVSync = 0;
  assign video_out_pVDE   = 0;

endmodule
