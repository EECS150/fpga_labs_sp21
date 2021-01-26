## Reference: https://reference.digilentinc.com/_media/reference/programmable-logic/pynq-z1/pynq-z1_c.zip
##

# SW0
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports a]
# SW1
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports b]

# LD0
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports c]
