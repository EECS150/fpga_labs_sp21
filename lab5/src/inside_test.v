
// Draw a triangle with three vertices (0), (1), (2)
// (0) -> (1) -> (2) follows counter-clockwise order
// Line i connecting points (i) and (i+1) is associated with three coefficients Ai, Bi, Ci
// (0)->(1): A0, B0, C0 -- line 0
// (1)->(2): A1, B1, C1 -- line 1
// (2)->(0): A2, B2, C2 -- line 2
// for a pixel (x, y) on image plane, denote Li = Ai * x + Bi * y + Ci
//   + Li < 0: (x, y) is on the RHS of the line i
//   + Li > 0: (x, y) is on the LHS of the line i
//   + Li = 0: (x, y) is on the line i
// How to determine Ai, Bi, Ci of the line (x{i}, y{i})->(x{i+1}, y{i+1})?
//   dx{i} = x{i+1} - x{i};
//   dy{i} = y{i+1} - y{i};
//   A{i} = -dy{i};
//   B{i} = dx{i};
//   C{i} = x{i} * dy{i} - y{i} * dx{i};
// To draw a triangle, we need to fill all the pixels within the three lines
// Reference: https://cs184.eecs.berkeley.edu/sp19/lecture/2/rasterization




// This module performs an inside test to check if a pixel (x, y) lies within
// a triangle formed by the three vertices (point0, point1, point2).
// Note that we are referring to pixel coordinates, meaning that x increments
// from left to right, and y increments from top to bottom. The origin is at
// the top-left corner.
(* use_dsp = "no" *) module inside_test (

// Also note the use of the attribute use_dsp here. It tells the Synthesis tool
// to avoid using DSP blocks to implement the arithmetic operations in the code.
// A DSP block can do a wide-width multiplication very effectively, among many other
// operations. 
// We turn off the use of DSP blocks here on purpose so that your circuit only
// utilizes LUTs and FFs to implement arithmetic operators.

  input pixel_clk,

  // pixel (x, y)
  input [31:0] pixel_x,
  input [31:0] pixel_y,

  // point0 (x0, y0)
  input [31:0] x0,
  input [31:0] y0,

  // point1 (x1, y1)
  input [31:0] x1,
  input [31:0] y1,

  // point2 (x2, y2)
  input [31:0] x2,
  input [31:0] y2,

  output [31:0] pixel_x_out,
  output [31:0] pixel_y_out,

  // HIGH if (pixel_x_out, pixel_y_out) is inside the triangle, LOW otherwise
  output is_inside
);

  // This module is originally pipelined with two stages
  // The first stage just register the input
  // The second stage registers the test result
  // It takes two cycles, from the arrival of an input pixel to the test result
  // of whether the pixel is inside a triangle
  // Think of this like a pipeline: when we have new pixel arrived,
  // the current pixel is being tested, and the previous pixel is output

  // TODO: you should add one or a few more pipeline stages to improve the timing of the circuit
  // The goal is to meet 74.25 MHz clock frequency (14ns).
  // Try to use as fewer stages as possible to achieve the desirable clock frequency.

  // When you add a new pipeline stage, make sure to register all the signals
  // involved, otherwise it might cause cycle mismatches and lead to incorrect result.
  // The most straightforward way to do this is to draw the circuit on a paper,
  // then draw a vertical line to cut the circuit to pieces. Then, add a register
  // at every intersection of the line with the signal wires in your circuit.
  // You should use a good naming scheme that helps you to keep track of pipelined registers easily.
  // Feel free to change the code below to your own style as long as the functionality is correct.
  // Also, please use REGISTER* modules from lib/EECS151.v.

  wire signed [31:0] pixel_x_value0, pixel_y_value0;
  wire signed [31:0] pixel_x_value1, pixel_y_value1;

  wire signed [31:0] x0_value0, y0_value0;
  wire signed [31:0] x1_value0, y1_value0;
  wire signed [31:0] x2_value0, y2_value0;

  REGISTER #(.N(32)) pixel_x_reg0 (.q(pixel_x_value0), .d(pixel_x), .clk(pixel_clk));
  REGISTER #(.N(32)) pixel_y_reg0 (.q(pixel_y_value0), .d(pixel_y), .clk(pixel_clk));

  REGISTER #(.N(32)) x0_reg0 (.q(x0_value0), .d(x0), .clk(pixel_clk));
  REGISTER #(.N(32)) y0_reg0 (.q(y0_value0), .d(y0), .clk(pixel_clk));
  REGISTER #(.N(32)) x1_reg0 (.q(x1_value0), .d(x1), .clk(pixel_clk));
  REGISTER #(.N(32)) y1_reg0 (.q(y1_value0), .d(y1), .clk(pixel_clk));
  REGISTER #(.N(32)) x2_reg0 (.q(x2_value0), .d(x2), .clk(pixel_clk));
  REGISTER #(.N(32)) y2_reg0 (.q(y2_value0), .d(y2), .clk(pixel_clk));

  wire signed [31:0] A0, B0, C0;
  wire signed [31:0] A1, B1, C1;
  wire signed [31:0] A2, B2, C2;

  wire signed [31:0] dx0 = x1_value0 - x0_value0;
  wire signed [31:0] dy0 = y1_value0 - y0_value0;
  assign A0 = -dy0;
  assign B0 = dx0;
  assign C0 = x0_value0 * dy0 - y0_value0 * dx0;

  wire signed [31:0] dx1 = x2_value0 - x1_value0;
  wire signed [31:0] dy1 = y2_value0 - y1_value0;
  assign A1 = -dy1;
  assign B1 = dx1;
  assign C1 = x1_value0 * dy1 - y1_value0 * dx1;

  wire signed [31:0] dx2 = x0_value0 - x2_value0;
  wire signed [31:0] dy2 = y0_value0 - y2_value0;
  assign A2 = -dy2;
  assign B2 = dx2;
  assign C2 = x2_value0 * dy2 - y2_value0 * dx2;

  wire signed [31:0] L0, L1, L2;
  assign L0 = A0 * pixel_x_value0 + B0 * pixel_y_value0 + C0;
  assign L1 = A1 * pixel_x_value0 + B1 * pixel_y_value0 + C1;
  assign L2 = A2 * pixel_x_value0 + B2 * pixel_y_value0 + C2;

  REGISTER #(.N(32)) pixel_x_reg1 (.q(pixel_x_value1), .d(pixel_x_value0), .clk(pixel_clk));
  REGISTER #(.N(32)) pixel_y_reg1 (.q(pixel_y_value1), .d(pixel_y_value0), .clk(pixel_clk));

  wire is_inside_value1;

  REGISTER #(.N(1)) is_inside_reg (
    .q(is_inside_value1),
    .d(L0 <= 0 & L1 <= 0 & L2 <= 0),
    .clk(pixel_clk)
  );

  // When you add new pipeline registers/stages, make sure that pixel_x_out and pixel_y_out
  // are assigned to the last stage. Same thing for is_inside.
  // Therefore, is_inside is an indicator of whether pixel (pixel_x_out, pixel_y_out)
  // is inside the triangle

  assign pixel_x_out = pixel_x_value1;
  assign pixel_y_out = pixel_y_value1;
  assign is_inside   = is_inside_value1;

endmodule
