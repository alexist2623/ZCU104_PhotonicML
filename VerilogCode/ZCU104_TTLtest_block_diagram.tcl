connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/M00_ACLK]
startgroup
set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_0]
endgroup
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:TTLController:1.0 TTLController_0
endgroup
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins TTLController_0/s_axi]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins TTLController_0/s_axi_aclk]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins TTLController_0/s_axi_aresetn]
connect_bd_net [get_bd_ports FMC_LPC_LA00_CC_P] [get_bd_pins TTLController_0/ttl_out_00_p]
connect_bd_net [get_bd_ports FMC_LPC_LA00_CC_N] [get_bd_pins TTLController_0/ttl_out_00_n]
connect_bd_net [get_bd_ports FMC_LPC_LA01_CC_P] [get_bd_pins TTLController_0/ttl_out_01_p]
connect_bd_net [get_bd_ports FMC_LPC_LA01_CC_N] [get_bd_pins TTLController_0/ttl_out_01_n]
connect_bd_net [get_bd_ports FMC_LPC_LA01_P] [get_bd_pins TTLController_0/ttl_out_01_p]
connect_bd_net [get_bd_ports FMC_LPC_LA02_P] [get_bd_pins TTLController_0/ttl_out_02_p]
connect_bd_net [get_bd_ports FMC_LPC_LA02_N] [get_bd_pins TTLController_0/ttl_out_02_n]


connect_bd_net [get_bd_ports FMC_LPC_LA03_P] [get_bd_pins TTLController_0/ttl_out_03_p]
connect_bd_net [get_bd_ports FMC_LPC_LA03_N] [get_bd_pins TTLController_0/ttl_out_03_n]


connect_bd_net [get_bd_ports FMC_LPC_LA04_P] [get_bd_pins TTLController_0/ttl_out_04_p]
connect_bd_net [get_bd_ports FMC_LPC_LA04_N] [get_bd_pins TTLController_0/ttl_out_04_n]


connect_bd_net [get_bd_ports FMC_LPC_LA05_P] [get_bd_pins TTLController_0/ttl_out_05_p]
connect_bd_net [get_bd_ports FMC_LPC_LA05_N] [get_bd_pins TTLController_0/ttl_out_05_n]


connect_bd_net [get_bd_ports FMC_LPC_LA06_P] [get_bd_pins TTLController_0/ttl_out_06_p]
connect_bd_net [get_bd_ports FMC_LPC_LA06_N] [get_bd_pins TTLController_0/ttl_out_06_n]


connect_bd_net [get_bd_ports FMC_LPC_LA07_P] [get_bd_pins TTLController_0/ttl_out_07_p]
connect_bd_net [get_bd_ports FMC_LPC_LA07_N] [get_bd_pins TTLController_0/ttl_out_07_n]


connect_bd_net [get_bd_ports FMC_LPC_LA08_P] [get_bd_pins TTLController_0/ttl_out_08_p]
connect_bd_net [get_bd_ports FMC_LPC_LA08_N] [get_bd_pins TTLController_0/ttl_out_08_n]


connect_bd_net [get_bd_ports FMC_LPC_LA09_P] [get_bd_pins TTLController_0/ttl_out_09_p]
connect_bd_net [get_bd_ports FMC_LPC_LA09_N] [get_bd_pins TTLController_0/ttl_out_09_n]


connect_bd_net [get_bd_ports FMC_LPC_LA10_P] [get_bd_pins TTLController_0/ttl_out_10_p]
connect_bd_net [get_bd_ports FMC_LPC_LA10_N] [get_bd_pins TTLController_0/ttl_out_10_n]


connect_bd_net [get_bd_ports FMC_LPC_LA11_P] [get_bd_pins TTLController_0/ttl_out_11_p]
connect_bd_net [get_bd_ports FMC_LPC_LA11_N] [get_bd_pins TTLController_0/ttl_out_11_n]


connect_bd_net [get_bd_ports FMC_LPC_LA12_P] [get_bd_pins TTLController_0/ttl_out_12_p]
connect_bd_net [get_bd_ports FMC_LPC_LA12_N] [get_bd_pins TTLController_0/ttl_out_12_n]


connect_bd_net [get_bd_ports FMC_LPC_LA13_P] [get_bd_pins TTLController_0/ttl_out_13_p]
connect_bd_net [get_bd_ports FMC_LPC_LA13_N] [get_bd_pins TTLController_0/ttl_out_13_n]


connect_bd_net [get_bd_ports FMC_LPC_LA14_P] [get_bd_pins TTLController_0/ttl_out_14_p]
connect_bd_net [get_bd_ports FMC_LPC_LA14_N] [get_bd_pins TTLController_0/ttl_out_14_n]


