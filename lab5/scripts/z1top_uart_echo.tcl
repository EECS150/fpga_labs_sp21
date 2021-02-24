add_files -norecurse src/z1top_uart_echo.v
add_files -norecurse src/button_parser.v
add_files -norecurse src/debouncer.v
add_files -norecurse src/synchronizer.v
add_files -norecurse src/edge_detector.v
add_files -norecurse src/fifo.v
add_files -norecurse src/uart_transmitter.v
add_files -norecurse src/uart_receiver.v
add_files -norecurse src/uart.v

set_property top z1top_uart_echo [get_filesets sources_1]
