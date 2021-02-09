`timescale 1ns/1ns

`define CLOCK_PERIOD 8

module register_file_tb();
  localparam AWIDTH = 5;
  localparam DWIDTH = 32;

  reg clk = 0;
  always #(`CLOCK_PERIOD/2) clk = ~clk;

  reg we;
  reg  [AWIDTH-1:0] addr;
  reg  [DWIDTH-1:0] din;
  wire [DWIDTH-1:0] dout;

  register_file #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH)
  ) DUT (
    .clk(clk),
    .we(we),     // input
    .addr(addr), // input
    .din(din),   // input
    .dout(dout)  // output
  );

  wire [DWIDTH-1:0] test_value1 = 32'd8;
  wire [DWIDTH-1:0] test_value2 = 32'd9;

  // Some basic tests are done for you. Feel free to add your own tests
  initial begin
    #0;

    repeat (10) @(posedge clk);

    // Avoid changing a signal on a positive edge of the clock,
    // since that might lead to incorrect behavior during simulation,
    // especially if that signal is driving a state element
    // One good practice is to change the signals on a negative edge of
    // the clock (or, "@(posedge clk); #1")

    // Write test_value1 to RF location 10
    @(negedge clk);
    we   = 1'b1;
    addr = 5'd10;
    din  = test_value1;

    // Reset 'we' to 0 in the next cycle
    @(negedge clk);
    we = 1'b0;

    repeat (5) @(posedge clk);

    // Write test_value2 to RF location 12
    @(negedge clk);
    we   = 1'b1;
    addr = 5'd12;
    din  = test_value2;

    @(negedge clk);
    we = 1'b0;

    // Now, read from RF location 10
    @(negedge clk);
    addr = 5'd10;

    // RegFile is asynchronous read, so we would expect the read data to be
    // available immediately
    #1;
    if (dout === test_value1)
      $display("Test 1 passed!");
    else
      $display("Test 1 failed! Expect %d, Got %d", test_value1, dout);

    repeat (10) @(posedge clk);

    // If 'we' is 0, we should not write to RF
    @(negedge clk);
    we   = 1'b0;
    addr = 5'd12;
    din  = test_value1;

    // RegFile is asynchronous read, so we would expect the read data to be
    // available immediately
    #1;
    if (dout === test_value2)
      $display("Test 2 passed!");
    else
      $display("Test 2 failed! Expect %d, Got %d", test_value2, dout);

    #100;
    $display("Done!");
    $finish();
  end

endmodule
