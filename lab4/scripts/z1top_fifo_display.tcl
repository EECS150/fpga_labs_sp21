# Add source files
add_files -norecurse src/colors.vh
add_files -norecurse src/fifo_display.v
add_files -norecurse src/z1top_fifo_display.v
add_files -norecurse src/button_parser.v
add_files -norecurse src/debouncer.v
add_files -norecurse src/synchronizer.v
add_files -norecurse src/edge_detector.v
add_files -norecurse src/display_controller.v
add_files -norecurse src/clk_wiz.v
add_files -norecurse src/pixel_stream.v
add_files -norecurse src/fifo.v

# Add memory initialization file
add_files -norecurse src/ucb_wheeler_hall_bin.mif

check_syntax

# This project needs Block Design
source scripts/z1top_fifo_display_bd.tcl
