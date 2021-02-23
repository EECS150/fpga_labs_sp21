
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
	rm -rf *.log *.jou *.str
