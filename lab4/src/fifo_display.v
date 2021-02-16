`timescale 1ns/1ns

module fifo_display (
  input pixel_clk,
  input rst,
  input play,

  // video signals
  output [23:0] video_out_pData,
  output video_out_pHSync,
  output video_out_pVSync,
  output video_out_pVDE
);

  wire [7:0] pixel_stream_dout;
  wire pixel_stream_dout_valid, pixel_stream_dout_ready;

  pixel_stream pixel_stream (
    .pixel_clk(pixel_clk),                             // input
    .rst(rst),                                         // input

    .play(play),                                       // input

    .pixel_stream_dout(pixel_stream_dout),             // output
    .pixel_stream_dout_valid(pixel_stream_dout_valid), // output
    .pixel_stream_dout_ready(pixel_stream_dout_ready)  // input
  );

  localparam FIFO_WIDTH = 8;
  localparam FIFO_LOGDEPTH = 10;

  wire [FIFO_WIDTH-1:0] fifo_enq_data, fifo_deq_data;
  wire fifo_enq_valid, fifo_enq_ready, fifo_deq_valid, fifo_deq_ready;

  fifo #(
    .WIDTH(FIFO_WIDTH),
    .LOGDEPTH (FIFO_LOGDEPTH)
  ) FIFO (
    .clk(pixel_clk),
    .rst(rst),

    .enq_valid(fifo_enq_valid), // input
    .enq_data(fifo_enq_data),   // input
    .enq_ready(fifo_enq_ready), // output

    .deq_valid(fifo_deq_valid), // output
    .deq_data(fifo_deq_data),   // output
    .deq_ready(fifo_deq_ready)  // input
  );

  wire [23:0] pixel_stream_din;
  wire pixel_stream_din_valid, pixel_stream_din_ready;

  display_controller display_controller (
    .pixel_clk(pixel_clk),                           // input
    .rst(rst),                                       // input

    .pixel_stream_din(pixel_stream_din),             // input
    .pixel_stream_din_valid(pixel_stream_din_valid), // input
    .pixel_stream_din_ready(pixel_stream_din_ready), // output

    .video_out_pData(video_out_pData),               // output
    .video_out_pHSync(video_out_pHSync),             // output
    .video_out_pVSync(video_out_pVSync),             // output
    .video_out_pVDE(video_out_pVDE)                  // output
  );

  // pixel_stream (dout) <---> fifo <---> display controller (din)
  // Connecting these blocks is just a matter of conveniently hooking up 
  // relevant signals from both ends
  // (valid goes with valid, ready goes with ready, data goes with data)
  assign fifo_enq_valid          = pixel_stream_dout_valid;
  assign fifo_enq_data           = pixel_stream_dout;
  assign pixel_stream_dout_ready = fifo_enq_ready;

  assign fifo_deq_ready          = pixel_stream_din_ready;
  assign pixel_stream_din_valid  = fifo_deq_valid;
  assign pixel_stream_din        = {fifo_deq_data, fifo_deq_data, fifo_deq_data};

endmodule
