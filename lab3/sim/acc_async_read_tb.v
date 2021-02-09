`timescale 1ns/1ns
`define CLOCK_PERIOD 8

module acc_async_read_tb();
  localparam AWIDTH = 10;
  localparam DWIDTH = 32;
  localparam DEPTH  = 1 << AWIDTH;

  reg clk = 0;
  always #(`CLOCK_PERIOD/2) clk = ~clk;

  reg rst;
  reg  [31:0] len;
  wire [DWIDTH-1:0] hw_result;
  wire done;

  wire [AWIDTH-1:0] rom_addr;
  wire [DWIDTH-1:0] rom_data;

  acc_async_read #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH)
  ) DUT (
    .clk(clk),
    .rst(rst),
    .done(done),           // output
    .len(len),             // input
    .read_addr(rom_addr),  // output
    .read_data(rom_data),  // input
    .acc_result(hw_result)    // output
  );

  ASYNC_ROM #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH),
    .MIF_HEX("test_data_sim.mif")
  ) rom (
    .addr(rom_addr), // input
    .q(rom_data)     // output
  );

  // "Software" version
  reg [31:0] test_vector [DEPTH-1:0];
  integer sw_result = 0;
  integer i;
  initial begin
    $readmemh("test_data_sim.mif", test_vector);
    #1;
    for (i = 0; i < len; i = i + 1) begin
		  sw_result = sw_result + test_vector[i];
    end
  end

  reg [31:0] cycle_cnt;

  always @(posedge clk) begin
    if (rst || done)
      cycle_cnt <= 0;
    else
      cycle_cnt <= cycle_cnt + 1;
  end

  initial begin
    rst = 1;
    len = 1024;

    repeat (10) @(posedge clk);

    @(negedge clk);
    rst = 0;

    wait (done === 1'b1);
    $display("At time %t, hw_result = %d, sw_result = %d, done = %d, number of cycles = %d",
             $time, hw_result, sw_result, done, cycle_cnt);

    if (hw_result == sw_result)
      $display("TEST 1 PASSED!");
    else begin
      $display("TEST 1 FAILED!");
      $finish();
    end

    repeat (100) @(posedge clk);

    // Hold reset for 5 cycles
    @(negedge clk);
    rst = 1'b1;

    repeat (5) @(posedge clk);

    @(negedge clk);
    rst = 1'b0;

    // The circuit should be able to restart the computation
    wait (done === 1'b1);
    $display("At time %t, hw_result = %d, sw_result = %d, done = %d, number of cycles = %d",
             $time, hw_result, sw_result, done, cycle_cnt);

    if (hw_result == sw_result)
      $display("TEST 2 PASSED!");
    else begin
      $display("TEST 2 FAILED!");
      $finish();
    end

    #100;
    $display("Done!");
    $finish();
  end

  initial begin
    repeat (3 * DEPTH) @(posedge clk);
    $display("Timeout!");
    $finish();
  end

endmodule
