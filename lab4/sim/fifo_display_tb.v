`timescale 1ns/1ns
`define CLOCK_PERIOD 25

module fifo_display_tb();
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

  localparam IMG_WIDTH  = 800;
  localparam IMG_HEIGHT = 600;

  reg rst;
  reg play;

  wire [23:0] video_out_pData;
  wire video_out_pHSync, video_out_pVSync, video_out_pVDE;

  fifo_display DUT (
    .pixel_clk(clk),
    .rst(rst),

    .play(play),

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

  reg [31:0] index;
  reg [7:0]  img_input  [IMG_WIDTH*IMG_HEIGHT-1:0];

  always @(posedge clk) begin
    if (rst === 1'b1) begin
      index <= 0;
    end
    else if (play === 1'b1) begin
      if (video_out_pVDE === 1'b1) begin
        if (video_out_pData[7:0] !== img_input[index]) begin
          $display("Failed! Mismatch at %d: input=%h, output=%h",
            index, img_input[index], video_out_pData[7:0]);
          $finish();
        end
        index <= index + 1;
      end
    end
  end

  initial begin
    rst = 1'b0;
    play = 1'b0;
    $readmemb("ucb_wheeler_hall_bin.mif", img_input);

    // Hold reset for 5 cycles
    @(negedge clk);
    rst = 1'b1;

    repeat (5) @(posedge clk);

    @(negedge clk);
    rst = 1'b0;

    repeat (10) @(posedge clk);

    // Now, play
    @(negedge clk);
    play = 1'b1;

    // Check video timing signals
    check_video_timing();
    $display("Done after %d cycles! Tests passed!", cycle_cnt);
    $finish();
  end

  initial begin
    // Should not take more than the number of cycles needed to cycle
    // through the entire video frame (plus some spare cycles)
    repeat (2 * H_FRAME * V_FRAME + 1000) @(posedge clk);

    $display("Timeout!");
    $finish();
  end

endmodule
