# Add source files
add_files -norecurse src/z1top_fifo_io.v
add_files -norecurse src/button_parser.v
add_files -norecurse src/debouncer.v
add_files -norecurse src/synchronizer.v
add_files -norecurse src/edge_detector.v
add_files -norecurse src/fifo.v

check_syntax
