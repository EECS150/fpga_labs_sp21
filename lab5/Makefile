
# IVerilog examples
# make iverilog-sim top={uart_transmitter_tb, echo_tb, inside_test_tb}

IV_SRCS = src/uart_transmitter.v \
          src/uart_receiver.v \
          src/uart.v \
          src/inside_test.v \
          sim/uart_transmitter_tb.v \
          sim/echo_tb.v \
          sim/inside_test_tb.v

top = testbench_name
sim_exec = $(top).out
sim_vcd  = $(top).vcd

iverilog-compile $(sim_exec): $(IV_SRCS)
	iverilog $(IV_SRCS) -I src/ ../lib/EECS151.v -s $(top) -o $(sim_exec)

iverilog-sim $(sim_vcd): $(sim_exec)
	./$(sim_exec)

wave: $(sim_vcd)
	gtkwave $(sim_vcd)

# Vivado flows

VERILOG_SRCS = src/*.v
Z1TOP_XPR = $(proj)/$(proj).xpr

$(Z1TOP_XPR): $(VERILOG_SRCS)
	vivado -mode batch -source scripts/build_project.tcl -tclargs $(proj)

.PHONY: build-project
build-project: $(Z1TOP_XPR)

.PHONY: sim
sim: $(VERILOG_SRCS)
	vivado -mode batch -source scripts/sim.tcl -tclargs $(proj) $(tb)

.PHONY: write-bitstream
write-bitstream: $(Z1TOP_XPR)
	vivado -mode batch -source scripts/write_bitstream.tcl -tclargs $(proj)

.PHONY: program-fpga
program-fpga:
	vivado -mode batch -source scripts/program_fpga.tcl -tclargs $(bs)

.PHONY: clean
# "make clean" won't remove your project folders
clean:
	rm -rf *.log *.jou *.str *.out *.vcd