connect_bd_net [get_bd_ports FMC_LPC_LA15_P] [get_bd_pins TTLController_0/ttl_out_15_p]
connect_bd_net [get_bd_ports FMC_LPC_LA15_N] [get_bd_pins TTLController_0/ttl_out_15_n]


connect_bd_net [get_bd_ports FMC_LPC_LA16_P] [get_bd_pins TTLController_0/ttl_out_16_p]
connect_bd_net [get_bd_ports FMC_LPC_LA16_N] [get_bd_pins TTLController_0/ttl_out_16_n]


connect_bd_net [get_bd_ports FMC_LPC_LA17_CC_P] [get_bd_pins TTLController_0/ttl_out_17_p]
connect_bd_net [get_bd_ports FMC_LPC_LA17_CC_N] [get_bd_pins TTLController_0/ttl_out_17_n]


connect_bd_net [get_bd_ports FMC_LPC_LA18_CC_P] [get_bd_pins TTLController_0/ttl_out_18_p]
connect_bd_net [get_bd_ports FMC_LPC_LA18_CC_N] [get_bd_pins TTLController_0/ttl_out_18_n]


connect_bd_net [get_bd_ports FMC_LPC_LA19_P] [get_bd_pins TTLController_0/ttl_out_19_p]
connect_bd_net [get_bd_ports FMC_LPC_LA19_N] [get_bd_pins TTLController_0/ttl_out_19_n]


connect_bd_net [get_bd_ports FMC_LPC_LA20_P] [get_bd_pins TTLController_0/ttl_out_20_p]
connect_bd_net [get_bd_ports FMC_LPC_LA20_N] [get_bd_pins TTLController_0/ttl_out_20_n]


connect_bd_net [get_bd_ports FMC_LPC_LA21_P] [get_bd_pins TTLController_0/ttl_out_21_p]
connect_bd_net [get_bd_ports FMC_LPC_LA21_N] [get_bd_pins TTLController_0/ttl_out_21_n]


connect_bd_net [get_bd_ports FMC_LPC_LA22_P] [get_bd_pins TTLController_0/ttl_out_22_p]
connect_bd_net [get_bd_ports FMC_LPC_LA22_N] [get_bd_pins TTLController_0/ttl_out_22_n]


connect_bd_net [get_bd_ports FMC_LPC_LA23_P] [get_bd_pins TTLController_0/ttl_out_23_p]
connect_bd_net [get_bd_ports FMC_LPC_LA23_N] [get_bd_pins TTLController_0/ttl_out_23_n]


connect_bd_net [get_bd_ports FMC_LPC_LA24_P] [get_bd_pins TTLController_0/ttl_out_24_p]
connect_bd_net [get_bd_ports FMC_LPC_LA24_N] [get_bd_pins TTLController_0/ttl_out_24_n]


connect_bd_net [get_bd_ports FMC_LPC_LA25_P] [get_bd_pins TTLController_0/ttl_out_25_p]
connect_bd_net [get_bd_ports FMC_LPC_LA25_N] [get_bd_pins TTLController_0/ttl_out_25_n]


connect_bd_net [get_bd_ports FMC_LPC_LA26_P] [get_bd_pins TTLController_0/ttl_out_26_p]
connect_bd_net [get_bd_ports FMC_LPC_LA26_N] [get_bd_pins TTLController_0/ttl_out_26_n]


connect_bd_net [get_bd_ports FMC_LPC_LA27_P] [get_bd_pins TTLController_0/ttl_out_27_p]
connect_bd_net [get_bd_ports FMC_LPC_LA27_N] [get_bd_pins TTLController_0/ttl_out_27_n]


connect_bd_net [get_bd_ports FMC_LPC_LA28_P] [get_bd_pins TTLController_0/ttl_out_28_p]
connect_bd_net [get_bd_ports FMC_LPC_LA28_N] [get_bd_pins TTLController_0/ttl_out_28_n]


connect_bd_net [get_bd_ports FMC_LPC_LA29_P] [get_bd_pins TTLController_0/ttl_out_29_p]
connect_bd_net [get_bd_ports FMC_LPC_LA29_N] [get_bd_pins TTLController_0/ttl_out_29_n]


connect_bd_net [get_bd_ports FMC_LPC_LA30_P] [get_bd_pins TTLController_0/ttl_out_30_p]
connect_bd_net [get_bd_ports FMC_LPC_LA30_N] [get_bd_pins TTLController_0/ttl_out_30_n]


connect_bd_net [get_bd_ports FMC_LPC_LA31_P] [get_bd_pins TTLController_0/ttl_out_31_p]
connect_bd_net [get_bd_ports FMC_LPC_LA31_N] [get_bd_pins TTLController_0/ttl_out_31_n]