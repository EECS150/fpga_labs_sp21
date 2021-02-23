
module read_rom (
  input clk,
  input rst,
  input read_en,

  output [7:0] rdata_out,
  output rdata_out_valid,
  input  rdata_out_ready
);

  localparam AWIDTH = 7;
  localparam DWIDTH = 8;
  localparam DEPTH  = 105;

  wire rdata_out_fire = rdata_out_valid & rdata_out_ready;

  wire [AWIDTH-1:0] mem_addr;
  wire [DWIDTH-1:0] mem_rdata;
  wire mem_en;

  SYNC_ROM #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH),
    .DEPTH(DEPTH),
    .MIF_HEX("text.mif")
  ) mem (
    .q(mem_rdata),
    .addr(mem_addr),
    .en(mem_en),
    .clk(clk)
  );

  wire [AWIDTH-1:0] index_value, index_next;
  wire index_ce, index_rst;
  REGISTER_R_CE #(.N(AWIDTH), .INIT(0)) index_reg (
    .q(index_value),
    .d(index_next),
    .ce(index_ce),
    .rst(index_rst),
    .clk(clk)
  );

  // Delay 1 cycle because SYNC_ROM has one-cycle read
  wire delay;
  REGISTER_R #(.N(1), .INIT(0)) delay_reg (
    .q(delay),
    .d(read_en & (mem_addr < DEPTH)),
    .rst(rst),
    .clk(clk)
  );

  assign index_next = index_value + 1;
  assign index_ce   = read_en & rdata_out_ready & (index_value < DEPTH);
  assign index_rst  = rst;

  assign mem_addr = index_value;
  assign mem_en   = read_en & rdata_out_ready;
  assign rdata_out = mem_rdata;
  assign rdata_out_valid = delay;

endmodule
