add_files -norecurse src/z1top_uart_tx.v
add_files -norecurse src/button_parser.v
add_files -norecurse src/debouncer.v
add_files -norecurse src/synchronizer.v
add_files -norecurse src/edge_detector.v
add_files -norecurse src/read_rom.v
add_files -norecurse src/uart_transmitter.v
# Add memory initialization file
add_files -norecurse src/text.mif

set_property top z1top_uart_tx [get_filesets sources_1]
