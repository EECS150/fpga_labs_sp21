`timescale 1ns/1ns

module datapath #(
  parameter WIDTH = 5
) (
  input clk,

  input [WIDTH-1:0] keypad_value,

  input mem_addr_cen,
  input op_a_cen,
  input op_b_cen,
  input result_cen,

  input mem_read,
  input mem_write,
  input write_sel,
  input displ_sel,

  output [WIDTH-1:0] displ_output
);

  wire [WIDTH-1:0] mem_addr_reg_value, mem_addr_reg_next;
  wire mem_addr_reg_ce;

  REGISTER_CE #(.N(WIDTH)) mem_addr_reg (
    .clk(clk),
    .ce(mem_addr_reg_ce),
    .d(mem_addr_reg_next),
    .q(mem_addr_reg_value)
  );

  wire [WIDTH-1:0] op_a_reg_value, op_a_reg_next;
  wire op_a_reg_ce;

  REGISTER_CE #(.N(WIDTH)) op_a_reg (
    .clk(clk),
    .ce(op_a_reg_ce),
    .d(op_a_reg_next),
    .q(op_a_reg_value)
  );

  wire [WIDTH-1:0] op_b_reg_value, op_b_reg_next;
  wire op_b_reg_ce;

  REGISTER_CE #(.N(WIDTH)) op_b_reg (
    .clk(clk),
    .ce(op_b_reg_ce),
    .d(op_b_reg_next),
    .q(op_b_reg_value)
  );

  wire [WIDTH-1:0] result_reg_value, result_reg_next;
  wire result_reg_ce;

  REGISTER_CE #(.N(WIDTH)) result_reg (
    .clk(clk),
    .ce(result_reg_ce),
    .d(result_reg_next),
    .q(result_reg_value)
  );

  wire [WIDTH-1:0] addr;
  wire [WIDTH-1:0] din, dout;
  wire wen;
  ASYNC_RAM #(
    .AWIDTH(WIDTH),
    .DWIDTH(WIDTH)
  ) RF (
    .clk(clk),
    .addr(addr),
    .d(din),
    .q(dout),
    .we(wen)
  );

  assign op_a_reg_next = dout;
  assign op_a_reg_ce   = op_a_cen;

  assign op_b_reg_next = dout;
  assign op_b_reg_ce   = op_b_cen;

  assign result_reg_next = (mem_read) ? dout : (op_a_reg_value + op_b_reg_value);
  assign result_reg_ce   = result_cen;

  assign mem_addr_reg_next = keypad_value;
  assign mem_addr_reg_ce   = mem_addr_cen;

  assign addr = mem_addr_reg_value;
  assign din  = write_sel ? result_reg_value : keypad_value;
  assign wen  = mem_write;

  assign displ_output = displ_sel ? result_reg_value : keypad_value;

endmodule
