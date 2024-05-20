startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup

startgroup
set_property -dict [list CONFIG.NUM_MI {4}] [get_bd_cells axi_interconnect_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:MasterController:1.0 MasterController_0
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:ImageController:1.0 ImageController_0
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:HDMIController:1.0 HDMIController_0
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:GTH_serializer:1.0 GTH_serializer_0
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:IOController:1.0 CameraExposureStart 
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:IOController:1.0 CameraExposureEnd
endgroup

connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins MasterController_0/s_axi]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins ImageController_0/s_axi]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins CameraExposureStart/s_axi]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins CameraExposureEnd/s_axi]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/M00_ACLK]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins MasterController_0/s_axi_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins GTH_serializer_0/s_axi_clk]

connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins axi_interconnect_0/M01_ACLK]
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins axi_interconnect_0/M02_ACLK] 
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins axi_interconnect_0/M03_ACLK] 
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins HDMIController_0/clk_pixel]
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins MasterController_0/clk_pixel]
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins ImageController_0/s_axi_aclk]
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins CameraExposureEnd/s_axi_aclk] 
connect_bd_net [get_bd_pins GTH_serializer_0/clk_pixel] [get_bd_pins CameraExposureStart/s_axi_aclk] 

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins MasterController_0/s_axi_aresetn]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins GTH_serializer_0/s_axi_resetn]

connect_bd_net [get_bd_pins MasterController_0/pixel_clk_resetn] [get_bd_pins proc_sys_reset_1/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins ImageController_0/s_axi_aresetn]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins GTH_serializer_0/clk_pixel_resetn]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M01_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M02_ARESETN] 
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M03_ARESETN] 
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins HDMIController_0/clk_pixel_resetn]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins CameraExposureStart/s_axi_aresetn] 
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins CameraExposureEnd/s_axi_aresetn]

connect_bd_net [get_bd_pins ImageController_0/auto_start] [get_bd_pins MasterController_0/auto_start]
connect_bd_net [get_bd_pins ImageController_0/counter] [get_bd_pins MasterController_0/counter]
connect_bd_net [get_bd_pins ImageController_0/rgb] [get_bd_pins HDMIController_0/rgb]
connect_bd_net [get_bd_pins ImageController_0/irq_signal] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

connect_bd_net [get_bd_pins HDMIController_0/cx] [get_bd_pins ImageController_0/cx]
connect_bd_net [get_bd_pins HDMIController_0/cy] [get_bd_pins ImageController_0/cy]
connect_bd_net [get_bd_pins HDMIController_0/tmds0_10bit] [get_bd_pins GTH_serializer_0/r]
connect_bd_net [get_bd_pins HDMIController_0/tmds1_10bit] [get_bd_pins GTH_serializer_0/g]
connect_bd_net [get_bd_pins HDMIController_0/tmds2_10bit] [get_bd_pins GTH_serializer_0/b]

connect_bd_net [get_bd_ports HDMI_DRU_CLOCK_C_P] [get_bd_pins GTH_serializer_0/gtrefclk00_in_p]
connect_bd_net [get_bd_ports HDMI_DRU_CLOCK_C_N] [get_bd_pins GTH_serializer_0/gtrefclk00_in_n]
connect_bd_net [get_bd_ports HDMI_TX_EN] [get_bd_pins GTH_serializer_0/out_en]
connect_bd_net [get_bd_ports HDMI_TX_LVDS_OUT_P] [get_bd_pins GTH_serializer_0/tmds_clk_p]
connect_bd_net [get_bd_ports HDMI_TX_LVDS_OUT_N] [get_bd_pins GTH_serializer_0/tmds_clk_n]
connect_bd_net [get_bd_ports HDMI_TX0_N] [get_bd_pins GTH_serializer_0/gthtxn_out_0]
connect_bd_net [get_bd_ports HDMI_TX0_P] [get_bd_pins GTH_serializer_0/gthtxp_out_0]
connect_bd_net [get_bd_ports HDMI_TX1_N] [get_bd_pins GTH_serializer_0/gthtxn_out_1]
connect_bd_net [get_bd_ports HDMI_TX1_P] [get_bd_pins GTH_serializer_0/gthtxp_out_1]
connect_bd_net [get_bd_ports HDMI_TX2_N] [get_bd_pins GTH_serializer_0/gthtxn_out_2]
connect_bd_net [get_bd_ports HDMI_TX2_P] [get_bd_pins GTH_serializer_0/gthtxp_out_2]

connect_bd_net [get_bd_pins CameraExposureEnd/output_signal] [get_bd_pins ImageController_0/image_change]
connect_bd_net [get_bd_pins CameraExposureEnd/auto_start] [get_bd_pins MasterController_0/auto_start]
connect_bd_net [get_bd_pins CameraExposureEnd/input_signal] [get_bd_ports PMOD1_0] 

connect_bd_net [get_bd_pins CameraExposureStart/output_signal] [get_bd_ports PMOD0_0] 
connect_bd_net [get_bd_pins CameraExposureStart/input_signal] [get_bd_pins ImageController_0/camera_exposure_start] 
connect_bd_net [get_bd_pins CameraExposureStart/auto_start] [get_bd_pins MasterController_0/auto_start]

assign_bd_address -target_address_space /zynq_ultra_ps_e_0/Data [get_bd_addr_segs MasterController_0/s_axi/reg0] -force
set_property range 4K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_MasterController_0_reg0}]
set_property offset 0x00A0000000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_MasterController_0_reg0}]
assign_bd_address -target_address_space /zynq_ultra_ps_e_0/Data [get_bd_addr_segs ImageController_0/s_axi/reg0] -force
set_property range 4K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ImageController_0_reg0}]
set_property offset 0x00A0001000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ImageController_0_reg0}]
assign_bd_address -target_address_space /zynq_ultra_ps_e_0/Data [get_bd_addr_segs CameraExposureStart/s_axi/reg0] -force
set_property range 4K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_CameraExposureStart_reg0}]
set_property offset 0x00A0002000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_CameraExposureStart_reg0}]
assign_bd_address -target_address_space /zynq_ultra_ps_e_0/Data [get_bd_addr_segs CameraExposureEnd/s_axi/reg0] -force
set_property range 4K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_CameraExposureEnd_reg0}]
set_property offset 0x00A0003000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_CameraExposureEnd_reg0}]

save_bd_design

make_wrapper -files [get_files C:/Jeonghyun/Lab/ZCU104/ZCU104_Main/ZCU104_Main/ZCU104_Main.srcs/sources_1/bd/ZCU104_Main_blk/ZCU104_Main_blk.bd] -top
add_files -norecurse c:/Jeonghyun/Lab/ZCU104/ZCU104_Main/ZCU104_Main/ZCU104_Main.gen/sources_1/bd/ZCU104_Main_blk/hdl/ZCU104_Main_blk_wrapper.v