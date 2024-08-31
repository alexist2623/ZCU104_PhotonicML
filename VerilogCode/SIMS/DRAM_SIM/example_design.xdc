create_clock -period 7.997 [get_ports c0_sys_clk_p]


#Pin LOC constraints for the status signals init_calib_complete and data_compare_error

#LOC constraints provided if the pins are selected for status signals

set_property PACKAGE_PIN AH14 [ get_ports "c0_data_compare_error" ]
set_property IOSTANDARD LVCMOS12 [ get_ports "c0_data_compare_error" ]

set_property DRIVE 8 [ get_ports "c0_data_compare_error" ]

set_property PACKAGE_PIN AJ14 [ get_ports "c0_init_calib_complete" ]
set_property IOSTANDARD LVCMOS12 [ get_ports "c0_init_calib_complete" ]

set_property DRIVE 8 [ get_ports "c0_init_calib_complete" ]

set_property IOSTANDARD DIFF_SSTL12 [ get_ports "c0_sys_clk_p" ]

set_property IOSTANDARD DIFF_SSTL12 [ get_ports "c0_sys_clk_n" ]

set_property PACKAGE_PIN AF17 [ get_ports "sys_rst" ]
set_property IOSTANDARD LVCMOS12 [ get_ports "sys_rst" ]

