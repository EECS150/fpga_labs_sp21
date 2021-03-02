`timescale 1ns/1ns
`include "../src/colors.vh"

module inside_test_tb();
  localparam WIDTH  = 1280;
  localparam HEIGHT = 720;

  localparam X0 = 500;
  localparam Y0 = 50;
  localparam X1 = 100;
  localparam Y1 = 400;
  localparam X2 = 700;
  localparam Y2 = 300;

  reg clk;
  initial clk = 0;
  always #(5) clk = ~clk;

  reg [31:0] pixel_x, pixel_y;
  reg [31:0] x0, y0, x1, y1, x2, y2;
  wire [31:0] pixel_x_out, pixel_y_out;
  wire is_inside;

  reg [23:0] sw_img_output [HEIGHT*WIDTH-1:0];

  integer x, y;
  integer DX0, DY0, DX1, DY1, DX2, DY2;
  integer A0, B0, C0;
  integer A1, B1, C1;
  integer A2, B2, C2;
  integer L0, L1, L2;

  initial begin
    // init img_data
    #0;
    for (y = 0; y < HEIGHT; y = y + 1) begin
      for (x = 0; x < WIDTH; x = x + 1) begin
        sw_img_output[y * WIDTH + x] = `BLACK;
      end
    end

    // Software implementation of triangle drawing
    #1;
    DX0 = X1 - X0; DY0 = Y1 - Y0;
    A0 = -DY0; B0 = DX0; C0 = X0 * DY0 - Y0 * DX0;

    DX1 = X2 - X1; DY1 = Y2 - Y1;
    A1 = -DY1; B1 = DX1; C1 = X1 * DY1 - Y1 * DX1;

    DX2 = X0 - X2; DY2 = Y0 - Y2;
    A2 = -DY2; B2 = DX2; C2 = X2 * DY2 - Y2 * DX2;

    for (y = 0; y < HEIGHT; y = y + 1) begin
      for (x = 0; x < WIDTH; x = x + 1) begin
        L0 = A0 * x + B0 * y + C0;
        L1 = A1 * x + B1 * y + C1;
        L2 = A2 * x + B2 * y + C2;
        if (L0 <= 0 && L1 <= 0 && L2 <= 0) begin
          sw_img_output[y * WIDTH + x] = `MAGENTA;
        end
      end
    end
  end

  inside_test dut (
    .pixel_clk(clk),           // input
    .pixel_x(pixel_x),         // input
    .pixel_y(pixel_y),         // input
    .x0(x0),                   // input
    .y0(y0),                   // input
    .x1(x1),                   // input
    .y1(y1),                   // input
    .x2(x2),                   // input
    .y2(y2),                   // input

    .pixel_x_out(pixel_x_out), // output
    .pixel_y_out(pixel_y_out), // output
    .is_inside(is_inside)      // output
  );

  reg [23:0] hw_img_output [HEIGHT*WIDTH-1:0];

  always @(posedge clk) begin
    hw_img_output[pixel_y_out * WIDTH + pixel_x_out] <= is_inside ? `MAGENTA : `BLACK;
  end

  integer i, j;
  integer num_mismatches = 0;

  initial begin
    #0;
    $dumpfile("inside_test_tb.vcd");
    $dumpvars;

    num_mismatches = 0;

    x0 = X0; y0 = Y0; 
    x1 = X1; y1 = Y1;
    x2 = X2; y2 = Y2;

    pixel_x = 0;
    pixel_y = 0;

    // Wait for some time
    repeat (10) @(posedge clk);

    // Push a pixel into the inside_test pipeline every clock cycle
    for (j = 0; j < HEIGHT; j = j + 1) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        @(posedge clk); #1;
        pixel_x = i;
        pixel_y = j;
      end
    end

    // Wait until the final pixel comes out of the pipeline
    wait ((pixel_x_out === WIDTH - 1) && (pixel_y_out === HEIGHT - 1));

    @(posedge clk); #1;
    $display("Done!");

    // Check for mismatches against software result
    for (j = 0; j < HEIGHT; j = j + 1) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        if (hw_img_output[j * WIDTH + i] !== sw_img_output[j * WIDTH + i])
          num_mismatches = num_mismatches + 1;
      end
   end

   if (num_mismatches == 0)
     $display("TEST PASSED!");
   else
     $display("TEST FAILED! Num mismatches: %d", num_mismatches);

   // Save to a file (that can be converted to an image for visualization)
   $writememh("hw_img_output.mif", hw_img_output);
   $writememh("sw_img_output.mif", sw_img_output);

   $finish();
end

endmodule
