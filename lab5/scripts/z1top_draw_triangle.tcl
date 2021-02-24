# Add source files
add_files -norecurse src/z1top_draw_triangle.v
add_files -norecurse src/button_parser.v
add_files -norecurse src/debouncer.v
add_files -norecurse src/synchronizer.v
add_files -norecurse src/edge_detector.v
add_files -norecurse src/clk_wiz.v
add_files -norecurse src/fifo.v
add_files -norecurse src/uart_receiver.v
add_files -norecurse src/uart_transmitter.v
add_files -norecurse src/colors.vh
add_files -norecurse src/inside_test.v
add_files -norecurse src/draw_triangle.v

check_syntax

# This project needs Block Design
source scripts/z1top_draw_triangle_bd.tcl