set_property PACKAGE_PIN AJ17 [ get_ports "c0_sys_clk_p" ]
set_property PACKAGE_PIN AK17 [ get_ports "c0_sys_clk_n" ]
set_property PACKAGE_PIN AA14 [ get_ports "c0_ddr4_dq[4]" ]
set_property PACKAGE_PIN AA15 [ get_ports "c0_ddr4_dqs_c[0]" ]
set_property PACKAGE_PIN AA16 [ get_ports "c0_ddr4_dqs_t[0]" ]
set_property PACKAGE_PIN AA18 [ get_ports "c0_ddr4_dqs_t[4]" ]
set_property PACKAGE_PIN AA19 [ get_ports "c0_ddr4_dq[38]" ]
set_property PACKAGE_PIN AA20 [ get_ports "c0_ddr4_dq[39]" ]
set_property PACKAGE_PIN AB14 [ get_ports "c0_ddr4_dq[5]" ]
set_property PACKAGE_PIN AB15 [ get_ports "c0_ddr4_dq[3]" ]
set_property PACKAGE_PIN AB16 [ get_ports "c0_ddr4_dq[2]" ]
set_property PACKAGE_PIN AB18 [ get_ports "c0_ddr4_dqs_c[4]" ]
set_property PACKAGE_PIN AB19 [ get_ports "c0_ddr4_dq[32]" ]
set_property PACKAGE_PIN AC16 [ get_ports "c0_ddr4_dq[1]" ]
set_property PACKAGE_PIN AC17 [ get_ports "c0_ddr4_dq[0]" ]
set_property PACKAGE_PIN AC18 [ get_ports "c0_ddr4_dq[36]" ]
set_property PACKAGE_PIN AC19 [ get_ports "c0_ddr4_dq[33]" ]
set_property PACKAGE_PIN AD15 [ get_ports "c0_ddr4_dm_dbi_n[0]" ]
set_property PACKAGE_PIN AD16 [ get_ports "c0_ddr4_dq[7]" ]
set_property PACKAGE_PIN AD17 [ get_ports "c0_ddr4_dq[6]" ]
set_property PACKAGE_PIN AD19 [ get_ports "c0_ddr4_dq[37]" ]
set_property PACKAGE_PIN AD20 [ get_ports "c0_ddr4_dq[34]" ]
set_property PACKAGE_PIN AE17 [ get_ports "c0_ddr4_reset_n" ]
set_property PACKAGE_PIN AE18 [ get_ports "c0_ddr4_dm_dbi_n[4]" ]
set_property PACKAGE_PIN AE20 [ get_ports "c0_ddr4_dq[35]" ]
set_property PACKAGE_PIN AE23 [ get_ports "c0_ddr4_dq[30]" ]
set_property PACKAGE_PIN AE24 [ get_ports "c0_ddr4_dq[31]" ]
set_property PACKAGE_PIN AF18 [ get_ports "c0_ddr4_odt[0]" ]
set_property PACKAGE_PIN AF21 [ get_ports "c0_ddr4_dq[28]" ]
set_property PACKAGE_PIN AF22 [ get_ports "c0_ddr4_dq[29]" ]
set_property PACKAGE_PIN AF23 [ get_ports "c0_ddr4_dqs_t[3]" ]
set_property PACKAGE_PIN AF8 [ get_ports "c0_ddr4_dq[62]" ]
set_property PACKAGE_PIN AG10 [ get_ports "c0_ddr4_dq[61]" ]
set_property PACKAGE_PIN AG11 [ get_ports "c0_ddr4_dq[60]" ]
set_property PACKAGE_PIN AG13 [ get_ports "c0_ddr4_dq[58]" ]
set_property PACKAGE_PIN AG18 [ get_ports "c0_ddr4_act_n" ]
set_property PACKAGE_PIN AG19 [ get_ports "c0_ddr4_dq[26]" ]
set_property PACKAGE_PIN AG20 [ get_ports "c0_ddr4_dq[27]" ]
set_property PACKAGE_PIN AG21 [ get_ports "c0_ddr4_dq[24]" ]
set_property PACKAGE_PIN AG23 [ get_ports "c0_ddr4_dqs_c[3]" ]
set_property PACKAGE_PIN AG8 [ get_ports "c0_ddr4_dq[63]" ]
set_property PACKAGE_PIN AG9 [ get_ports "c0_ddr4_dqs_t[7]" ]
set_property PACKAGE_PIN AH11 [ get_ports "c0_ddr4_dq[56]" ]
set_property PACKAGE_PIN AH12 [ get_ports "c0_ddr4_dm_dbi_n[7]" ]
set_property PACKAGE_PIN AH13 [ get_ports "c0_ddr4_dq[59]" ]
set_property PACKAGE_PIN AH17 [ get_ports "c0_ddr4_cke[0]" ]
set_property PACKAGE_PIN AH18 [ get_ports "c0_ddr4_cs_n[0]" ]
set_property PACKAGE_PIN AH21 [ get_ports "c0_ddr4_dq[25]" ]
set_property PACKAGE_PIN AH22 [ get_ports "c0_ddr4_dm_dbi_n[3]" ]
set_property PACKAGE_PIN AH9 [ get_ports "c0_ddr4_dqs_c[7]" ]
set_property PACKAGE_PIN AJ10 [ get_ports "c0_ddr4_dq[52]" ]
set_property PACKAGE_PIN AJ11 [ get_ports "c0_ddr4_dq[57]" ]
set_property PACKAGE_PIN AJ15 [ get_ports "c0_ddr4_bg[0]" ]
set_property PACKAGE_PIN AJ16 [ get_ports "c0_ddr4_ba[1]" ]
set_property PACKAGE_PIN AJ19 [ get_ports "c0_ddr4_dq[18]" ]
set_property PACKAGE_PIN AJ20 [ get_ports "c0_ddr4_dq[20]" ]
set_property PACKAGE_PIN AJ21 [ get_ports "c0_ddr4_dq[22]" ]
set_property PACKAGE_PIN AJ22 [ get_ports "c0_ddr4_dq[23]" ]
set_property PACKAGE_PIN AJ9 [ get_ports "c0_ddr4_dq[54]" ]
set_property PACKAGE_PIN AK10 [ get_ports "c0_ddr4_dq[53]" ]
set_property PACKAGE_PIN AK12 [ get_ports "c0_ddr4_dq[50]" ]
set_property PACKAGE_PIN AK13 [ get_ports "c0_ddr4_dm_dbi_n[6]" ]
set_property PACKAGE_PIN AK14 [ get_ports "c0_ddr4_ba[0]" ]
set_property PACKAGE_PIN AK15 [ get_ports "c0_ddr4_adr[16]" ]
set_property PACKAGE_PIN AK18 [ get_ports "c0_ddr4_adr[14]" ]
set_property PACKAGE_PIN AK19 [ get_ports "c0_ddr4_dq[19]" ]
set_property PACKAGE_PIN AK20 [ get_ports "c0_ddr4_dq[21]" ]
set_property PACKAGE_PIN AK22 [ get_ports "c0_ddr4_dqs_t[2]" ]
set_property PACKAGE_PIN AK23 [ get_ports "c0_ddr4_dqs_c[2]" ]
set_property PACKAGE_PIN AK8 [ get_ports "c0_ddr4_dqs_t[6]" ]
set_property PACKAGE_PIN AK9 [ get_ports "c0_ddr4_dq[55]" ]
set_property PACKAGE_PIN AL10 [ get_ports "c0_ddr4_dq[49]" ]
set_property PACKAGE_PIN AL11 [ get_ports "c0_ddr4_dq[48]" ]
set_property PACKAGE_PIN AL12 [ get_ports "c0_ddr4_dq[51]" ]
set_property PACKAGE_PIN AL15 [ get_ports "c0_ddr4_adr[13]" ]
set_property PACKAGE_PIN AL16 [ get_ports "c0_ddr4_adr[12]" ]
set_property PACKAGE_PIN AL17 [ get_ports "c0_ddr4_bg[1]" ]
set_property PACKAGE_PIN AL18 [ get_ports "c0_ddr4_adr[15]" ]
set_property PACKAGE_PIN AL20 [ get_ports "c0_ddr4_dm_dbi_n[2]" ]
set_property PACKAGE_PIN AL22 [ get_ports "c0_ddr4_dq[16]" ]
set_property PACKAGE_PIN AL23 [ get_ports "c0_ddr4_dq[17]" ]
set_property PACKAGE_PIN AL8 [ get_ports "c0_ddr4_dqs_c[6]" ]
set_property PACKAGE_PIN AM10 [ get_ports "c0_ddr4_dq[45]" ]
set_property PACKAGE_PIN AM11 [ get_ports "c0_ddr4_dq[44]" ]
set_property PACKAGE_PIN AM14 [ get_ports "c0_ddr4_ck_t[0]" ]
set_property PACKAGE_PIN AM15 [ get_ports "c0_ddr4_adr[11]" ]
set_property PACKAGE_PIN AM16 [ get_ports "c0_ddr4_adr[10]" ]
set_property PACKAGE_PIN AM18 [ get_ports "c0_ddr4_adr[4]" ]
set_property PACKAGE_PIN AM19 [ get_ports "c0_ddr4_dq[8]" ]
set_property PACKAGE_PIN AM21 [ get_ports "c0_ddr4_dqs_t[1]" ]
set_property PACKAGE_PIN AM23 [ get_ports "c0_ddr4_dq[14]" ]
set_property PACKAGE_PIN AM8 [ get_ports "c0_ddr4_dq[47]" ]
set_property PACKAGE_PIN AM9 [ get_ports "c0_ddr4_dq[46]" ]
set_property PACKAGE_PIN AN11 [ get_ports "c0_ddr4_dq[42]" ]
set_property PACKAGE_PIN AN12 [ get_ports "c0_ddr4_dm_dbi_n[5]" ]
set_property PACKAGE_PIN AN13 [ get_ports "c0_ddr4_adr[2]" ]
set_property PACKAGE_PIN AN14 [ get_ports "c0_ddr4_ck_c[0]" ]
set_property PACKAGE_PIN AN16 [ get_ports "c0_ddr4_adr[9]" ]
set_property PACKAGE_PIN AN17 [ get_ports "c0_ddr4_adr[8]" ]
set_property PACKAGE_PIN AN18 [ get_ports "c0_ddr4_adr[5]" ]
set_property PACKAGE_PIN AN19 [ get_ports "c0_ddr4_dq[9]" ]
set_property PACKAGE_PIN AN21 [ get_ports "c0_ddr4_dqs_c[1]" ]
set_property PACKAGE_PIN AN22 [ get_ports "c0_ddr4_dq[12]" ]
set_property PACKAGE_PIN AN23 [ get_ports "c0_ddr4_dq[15]" ]
set_property PACKAGE_PIN AN8 [ get_ports "c0_ddr4_dqs_c[5]" ]
set_property PACKAGE_PIN AN9 [ get_ports "c0_ddr4_dqs_t[5]" ]
set_property PACKAGE_PIN AP10 [ get_ports "c0_ddr4_dq[40]" ]
set_property PACKAGE_PIN AP11 [ get_ports "c0_ddr4_dq[43]" ]
set_property PACKAGE_PIN AP13 [ get_ports "c0_ddr4_adr[3]" ]
set_property PACKAGE_PIN AP15 [ get_ports "c0_ddr4_adr[7]" ]
set_property PACKAGE_PIN AP16 [ get_ports "c0_ddr4_adr[6]" ]
set_property PACKAGE_PIN AP17 [ get_ports "c0_ddr4_adr[1]" ]
set_property PACKAGE_PIN AP18 [ get_ports "c0_ddr4_adr[0]" ]
set_property PACKAGE_PIN AP19 [ get_ports "c0_ddr4_dm_dbi_n[1]" ]
set_property PACKAGE_PIN AP21 [ get_ports "c0_ddr4_dq[10]" ]
set_property PACKAGE_PIN AP22 [ get_ports "c0_ddr4_dq[11]" ]
set_property PACKAGE_PIN AP23 [ get_ports "c0_ddr4_dq[13]" ]
set_property PACKAGE_PIN AP9 [ get_ports "c0_ddr4_dq[41]" ]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins -hier -filter {NAME =~ */u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKIN1}]


