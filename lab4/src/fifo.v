`timescale 1ns/1ns

module fifo #(
  parameter WIDTH    = 32, // data width is 32-bit
  parameter LOGDEPTH = 3   // 2^3 = 8 entries
) (
  input clk,
  input rst,

  // Write interface (enqueue)
  input  enq_valid,
  input  [WIDTH-1:0] enq_data,
  output enq_ready,

  // Read interface (dequeue)
  output deq_valid,
  output [WIDTH-1:0] deq_data,
  input deq_ready
);

  // For simplicity, we deal with FIFO with depth values of power of two.

  // Dual-port Memory
  // Use port0 for write, port1 for read
  wire [LOGDEPTH-1:0] buffer_addr0, buffer_addr1;
  wire [WIDTH-1:0] buffer_din0, buffer_din1, buffer_dout0, buffer_dout1;
  wire buffer_we0, buffer_we1;

  ASYNC_RAM_DP #(
    .AWIDTH(LOGDEPTH),
    .DWIDTH(WIDTH)
  ) buffer (
    .clk(clk),

    // Port 0
    .q0(buffer_dout0),
    .d0(buffer_din0),
    .addr0(buffer_addr0),
    .we0(buffer_we0),

    // Port 1
    .q1(buffer_dout1),
    .d1(buffer_din1),
    .addr1(buffer_addr1),
    .we1(buffer_we1)
  );

  // Disable write on port1
  assign buffer_we1  = 1'b0;
  assign buffer_din1 = 0;

  wire [LOGDEPTH-1:0] read_ptr_value, read_ptr_next;
  wire read_ptr_ce;
  wire [LOGDEPTH-1:0] write_ptr_value, write_ptr_next;
  wire write_ptr_ce;

  REGISTER_R_CE #(.N(LOGDEPTH)) read_ptr_reg  (
    .q(read_ptr_value),
    .d(read_ptr_next),
    .ce(read_ptr_ce),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R_CE #(.N(LOGDEPTH)) write_ptr_reg (
    .q(write_ptr_value),
    .d(write_ptr_next),
    .ce(write_ptr_ce),
    .rst(rst),
    .clk(clk)
  );

  // TODO: Your code to implement the FIFO logic
  // Note that:
  // - enq_ready is LOW: FIFO is full
  // - deq_valid is LOW: FIFO is empty

endmodule
