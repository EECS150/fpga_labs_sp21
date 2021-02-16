`timescale 1ns/1ns
`define CLOCK_PERIOD 25

module display_controller_tb();
  reg clk = 0;
  always #(`CLOCK_PERIOD/2) clk = ~clk;

  localparam H_ACTIVE_VIDEO = 800;
  localparam H_FRONT_PORCH  = 40;
  localparam H_SYNC_WIDTH   = 128;
  localparam H_BACK_PORCH   = 88;

  localparam V_ACTIVE_VIDEO = 600;
  localparam V_FRONT_PORCH  = 1;
  localparam V_SYNC_WIDTH   = 4;
  localparam V_BACK_PORCH   = 23;

  localparam H_FRAME = H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH;
  localparam V_FRAME = V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH;

  localparam H_SYNC_START = H_ACTIVE_VIDEO + H_FRONT_PORCH;
  localparam H_SYNC_END   = H_SYNC_START + H_SYNC_WIDTH;
  localparam V_SYNC_START = V_ACTIVE_VIDEO + V_FRONT_PORCH;
  localparam V_SYNC_END   = V_SYNC_START + V_SYNC_WIDTH;

  reg rst;

  reg [23:0] pixel_stream_din;
  reg pixel_stream_din_valid;
  wire pixel_stream_din_ready;

  wire [23:0] video_out_pData;
  wire video_out_pHSync, video_out_pVSync, video_out_pVDE;

  display_controller DUT (
    .pixel_clk(clk),
    .rst(rst),

    // pixel stream input
    .pixel_stream_din(pixel_stream_din),
    .pixel_stream_din_valid(pixel_stream_din_valid),
    .pixel_stream_din_ready(pixel_stream_din_ready),

    // video output signals
    .video_out_pData(video_out_pData),
    .video_out_pHSync(video_out_pHSync),
    .video_out_pVSync(video_out_pVSync),
    .video_out_pVDE(video_out_pVDE)
  );

  reg [31:0] cycle_cnt;
  always @(posedge clk) begin
    if (rst)
      cycle_cnt <= 0;
    else
      cycle_cnt <= cycle_cnt + 1;
  end

  integer i, x, y;

  task check_video_timing;
  begin
    wait (video_out_pVDE === 1'b1);

    for (y = 0; y < V_FRAME; y = y + 1) begin
      for (x = 0; x < H_FRAME; x = x + 1) begin
        @(posedge clk);
        if (x < H_ACTIVE_VIDEO && y < V_ACTIVE_VIDEO) begin
          // Active Video region
          if (video_out_pVDE === 1'b0) begin
            $display("At time %t, Failed! VDE signal should be HIGH!", $time);
            $finish();
          end
        end
        else begin
          if (video_out_pVDE === 1'b1) begin
            $display("At time %t, Failed! VDE signal should be LOW!", $time);
            $finish();
          end
        end

        if (x >= H_SYNC_START && x < H_SYNC_END) begin
          // HSync region
          if (video_out_pHSync === 1'b0) begin
            $display("At time %t, Failed! HSync signal should be HIGH!", $time);
            $finish();
          end
        end
        else begin
          if (video_out_pHSync === 1'b1) begin
            $display("At time %t, Failed! HSync signal should be LOW!", $time);
            $finish();
          end
        end

        if (y >= V_SYNC_START && y < V_SYNC_END) begin
          // VSync region
          if (video_out_pVSync === 1'b0) begin
            $display("At time %t, Failed! VSync signal should be HIGH!", $time);
            $finish();
          end
        end
        else begin
          if (video_out_pVSync === 1'b1) begin
            $display("At time %t, Failed! VSync signal should be LOW!", $time);
            $finish();
          end
        end
      end
    end
  end
  endtask

  initial begin
    rst = 1'b0;
    pixel_stream_din = 0;
    pixel_stream_din_valid = 1'b0;

    // Hold reset for 5 cycles
    @(negedge clk);
    rst = 1'b1;

    repeat (5) @(posedge clk);

    @(negedge clk);
    rst = 1'b0;
    pixel_stream_din_valid = 1'b1;

    // Run twice
    for (i = 0; i < 2; i = i + 1) begin
      check_video_timing();
      $display("[%d] Done after %d cycles! Tests passed!", i, cycle_cnt);
    end

    $finish();
  end

endmodule
