`timescale 1ns/1ns

module acc_sync_read #(
  parameter AWIDTH = 10,
  parameter DWIDTH = 32
) (
  input  clk,
  input  rst,
  input  [31:0] len,
  output [AWIDTH-1:0] read_addr,
  input  [DWIDTH-1:0] read_data,
  output [DWIDTH-1:0] acc_result,
  output done
);

  // TODO: Your code to implement an accumulator that reads data from (external)
  // memory block synchronously w.r.t clk
  // Some initial code has been provide to you, but please feel free to change them
  // as you see fit

  // indexing value to memory 
  wire [31:0] index_reg_value, index_reg_next;
  wire index_reg_rst, index_reg_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) index_reg (
    .q(index_reg_value),
    .d(index_reg_next),
    .ce(index_reg_ce),
    .rst(index_reg_rst),
    .clk(clk)
  );

  // accumulation result
  wire [31:0] sum_reg_value, sum_reg_next;
  wire sum_reg_rst, sum_reg_ce;
  REGISTER_R_CE #(.N(DWIDTH), .INIT(0)) sum_reg (
    .q(sum_reg_value),
    .d(sum_reg_next),
    .ce(sum_reg_ce),
    .rst(sum_reg_rst),
    .clk(clk)
  );

  // TODO: Update these lines
  assign read_addr = 0;

  assign index_reg_next = 0;
  assign index_reg_ce   = 0;
  assign index_reg_rst  = 0;

  assign sum_reg_next = 0;
  assign sum_reg_ce   = 0;
  assign sum_reg_rst  = 0;

  assign acc_result = 0;

  // Note that you must hold 'done' HIGH when the computation finishes
  assign done = 0;

endmodule
