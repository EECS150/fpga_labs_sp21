
// This block keeps streaming pixels from the ROM to the sink block
// as long as the sink block is ready
module pixel_stream #(
  parameter IMG_ADDR_WIDTH = 19,
  parameter IMG_DATA_WIDTH = 8,
  parameter IMG_NUM_PIXELS = 600 * 800
) (
  input pixel_clk,
  input rst,

  input play,
  output [IMG_DATA_WIDTH-1:0] pixel_stream_dout,
  output pixel_stream_dout_valid,
  input  pixel_stream_dout_ready
);
  wire [IMG_ADDR_WIDTH-1:0] img_mem_addr;
  wire [IMG_DATA_WIDTH-1:0] img_mem_rdata;
  wire img_mem_en;
  SYNC_ROM #(
    .AWIDTH(IMG_ADDR_WIDTH),
    .DWIDTH(IMG_DATA_WIDTH),
    .DEPTH(IMG_NUM_PIXELS),
    .MIF_BIN("ucb_wheeler_hall_bin.mif")
  ) img_memory (
    .q(img_mem_rdata),
    .addr(img_mem_addr),
    .en(img_mem_en),
    .clk(pixel_clk)
  );

  wire [IMG_ADDR_WIDTH-1:0] pixel_index_value, pixel_index_next;
  wire pixel_index_ce, pixel_index_rst;

  REGISTER_R_CE #(.N(IMG_ADDR_WIDTH), .INIT(0)) pixel_index (
    .q(pixel_index_value),
    .d(pixel_index_next),
    .ce(pixel_index_ce),
    .rst(pixel_index_rst),
    .clk(pixel_clk)
  );

  wire play_delayed;
  REGISTER_R #(.N(1), .INIT(0)) delay_reg (
    .q(play_delayed),
    .d(play),
    .rst(rst),
    .clk(pixel_clk)
  );

  wire pixel_stream_dout_fire = pixel_stream_dout_valid & pixel_stream_dout_ready;

  assign pixel_index_next = pixel_index_value + 1;
  assign pixel_index_ce   = play & pixel_stream_dout_ready;
  assign pixel_index_rst  = (pixel_index_value == IMG_NUM_PIXELS - 1) | rst;

  assign img_mem_addr = pixel_index_value;
  assign img_mem_en   = play & pixel_stream_dout_ready;
  assign pixel_stream_dout = img_mem_rdata;
  // Delay 1 cycle because SYNC_ROM has one-cycle read
  assign pixel_stream_dout_valid = play_delayed;

endmodule
