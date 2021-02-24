
set_property ip_repo_paths digilent_ips [current_project]
update_ip_catalog

create_bd_design "z1top_draw_triangle_bd"

#create_bd_cell -type ip -vlnv digilentinc.com:ip:rgb2dvi:1.4 rgb2dvi_0
# Create instance: rgb2dvi_0, and set properties
set rgb2dvi_0 [ create_bd_cell -type ip -vlnv digilentinc.com:ip:rgb2dvi:1.4 rgb2dvi_0 ]
set_property -dict [ list CONFIG.kClkRange {3} ] $rgb2dvi_0

# Create instance: z1top_draw_triangle_0, and set properties
set z1top_draw_triangle_0 [create_bd_cell -type module -reference z1top_draw_triangle z1top_draw_triangle_0]

# Create interface ports
set TMDS_0 [ create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:tmds_rtl:1.0 TMDS_0 ]

# Create ports
set BUTTONS [ create_bd_port -dir I -from 3 -to 0 BUTTONS ]
set FPGA_SERIAL_RX [ create_bd_port -dir I FPGA_SERIAL_RX ]
set FPGA_SERIAL_TX [ create_bd_port -dir O FPGA_SERIAL_TX ]
set CLK_125MHZ_FPGA [ create_bd_port -dir I CLK_125MHZ_FPGA ]
set LEDS [ create_bd_port -dir O -from 5 -to 0 LEDS ]
set SWITCHES [ create_bd_port -dir I -from 1 -to 0 SWITCHES ]

# Create interface connections
connect_bd_intf_net -intf_net rgb2dvi_0_TMDS [get_bd_intf_ports TMDS_0] [get_bd_intf_pins rgb2dvi_0/TMDS]

# Create port connections
connect_bd_net -net BUTTONS [get_bd_ports BUTTONS] [get_bd_pins z1top_draw_triangle_0/BUTTONS]
connect_bd_net -net FPGA_SERIAL_RX [get_bd_ports FPGA_SERIAL_RX] [get_bd_pins z1top_draw_triangle_0/FPGA_SERIAL_RX]
connect_bd_net -net FPGA_SERIAL_TX [get_bd_ports FPGA_SERIAL_TX] [get_bd_pins z1top_draw_triangle_0/FPGA_SERIAL_TX]
connect_bd_net -net CLK_125MHZ_FPGA [get_bd_ports CLK_125MHZ_FPGA] [get_bd_pins z1top_draw_triangle_0/CLK_125MHZ_FPGA]
connect_bd_net -net SWITCHES [get_bd_ports SWITCHES] [get_bd_pins z1top_draw_triangle_0/SWITCHES]
connect_bd_net -net z1top_draw_triangle_0_LEDS [get_bd_ports LEDS] [get_bd_pins z1top_draw_triangle_0/LEDS]
connect_bd_net -net z1top_draw_triangle_0_pixel_clk [get_bd_pins rgb2dvi_0/PixelClk] [get_bd_pins z1top_draw_triangle_0/pixel_clk]
connect_bd_net -net z1top_draw_triangle_0_video_out_pData [get_bd_pins rgb2dvi_0/vid_pData] [get_bd_pins z1top_draw_triangle_0/video_out_pData]
connect_bd_net -net z1top_draw_triangle_0_video_out_pHSync [get_bd_pins rgb2dvi_0/vid_pHSync] [get_bd_pins z1top_draw_triangle_0/video_out_pHSync]
connect_bd_net -net z1top_draw_triangle_0_video_out_pVDE [get_bd_pins rgb2dvi_0/vid_pVDE] [get_bd_pins z1top_draw_triangle_0/video_out_pVDE]
connect_bd_net -net z1top_draw_triangle_0_video_out_pVSync [get_bd_pins rgb2dvi_0/vid_pVSync] [get_bd_pins z1top_draw_triangle_0/video_out_pVSync]

validate_bd_design
save_bd_design

make_wrapper -files [get_files ${project_name}/${project_name}.srcs/sources_1/bd/z1top_draw_triangle_bd/z1top_draw_triangle_bd.bd] -top
add_files -norecurse           ${project_name}/${project_name}.srcs/sources_1/bd/z1top_draw_triangle_bd/hdl/z1top_draw_triangle_bd_wrapper.v
update_compile_order -fileset sources_1
set_property top z1top_draw_triangle_bd_wrapper [current_fileset]
