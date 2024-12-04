##################################################################################
##                                                                              ##
## ZCU104 Rev1.0 Master XDC                                                       ##
##                                                                              ##
##################################################################################
set_property PACKAGE_PIN A20      [get_ports "UART2_TXD_FPGA_RXD"] ;# Bank  28 VCCO - VCC1V8   - IO_L21P_T3L_N4_AD8P_28
set_property IOSTANDARD  LVCMOS18 [get_ports "UART2_TXD_FPGA_RXD"] ;# Bank  28 VCCO - VCC1V8   - IO_L21P_T3L_N4_AD8P_28
set_property PACKAGE_PIN C19      [get_ports "UART2_RXD_FPGA_TXD"] ;# Bank  28 VCCO - VCC1V8   - IO_L20N_T3L_N3_AD1N_28
set_property IOSTANDARD  LVCMOS18 [get_ports "UART2_RXD_FPGA_TXD"] ;# Bank  28 VCCO - VCC1V8   - IO_L20N_T3L_N3_AD1N_28
set_property PACKAGE_PIN C18      [get_ports "UART2_RTS_B"] ;# Bank  28 VCCO - VCC1V8   - IO_L20P_T3L_N2_AD1P_28
set_property IOSTANDARD  LVCMOS18 [get_ports "UART2_RTS_B"] ;# Bank  28 VCCO - VCC1V8   - IO_L20P_T3L_N2_AD1P_28
set_property PACKAGE_PIN A19      [get_ports "UART2_CTS_B"] ;# Bank  28 VCCO - VCC1V8   - IO_L19N_T3L_N1_DBC_AD9N_28
set_property IOSTANDARD  LVCMOS18 [get_ports "UART2_CTS_B"] ;# Bank  28 VCCO - VCC1V8   - IO_L19N_T3L_N1_DBC_AD9N_28
set_property PACKAGE_PIN E23      [get_ports "CLK_125_N"] ;# Bank  28 VCCO - VCC1V8   - IO_L13N_T2L_N1_GC_QBC_28
set_property IOSTANDARD  LVDS     [get_ports "CLK_125_N"] ;# Bank  28 VCCO - VCC1V8   - IO_L13N_T2L_N1_GC_QBC_28
set_property PACKAGE_PIN F23      [get_ports "CLK_125_P"] ;# Bank  28 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_28
set_property IOSTANDARD  LVDS     [get_ports "CLK_125_P"] ;# Bank  28 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_28
set_property PACKAGE_PIN F21      [get_ports "HDMI_TX_LVDS_OUT_N"] ;# Bank  28 VCCO - VCC1V8   - IO_L12N_T1U_N11_GC_28
set_property IOSTANDARD  LVDS     [get_ports "HDMI_TX_LVDS_OUT_N"] ;# Bank  28 VCCO - VCC1V8   - IO_L12N_T1U_N11_GC_28
set_property PACKAGE_PIN G21      [get_ports "HDMI_TX_LVDS_OUT_P"] ;# Bank  28 VCCO - VCC1V8   - IO_L12P_T1U_N10_GC_28
set_property IOSTANDARD  LVDS     [get_ports "HDMI_TX_LVDS_OUT_P"] ;# Bank  28 VCCO - VCC1V8   - IO_L12P_T1U_N10_GC_28
set_property PACKAGE_PIN E22      [get_ports "HDMI_REC_CLOCK_N"] ;# Bank  28 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_28
set_property IOSTANDARD  LVDS     [get_ports "HDMI_REC_CLOCK_N"] ;# Bank  28 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_28
set_property PACKAGE_PIN F22      [get_ports "HDMI_REC_CLOCK_P"] ;# Bank  28 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_28
set_property IOSTANDARD  LVDS     [get_ports "HDMI_REC_CLOCK_P"] ;# Bank  28 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_28
set_property PACKAGE_PIN A11      [get_ports "FMC_LPC_LA23_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L24N_T3U_N11_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA23_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L24N_T3U_N11_68
set_property PACKAGE_PIN B11      [get_ports "FMC_LPC_LA23_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L24P_T3U_N10_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA23_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L24P_T3U_N10_68
set_property PACKAGE_PIN A7       [get_ports "FMC_LPC_LA27_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L23N_T3U_N9_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA27_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L23N_T3U_N9_68
set_property PACKAGE_PIN A8       [get_ports "FMC_LPC_LA27_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L23P_T3U_N8_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA27_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L23P_T3U_N8_68
set_property PACKAGE_PIN A10      [get_ports "FMC_LPC_LA21_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA21_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_68
set_property PACKAGE_PIN B10      [get_ports "FMC_LPC_LA21_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA21_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_68
set_property PACKAGE_PIN A6       [get_ports "FMC_LPC_LA24_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L21N_T3L_N5_AD8N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA24_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L21N_T3L_N5_AD8N_68
set_property PACKAGE_PIN B6       [get_ports "FMC_LPC_LA24_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L21P_T3L_N4_AD8P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA24_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L21P_T3L_N4_AD8P_68
set_property PACKAGE_PIN B8       [get_ports "FMC_LPC_LA26_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L20N_T3L_N3_AD1N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA26_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L20N_T3L_N3_AD1N_68
set_property PACKAGE_PIN B9       [get_ports "FMC_LPC_LA26_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L20P_T3L_N2_AD1P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA26_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L20P_T3L_N2_AD1P_68
set_property PACKAGE_PIN C6       [get_ports "FMC_LPC_LA25_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA25_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_68
set_property PACKAGE_PIN C7       [get_ports "FMC_LPC_LA25_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA25_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_68
set_property PACKAGE_PIN C11      [get_ports "FMC_LPC_LA19_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L18N_T2U_N11_AD2N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA19_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L18N_T2U_N11_AD2N_68
set_property PACKAGE_PIN D12      [get_ports "FMC_LPC_LA19_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L18P_T2U_N10_AD2P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA19_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L18P_T2U_N10_AD2P_68
set_property PACKAGE_PIN E12      [get_ports "FMC_LPC_LA20_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA20_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_68
set_property PACKAGE_PIN F12      [get_ports "FMC_LPC_LA20_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA20_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_68
set_property PACKAGE_PIN D10      [get_ports "FMC_LPC_LA18_CC_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L16N_T2U_N7_QBC_AD3N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA18_CC_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L16N_T2U_N7_QBC_AD3N_68
set_property PACKAGE_PIN D11      [get_ports "FMC_LPC_LA18_CC_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L16P_T2U_N6_QBC_AD3P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA18_CC_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L16P_T2U_N6_QBC_AD3P_68
set_property PACKAGE_PIN H12      [get_ports "FMC_LPC_LA22_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L15N_T2L_N5_AD11N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA22_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L15N_T2L_N5_AD11N_68
set_property PACKAGE_PIN H13      [get_ports "FMC_LPC_LA22_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L15P_T2L_N4_AD11P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA22_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L15P_T2L_N4_AD11P_68
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA17_CC_N[0]}]
set_property PACKAGE_PIN F11 [get_ports {FMC_LPC_LA17_CC_P[0]}]
set_property PACKAGE_PIN E10 [get_ports {FMC_LPC_LA17_CC_N[0]}]
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA17_CC_P[0]}]
set_property PACKAGE_PIN F10      [get_ports "FMC_LPC_CLK1_M2C_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L12N_T1U_N11_GC_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_CLK1_M2C_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L12N_T1U_N11_GC_68
set_property PACKAGE_PIN G10      [get_ports "FMC_LPC_CLK1_M2C_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L12P_T1U_N10_GC_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_CLK1_M2C_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L12P_T1U_N10_GC_68
set_property PACKAGE_PIN D9       [get_ports "FMC_LPC_LA30_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L10N_T1U_N7_QBC_AD4N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA30_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L10N_T1U_N7_QBC_AD4N_68
set_property PACKAGE_PIN E9       [get_ports "FMC_LPC_LA30_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L10P_T1U_N6_QBC_AD4P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA30_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L10P_T1U_N6_QBC_AD4P_68
set_property PACKAGE_PIN E8       [get_ports "FMC_LPC_LA32_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L9N_T1L_N5_AD12N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA32_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L9N_T1L_N5_AD12N_68
set_property PACKAGE_PIN F8       [get_ports "FMC_LPC_LA32_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L9P_T1L_N4_AD12P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA32_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L9P_T1L_N4_AD12P_68
set_property PACKAGE_PIN C8       [get_ports "FMC_LPC_LA33_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA33_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_68
set_property PACKAGE_PIN C9       [get_ports "FMC_LPC_LA33_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA33_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_68
set_property PACKAGE_PIN E7       [get_ports "FMC_LPC_LA31_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L7N_T1L_N1_QBC_AD13N_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA31_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L7N_T1L_N1_QBC_AD13N_68
set_property PACKAGE_PIN F7       [get_ports "FMC_LPC_LA31_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L7P_T1L_N0_QBC_AD13P_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA31_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L7P_T1L_N0_QBC_AD13P_68
set_property PACKAGE_PIN J10      [get_ports "FMC_LPC_LA29_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L2N_T0L_N3_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA29_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L2N_T0L_N3_68
set_property PACKAGE_PIN K10      [get_ports "FMC_LPC_LA29_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L2P_T0L_N2_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA29_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L2P_T0L_N2_68
set_property PACKAGE_PIN L13      [get_ports "FMC_LPC_LA28_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L1N_T0L_N1_DBC_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA28_N"] ;# Bank  68 VCCO - VADJ_FMC - IO_L1N_T0L_N1_DBC_68
set_property PACKAGE_PIN M13      [get_ports "FMC_LPC_LA28_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L1P_T0L_N0_DBC_68
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA28_P"] ;# Bank  68 VCCO - VADJ_FMC - IO_L1P_T0L_N0_DBC_68
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA04_N]
set_property PACKAGE_PIN L17 [get_ports FMC_LPC_LA04_P]
set_property PACKAGE_PIN L16 [get_ports FMC_LPC_LA04_N]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA04_P]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA03_N]
set_property PACKAGE_PIN K19 [get_ports FMC_LPC_LA03_P]
set_property PACKAGE_PIN K18 [get_ports FMC_LPC_LA03_N]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA03_P]
set_property PACKAGE_PIN K15      [get_ports "FMC_LPC_LA10_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA10_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_67
set_property PACKAGE_PIN L15      [get_ports "FMC_LPC_LA10_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA10_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_67
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA05_N]
set_property PACKAGE_PIN K17 [get_ports FMC_LPC_LA05_P]
set_property PACKAGE_PIN J17 [get_ports FMC_LPC_LA05_N]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA05_P]
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA07_N[0]}]
set_property PACKAGE_PIN J16 [get_ports {FMC_LPC_LA07_P[0]}]
set_property PACKAGE_PIN J15 [get_ports {FMC_LPC_LA07_N[0]}]
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA07_P[0]}]
set_property PACKAGE_PIN K20      [get_ports "FMC_LPC_LA02_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA02_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_67
set_property PACKAGE_PIN L20      [get_ports "FMC_LPC_LA02_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA02_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_67
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA09_N[0]}]
set_property PACKAGE_PIN H16 [get_ports {FMC_LPC_LA09_P[0]}]
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA09_P[0]}]
set_property PACKAGE_PIN F18      [get_ports "FMC_LPC_LA12_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA12_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_67
set_property PACKAGE_PIN G18      [get_ports "FMC_LPC_LA12_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA12_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_67
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA01_CC_N]
set_property PACKAGE_PIN H18 [get_ports FMC_LPC_LA01_CC_P]
set_property PACKAGE_PIN H17 [get_ports FMC_LPC_LA01_CC_N]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA01_CC_P]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA06_N]
set_property PACKAGE_PIN H19 [get_ports FMC_LPC_LA06_P]
set_property PACKAGE_PIN G19 [get_ports FMC_LPC_LA06_N]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA06_P]
set_property PACKAGE_PIN F15      [get_ports "FMC_LPC_LA13_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L14N_T2L_N3_GC_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA13_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L14N_T2L_N3_GC_67
set_property PACKAGE_PIN G15      [get_ports "FMC_LPC_LA13_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L14P_T2L_N2_GC_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA13_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L14P_T2L_N2_GC_67
set_property PACKAGE_PIN F16      [get_ports "FMC_LPC_LA00_CC_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L13N_T2L_N1_GC_QBC_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA00_CC_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L13N_T2L_N1_GC_QBC_67
set_property PACKAGE_PIN F17      [get_ports "FMC_LPC_LA00_CC_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA00_CC_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L13P_T2L_N0_GC_QBC_67
set_property PACKAGE_PIN E14      [get_ports "FMC_LPC_CLK0_M2C_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L12N_T1U_N11_GC_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_CLK0_M2C_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN E15      [get_ports "FMC_LPC_CLK0_M2C_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_CLK0_M2C_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA08_N[0]}]
set_property PACKAGE_PIN E18 [get_ports {FMC_LPC_LA08_P[0]}]
set_property PACKAGE_PIN E17 [get_ports {FMC_LPC_LA08_N[0]}]
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA08_P[0]}]
set_property PACKAGE_PIN C17      [get_ports "FMC_LPC_LA16_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA16_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_67
set_property PACKAGE_PIN D17      [get_ports "FMC_LPC_LA16_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA16_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_67
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA15_N[0]}]
set_property PACKAGE_PIN D16 [get_ports {FMC_LPC_LA15_P[0]}]
set_property PACKAGE_PIN C16 [get_ports {FMC_LPC_LA15_N[0]}]
set_property IOSTANDARD LVDS [get_ports {FMC_LPC_LA15_P[0]}]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA14_N]
set_property PACKAGE_PIN C13 [get_ports FMC_LPC_LA14_P]
set_property IOSTANDARD LVDS [get_ports FMC_LPC_LA14_P]
set_property PACKAGE_PIN A12      [get_ports "FMC_LPC_LA11_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L5N_T0U_N9_AD14N_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA11_N"] ;# Bank  67 VCCO - VADJ_FMC - IO_L5N_T0U_N9_AD14N_67
set_property PACKAGE_PIN A13      [get_ports "FMC_LPC_LA11_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L5P_T0U_N8_AD14P_67
set_property IOSTANDARD  LVDS     [get_ports "FMC_LPC_LA11_P"] ;# Bank  67 VCCO - VADJ_FMC - IO_L5P_T0U_N8_AD14P_67
set_property PACKAGE_PIN AC13 [get_ports {DDR4_SODIMM_dq[32]}]
set_property PACKAGE_PIN AB13 [get_ports {DDR4_SODIMM_dq[33]}]
set_property PACKAGE_PIN AF12 [get_ports {DDR4_SODIMM_dq[34]}]
set_property PACKAGE_PIN AE12 [get_ports {DDR4_SODIMM_dq[35]}]
set_property PACKAGE_PIN AC12 [get_ports {DDR4_SODIMM_dqs_t[4]}]
set_property PACKAGE_PIN AD12 [get_ports {DDR4_SODIMM_dqs_c[4]}]
set_property PACKAGE_PIN AF13 [get_ports {DDR4_SODIMM_dq[36]}]
set_property PACKAGE_PIN AE13 [get_ports {DDR4_SODIMM_dq[37]}]
set_property PACKAGE_PIN AE14 [get_ports {DDR4_SODIMM_dq[38]}]
set_property PACKAGE_PIN AD14 [get_ports {DDR4_SODIMM_dq[39]}]
set_property PACKAGE_PIN AF11 [get_ports {DDR4_SODIMM_dm_n[4]}]
set_property PACKAGE_PIN AG8 [get_ports {DDR4_SODIMM_dq[40]}]
set_property PACKAGE_PIN AF8 [get_ports {DDR4_SODIMM_dq[41]}]
set_property PACKAGE_PIN AG10 [get_ports {DDR4_SODIMM_dq[42]}]
set_property PACKAGE_PIN AG11 [get_ports {DDR4_SODIMM_dq[43]}]
set_property PACKAGE_PIN AG9 [get_ports {DDR4_SODIMM_dqs_t[5]}]
set_property PACKAGE_PIN AH9 [get_ports {DDR4_SODIMM_dqs_c[5]}]
set_property PACKAGE_PIN AH13 [get_ports {DDR4_SODIMM_dq[44]}]
set_property PACKAGE_PIN AG13 [get_ports {DDR4_SODIMM_dq[45]}]
set_property PACKAGE_PIN AJ11 [get_ports {DDR4_SODIMM_dq[46]}]
set_property PACKAGE_PIN AH11 [get_ports {DDR4_SODIMM_dq[47]}]
set_property PACKAGE_PIN AH12 [get_ports {DDR4_SODIMM_dm_n[5]}]
set_property PACKAGE_PIN AK9 [get_ports {DDR4_SODIMM_dq[48]}]
set_property PACKAGE_PIN AJ9 [get_ports {DDR4_SODIMM_dq[49]}]
set_property PACKAGE_PIN AK10 [get_ports {DDR4_SODIMM_dq[50]}]
set_property PACKAGE_PIN AJ10 [get_ports {DDR4_SODIMM_dq[51]}]
set_property PACKAGE_PIN AK8 [get_ports {DDR4_SODIMM_dqs_t[6]}]
set_property PACKAGE_PIN AL8 [get_ports {DDR4_SODIMM_dqs_c[6]}]
set_property PACKAGE_PIN AL12 [get_ports {DDR4_SODIMM_dq[52]}]
set_property PACKAGE_PIN AK12 [get_ports {DDR4_SODIMM_dq[53]}]
set_property PACKAGE_PIN AL10 [get_ports {DDR4_SODIMM_dq[54]}]
set_property PACKAGE_PIN AL11 [get_ports {DDR4_SODIMM_dq[55]}]
set_property PACKAGE_PIN AK13 [get_ports {DDR4_SODIMM_dm_n[6]}]
set_property PACKAGE_PIN AM8 [get_ports {DDR4_SODIMM_dq[56]}]
set_property PACKAGE_PIN AM9 [get_ports {DDR4_SODIMM_dq[57]}]
set_property PACKAGE_PIN AM10 [get_ports {DDR4_SODIMM_dq[58]}]
set_property PACKAGE_PIN AM11 [get_ports {DDR4_SODIMM_dq[59]}]
set_property PACKAGE_PIN AN9 [get_ports {DDR4_SODIMM_dqs_t[7]}]
set_property PACKAGE_PIN AN8 [get_ports {DDR4_SODIMM_dqs_c[7]}]
set_property PACKAGE_PIN AP11 [get_ports {DDR4_SODIMM_dq[60]}]
set_property PACKAGE_PIN AN11 [get_ports {DDR4_SODIMM_dq[61]}]
set_property PACKAGE_PIN AP9 [get_ports {DDR4_SODIMM_dq[62]}]
set_property PACKAGE_PIN AP10 [get_ports {DDR4_SODIMM_dq[63]}]
set_property PACKAGE_PIN AN12 [get_ports {DDR4_SODIMM_dm_n[7]}]
set_property PACKAGE_PIN AA20 [get_ports {DDR4_SODIMM_dq[8]}]
set_property PACKAGE_PIN AA19 [get_ports {DDR4_SODIMM_dq[9]}]
set_property PACKAGE_PIN AD19 [get_ports {DDR4_SODIMM_dq[10]}]
set_property PACKAGE_PIN AC18 [get_ports {DDR4_SODIMM_dq[11]}]
set_property PACKAGE_PIN AA18 [get_ports {DDR4_SODIMM_dqs_t[1]}]
set_property PACKAGE_PIN AB18 [get_ports {DDR4_SODIMM_dqs_c[1]}]
set_property PACKAGE_PIN AE20 [get_ports {DDR4_SODIMM_dq[12]}]
set_property PACKAGE_PIN AD20 [get_ports {DDR4_SODIMM_dq[13]}]
set_property PACKAGE_PIN AC19 [get_ports {DDR4_SODIMM_dq[14]}]
set_property PACKAGE_PIN AB19 [get_ports {DDR4_SODIMM_dq[15]}]
set_property PACKAGE_PIN AE18 [get_ports {DDR4_SODIMM_dm_n[1]}]
set_property PACKAGE_PIN AE24 [get_ports {DDR4_SODIMM_dq[0]}]
set_property PACKAGE_PIN AE23 [get_ports {DDR4_SODIMM_dq[1]}]
set_property PACKAGE_PIN AF22 [get_ports {DDR4_SODIMM_dq[2]}]
set_property PACKAGE_PIN AF21 [get_ports {DDR4_SODIMM_dq[3]}]
set_property PACKAGE_PIN AF23 [get_ports {DDR4_SODIMM_dqs_t[0]}]
set_property PACKAGE_PIN AG23 [get_ports {DDR4_SODIMM_dqs_c[0]}]
set_property PACKAGE_PIN AG20 [get_ports {DDR4_SODIMM_dq[4]}]
set_property PACKAGE_PIN AG19 [get_ports {DDR4_SODIMM_dq[5]}]
set_property PACKAGE_PIN AH21 [get_ports {DDR4_SODIMM_dq[6]}]
set_property PACKAGE_PIN AG21 [get_ports {DDR4_SODIMM_dq[7]}]
set_property PACKAGE_PIN AH22 [get_ports {DDR4_SODIMM_dm_n[0]}]
set_property PACKAGE_PIN AJ22 [get_ports {DDR4_SODIMM_dq[16]}]
set_property PACKAGE_PIN AJ21 [get_ports {DDR4_SODIMM_dq[17]}]
set_property PACKAGE_PIN AK20 [get_ports {DDR4_SODIMM_dq[18]}]
set_property PACKAGE_PIN AJ20 [get_ports {DDR4_SODIMM_dq[19]}]
set_property PACKAGE_PIN AK22 [get_ports {DDR4_SODIMM_dqs_t[2]}]
set_property PACKAGE_PIN AK23 [get_ports {DDR4_SODIMM_dqs_c[2]}]
set_property PACKAGE_PIN AK19 [get_ports {DDR4_SODIMM_dq[20]}]
set_property PACKAGE_PIN AJ19 [get_ports {DDR4_SODIMM_dq[21]}]
set_property PACKAGE_PIN AL23 [get_ports {DDR4_SODIMM_dq[22]}]
set_property PACKAGE_PIN AL22 [get_ports {DDR4_SODIMM_dq[23]}]
set_property PACKAGE_PIN AL20 [get_ports {DDR4_SODIMM_dm_n[2]}]
set_property PACKAGE_PIN AN23 [get_ports {DDR4_SODIMM_dq[24]}]
set_property PACKAGE_PIN AM23 [get_ports {DDR4_SODIMM_dq[25]}]
set_property PACKAGE_PIN AP23 [get_ports {DDR4_SODIMM_dq[26]}]
set_property PACKAGE_PIN AN22 [get_ports {DDR4_SODIMM_dq[27]}]
set_property PACKAGE_PIN AM21 [get_ports {DDR4_SODIMM_dqs_t[3]}]
set_property PACKAGE_PIN AN21 [get_ports {DDR4_SODIMM_dqs_c[3]}]
set_property PACKAGE_PIN AP22 [get_ports {DDR4_SODIMM_dq[28]}]
set_property PACKAGE_PIN AP21 [get_ports {DDR4_SODIMM_dq[29]}]
set_property PACKAGE_PIN AN19 [get_ports {DDR4_SODIMM_dq[30]}]
set_property PACKAGE_PIN AM19 [get_ports {DDR4_SODIMM_dq[31]}]
set_property PACKAGE_PIN AP19 [get_ports {DDR4_SODIMM_dm_n[3]}]
set_property PACKAGE_PIN AD16     [get_ports "DDR4_SODIMM_PARITY"] ;# Bank  64 VCCO - VCC1V2   - IO_L24N_T3U_N11_64
set_property IOSTANDARD  POD12    [get_ports "DDR4_SODIMM_PARITY"] ;# Bank  64 VCCO - VCC1V2   - IO_L24N_T3U_N11_64
set_property PACKAGE_PIN AD17 [get_ports {DDR4_SODIMM_cke[0]}]
set_property PACKAGE_PIN AB14 [get_ports DDR4_SODIMM_reset_n]
set_property IOSTANDARD LVCMOS12 [get_ports DDR4_SODIMM_reset_n]
set_property PACKAGE_PIN AA14 [get_ports {DDR4_SODIMM_adr[15]}]
set_property PACKAGE_PIN AA15 [get_ports {DDR4_SODIMM_cs_n[0]}]
set_property PACKAGE_PIN AA16 [get_ports {DDR4_SODIMM_adr[14]}]
set_property PACKAGE_PIN AB15     [get_ports "DDR4_SODIMM_ALERT_B"] ;# Bank  64 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_64
set_property IOSTANDARD  POD12    [get_ports "DDR4_SODIMM_ALERT_B"] ;# Bank  64 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_64
set_property PACKAGE_PIN AB16 [get_ports {DDR4_SODIMM_bg[1]}]
set_property PACKAGE_PIN AC16 [get_ports {DDR4_SODIMM_bg[0]}]
set_property PACKAGE_PIN AC17 [get_ports DDR4_SODIMM_act_n]
set_property PACKAGE_PIN AE15 [get_ports {DDR4_SODIMM_odt[0]}]
set_property PACKAGE_PIN AD15 [get_ports {DDR4_SODIMM_adr[16]}]
set_property PACKAGE_PIN AH16 [get_ports {DDR4_SODIMM_adr[0]}]
set_property PACKAGE_PIN AG14 [get_ports {DDR4_SODIMM_adr[1]}]
set_property PACKAGE_PIN AG15 [get_ports {DDR4_SODIMM_adr[2]}]
set_property PACKAGE_PIN AF15 [get_ports {DDR4_SODIMM_adr[3]}]
set_property PACKAGE_PIN AF16 [get_ports {DDR4_SODIMM_adr[4]}]
set_property PACKAGE_PIN AJ14 [get_ports {DDR4_SODIMM_adr[5]}]
set_property PACKAGE_PIN AH14 [get_ports {DDR4_SODIMM_adr[6]}]
set_property PACKAGE_PIN AF17 [get_ports {DDR4_SODIMM_adr[7]}]
set_property PACKAGE_PIN AF18 [get_ports {DDR4_SODIMM_ck_t[0]}]
set_property PACKAGE_PIN AG18 [get_ports {DDR4_SODIMM_ck_c[0]}]
set_property PACKAGE_PIN AJ15     [get_ports "DDR4_SODIMM_ck_c[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_64
set_property IOSTANDARD  DIFF_POD12 [get_ports "DDR4_SODIMM_ck_c[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_64
set_property PACKAGE_PIN AJ16     [get_ports "DDR4_SODIMM_ck_t[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_64
set_property IOSTANDARD  DIFF_POD12 [get_ports "DDR4_SODIMM_ck_t[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_64
set_property PACKAGE_PIN AK17 [get_ports {DDR4_SODIMM_adr[8]}]
set_property PACKAGE_PIN AJ17 [get_ports {DDR4_SODIMM_adr[9]}]
set_property PACKAGE_PIN AK14 [get_ports {DDR4_SODIMM_adr[10]}]
set_property PACKAGE_PIN AK15 [get_ports {DDR4_SODIMM_adr[11]}]
set_property PACKAGE_PIN AL18 [get_ports {DDR4_SODIMM_adr[12]}]
set_property PACKAGE_PIN AK18 [get_ports {DDR4_SODIMM_adr[13]}]
set_property PACKAGE_PIN AL15 [get_ports {DDR4_SODIMM_ba[0]}]
set_property PACKAGE_PIN AL16 [get_ports {DDR4_SODIMM_ba[1]}]
set_property PACKAGE_PIN AM15     [get_ports "DDR4_SODIMM_cke[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L7N_T1L_N1_QBC_AD13N_64
set_property IOSTANDARD  SSTL12   [get_ports "DDR4_SODIMM_cke[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L7N_T1L_N1_QBC_AD13N_64
set_property PACKAGE_PIN AM16     [get_ports "DDR4_SODIMM_odt[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L7P_T1L_N0_QBC_AD13P_64
set_property IOSTANDARD  SSTL12   [get_ports "DDR4_SODIMM_odt[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_L7P_T1L_N0_QBC_AD13P_64
set_property PACKAGE_PIN AL17     [get_ports "DDR4_SODIMM_cs_n[1]"] ;# Bank  64 VCCO - VCC1V2   - IO_T1U_N12_64
set_property PACKAGE_PIN AN16     [get_ports "DDR4_SODIMM_cs_n[3]"] ;# Bank  64 VCCO - VCC1V2   - IO_L6N_T0U_N11_AD6N_64
set_property PACKAGE_PIN AN17     [get_ports "DDR4_SODIMM_cs_n[2]"] ;# Bank  64 VCCO - VCC1V2   - IO_L6P_T0U_N10_AD6P_64

set_property PACKAGE_PIN E5       [get_ports "HDMI_RX_PWR_DET"] ;# Bank  88 VCCO - VCC3V3   - IO_L12N_AD8N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_RX_PWR_DET"] ;# Bank  88 VCCO - VCC3V3   - IO_L12N_AD8N_88
set_property PACKAGE_PIN F6       [get_ports "HDMI_RX_HPD"] ;# Bank  88 VCCO - VCC3V3   - IO_L12P_AD8P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_RX_HPD"] ;# Bank  88 VCCO - VCC3V3   - IO_L12P_AD8P_88
set_property PACKAGE_PIN D5 [get_ports GPIO_LED_0_LS]
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_LED_0_LS]
set_property PACKAGE_PIN D6 [get_ports GPIO_LED_1_LS]
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_LED_1_LS]
set_property PACKAGE_PIN A5       [get_ports "GPIO_LED_2_LS"] ;# Bank  88 VCCO - VCC3V3   - IO_L10N_AD10N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_LED_2_LS"] ;# Bank  88 VCCO - VCC3V3   - IO_L10N_AD10N_88
set_property PACKAGE_PIN B5       [get_ports "GPIO_LED_3_LS"] ;# Bank  88 VCCO - VCC3V3   - IO_L10P_AD10P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_LED_3_LS"] ;# Bank  88 VCCO - VCC3V3   - IO_L10P_AD10P_88
set_property PACKAGE_PIN F4       [get_ports "GPIO_DIP_SW3"] ;# Bank  88 VCCO - VCC3V3   - IO_L9N_AD11N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_DIP_SW3"] ;# Bank  88 VCCO - VCC3V3   - IO_L9N_AD11N_88
set_property PACKAGE_PIN F5       [get_ports "GPIO_DIP_SW2"] ;# Bank  88 VCCO - VCC3V3   - IO_L9P_AD11P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_DIP_SW2"] ;# Bank  88 VCCO - VCC3V3   - IO_L9P_AD11P_88
set_property PACKAGE_PIN D4       [get_ports "GPIO_DIP_SW1"] ;# Bank  88 VCCO - VCC3V3   - IO_L8N_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_DIP_SW1"] ;# Bank  88 VCCO - VCC3V3   - IO_L8N_HDGC_88
set_property PACKAGE_PIN E4       [get_ports "GPIO_DIP_SW0"] ;# Bank  88 VCCO - VCC3V3   - IO_L8P_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_DIP_SW0"] ;# Bank  88 VCCO - VCC3V3   - IO_L8P_HDGC_88
set_property PACKAGE_PIN B4       [get_ports "GPIO_PB_SW0"] ;# Bank  88 VCCO - VCC3V3   - IO_L7N_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_PB_SW0"] ;# Bank  88 VCCO - VCC3V3   - IO_L7N_HDGC_88
set_property PACKAGE_PIN C4       [get_ports "GPIO_PB_SW1"] ;# Bank  88 VCCO - VCC3V3   - IO_L7P_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_PB_SW1"] ;# Bank  88 VCCO - VCC3V3   - IO_L7P_HDGC_88
set_property PACKAGE_PIN B3       [get_ports "GPIO_PB_SW2"] ;# Bank  88 VCCO - VCC3V3   - IO_L6N_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_PB_SW2"] ;# Bank  88 VCCO - VCC3V3   - IO_L6N_HDGC_88
set_property PACKAGE_PIN C3       [get_ports "GPIO_PB_SW3"] ;# Bank  88 VCCO - VCC3V3   - IO_L6P_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "GPIO_PB_SW3"] ;# Bank  88 VCCO - VCC3V3   - IO_L6P_HDGC_88
set_property PACKAGE_PIN C2       [get_ports "34N8749"] ;# Bank  88 VCCO - VCC3V3   - IO_L5N_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_RX_LS_OE"] ;# Bank  88 VCCO - VCC3V3   - IO_L5N_HDGC_88
set_property PACKAGE_PIN D2       [get_ports "HDMI_RX_SNK_SCL"] ;# Bank  88 VCCO - VCC3V3   - IO_L5P_HDGC_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_RX_SNK_SCL"] ;# Bank  88 VCCO - VCC3V3   - IO_L5P_HDGC_88
set_property PACKAGE_PIN E2       [get_ports "HDMI_RX_SNK_SDA"] ;# Bank  88 VCCO - VCC3V3   - IO_L4N_AD12N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_RX_SNK_SDA"] ;# Bank  88 VCCO - VCC3V3   - IO_L4N_AD12N_88
set_property PACKAGE_PIN E3       [get_ports "HDMI_TX_HPD"] ;# Bank  88 VCCO - VCC3V3   - IO_L4P_AD12P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_HPD"] ;# Bank  88 VCCO - VCC3V3   - IO_L4P_AD12P_88
set_property PACKAGE_PIN A2       [get_ports "HDMI_TX_EN"] ;# Bank  88 VCCO - VCC3V3   - IO_L3N_AD13N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_EN"] ;# Bank  88 VCCO - VCC3V3   - IO_L3N_AD13N_88
set_property PACKAGE_PIN A3       [get_ports "HDMI_TX_CEC"] ;# Bank  88 VCCO - VCC3V3   - IO_L3P_AD13P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_CEC"] ;# Bank  88 VCCO - VCC3V3   - IO_L3P_AD13P_88
set_property PACKAGE_PIN B1       [get_ports "HDMI_TX_SRC_SCL"] ;# Bank  88 VCCO - VCC3V3   - IO_L2N_AD14N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_SRC_SCL"] ;# Bank  88 VCCO - VCC3V3   - IO_L2N_AD14N_88
set_property PACKAGE_PIN C1       [get_ports "HDMI_TX_SRC_SDA"] ;# Bank  88 VCCO - VCC3V3   - IO_L2P_AD14P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_SRC_SDA"] ;# Bank  88 VCCO - VCC3V3   - IO_L2P_AD14P_88
set_property PACKAGE_PIN D1       [get_ports "HDMI_CTL_SCL"] ;# Bank  88 VCCO - VCC3V3   - IO_L1N_AD15N_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_CTL_SCL"] ;# Bank  88 VCCO - VCC3V3   - IO_L1N_AD15N_88
set_property PACKAGE_PIN E1       [get_ports "HDMI_CTL_SDA"] ;# Bank  88 VCCO - VCC3V3   - IO_L1P_AD15P_88
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_CTL_SDA"] ;# Bank  88 VCCO - VCC3V3   - IO_L1P_AD15P_88
set_property PACKAGE_PIN G8       [get_ports "PMOD0_0"] ;# Bank  87 VCCO - VCC3V3   - IO_L12N_AD0N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_0"] ;# Bank  87 VCCO - VCC3V3   - IO_L12N_AD0N_87
set_property PACKAGE_PIN H8       [get_ports "PMOD0_1"] ;# Bank  87 VCCO - VCC3V3   - IO_L12P_AD0P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_1"] ;# Bank  87 VCCO - VCC3V3   - IO_L12P_AD0P_87
set_property PACKAGE_PIN G7       [get_ports "PMOD0_2"] ;# Bank  87 VCCO - VCC3V3   - IO_L11N_AD1N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_2"] ;# Bank  87 VCCO - VCC3V3   - IO_L11N_AD1N_87
set_property PACKAGE_PIN H7       [get_ports "PMOD0_3"] ;# Bank  87 VCCO - VCC3V3   - IO_L11P_AD1P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_3"] ;# Bank  87 VCCO - VCC3V3   - IO_L11P_AD1P_87
set_property PACKAGE_PIN G6       [get_ports "PMOD0_4"] ;# Bank  87 VCCO - VCC3V3   - IO_L10N_AD2N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_4"] ;# Bank  87 VCCO - VCC3V3   - IO_L10N_AD2N_87
set_property PACKAGE_PIN H6       [get_ports "PMOD0_5"] ;# Bank  87 VCCO - VCC3V3   - IO_L10P_AD2P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_5"] ;# Bank  87 VCCO - VCC3V3   - IO_L10P_AD2P_87
set_property PACKAGE_PIN J6       [get_ports "PMOD0_6"] ;# Bank  87 VCCO - VCC3V3   - IO_L9N_AD3N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_6"] ;# Bank  87 VCCO - VCC3V3   - IO_L9N_AD3N_87
set_property PACKAGE_PIN J7       [get_ports "PMOD0_7"] ;# Bank  87 VCCO - VCC3V3   - IO_L9P_AD3P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD0_7"] ;# Bank  87 VCCO - VCC3V3   - IO_L9P_AD3P_87
set_property PACKAGE_PIN J9       [get_ports "PMOD1_0"] ;# Bank  87 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_0"] ;# Bank  87 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_87
set_property PACKAGE_PIN K9       [get_ports "PMOD1_1"] ;# Bank  87 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_1"] ;# Bank  87 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_87
set_property PACKAGE_PIN K8       [get_ports "PMOD1_2"] ;# Bank  87 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_2"] ;# Bank  87 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_87
set_property PACKAGE_PIN L8       [get_ports "PMOD1_3"] ;# Bank  87 VCCO - VCC3V3   - IO_L7P_HDGC_AD5P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_3"] ;# Bank  87 VCCO - VCC3V3   - IO_L7P_HDGC_AD5P_87
set_property PACKAGE_PIN L10      [get_ports "PMOD1_4"] ;# Bank  87 VCCO - VCC3V3   - IO_L6N_HDGC_AD6N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_4"] ;# Bank  87 VCCO - VCC3V3   - IO_L6N_HDGC_AD6N_87
set_property PACKAGE_PIN M10      [get_ports "PMOD1_5"] ;# Bank  87 VCCO - VCC3V3   - IO_L6P_HDGC_AD6P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_5"] ;# Bank  87 VCCO - VCC3V3   - IO_L6P_HDGC_AD6P_87
set_property PACKAGE_PIN M8       [get_ports "PMOD1_6"] ;# Bank  87 VCCO - VCC3V3   - IO_L5N_HDGC_AD7N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_6"] ;# Bank  87 VCCO - VCC3V3   - IO_L5N_HDGC_AD7N_87
set_property PACKAGE_PIN M9       [get_ports "PMOD1_7"] ;# Bank  87 VCCO - VCC3V3   - IO_L5P_HDGC_AD7P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PMOD1_7"] ;# Bank  87 VCCO - VCC3V3   - IO_L5P_HDGC_AD7P_87
set_property PACKAGE_PIN M11      [get_ports "CPU_RESET"] ;# Bank  87 VCCO - VCC3V3   - IO_L4N_AD8N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "CPU_RESET"] ;# Bank  87 VCCO - VCC3V3   - IO_L4N_AD8N_87
set_property PACKAGE_PIN N11      [get_ports "HDMI_8T49N241_LOL"] ;# Bank  87 VCCO - VCC3V3   - IO_L4P_AD8P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_8T49N241_LOL"] ;# Bank  87 VCCO - VCC3V3   - IO_L4P_AD8P_87
set_property PACKAGE_PIN M12      [get_ports "HDMI_8T49N241_RST"] ;# Bank  87 VCCO - VCC3V3   - IO_L3N_AD9N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_8T49N241_RST"] ;# Bank  87 VCCO - VCC3V3   - IO_L3N_AD9N_87
set_property PACKAGE_PIN N13      [get_ports "HDMI_TX_LS_OE"] ;# Bank  87 VCCO - VCC3V3   - IO_L3P_AD9P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_LS_OE"] ;# Bank  87 VCCO - VCC3V3   - IO_L3P_AD9P_87
set_property PACKAGE_PIN N8       [get_ports "HDMI_TX_CT_HPD"] ;# Bank  87 VCCO - VCC3V3   - IO_L2N_AD10N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "HDMI_TX_CT_HPD"] ;# Bank  87 VCCO - VCC3V3   - IO_L2N_AD10N_87
set_property PACKAGE_PIN N9       [get_ports "34N8735"] ;# Bank  87 VCCO - VCC3V3   - IO_L2P_AD10P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "34N8735"] ;# Bank  87 VCCO - VCC3V3   - IO_L2P_AD10P_87
set_property PACKAGE_PIN N12      [get_ports "PL_I2C1_SCL_LS"] ;# Bank  87 VCCO - VCC3V3   - IO_L1N_AD11N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PL_I2C1_SCL_LS"] ;# Bank  87 VCCO - VCC3V3   - IO_L1N_AD11N_87
set_property PACKAGE_PIN P12      [get_ports "PL_I2C1_SDA_LS"] ;# Bank  87 VCCO - VCC3V3   - IO_L1P_AD11P_87
set_property IOSTANDARD  LVCMOS33 [get_ports "PL_I2C1_SDA_LS"] ;# Bank  87 VCCO - VCC3V3   - IO_L1P_AD11P_87
set_property PACKAGE_PIN AP3      [get_ports "GND"] ;# Bank 223 - MGTHRXN0_223
set_property PACKAGE_PIN AN1      [get_ports "GND"] ;# Bank 223 - MGTHRXN1_223
set_property PACKAGE_PIN AL1      [get_ports "GND"] ;# Bank 223 - MGTHRXN2_223
set_property PACKAGE_PIN AK3      [get_ports "GND"] ;# Bank 223 - MGTHRXN3_223
set_property PACKAGE_PIN AP4      [get_ports "GND"] ;# Bank 223 - MGTHRXP0_223
set_property PACKAGE_PIN AN2      [get_ports "GND"] ;# Bank 223 - MGTHRXP1_223
set_property PACKAGE_PIN AL2      [get_ports "GND"] ;# Bank 223 - MGTHRXP2_223
set_property PACKAGE_PIN AK4      [get_ports "GND"] ;# Bank 223 - MGTHRXP3_223
set_property PACKAGE_PIN AN5      [get_ports "9N7450"] ;# Bank 223 - MGTHTXN0_223
set_property PACKAGE_PIN AM3      [get_ports "9N7448"] ;# Bank 223 - MGTHTXN1_223
set_property PACKAGE_PIN AL5      [get_ports "9N7446"] ;# Bank 223 - MGTHTXN2_223
set_property PACKAGE_PIN AJ5      [get_ports "9N7444"] ;# Bank 223 - MGTHTXN3_223
set_property PACKAGE_PIN AN6      [get_ports "9N7449"] ;# Bank 223 - MGTHTXP0_223
set_property PACKAGE_PIN AM4      [get_ports "9N7447"] ;# Bank 223 - MGTHTXP1_223
set_property PACKAGE_PIN AL6      [get_ports "9N7445"] ;# Bank 223 - MGTHTXP2_223
set_property PACKAGE_PIN AJ6      [get_ports "9N7443"] ;# Bank 223 - MGTHTXP3_223
set_property PACKAGE_PIN AD7      [get_ports "9N7442"] ;# Bank 223 - MGTREFCLK0N_223
set_property PACKAGE_PIN AD8      [get_ports "9N7441"] ;# Bank 223 - MGTREFCLK0P_223
set_property PACKAGE_PIN AC9      [get_ports "9N7455"] ;# Bank 223 - MGTREFCLK1N_223
set_property PACKAGE_PIN AC10     [get_ports "9N7454"] ;# Bank 223 - MGTREFCLK1P_223
set_property PACKAGE_PIN AJ1      [get_ports "GND"] ;# Bank 224 - MGTHRXN0_224
set_property PACKAGE_PIN AG1      [get_ports "GND"] ;# Bank 224 - MGTHRXN1_224
set_property PACKAGE_PIN AF3      [get_ports "GND"] ;# Bank 224 - MGTHRXN2_224
set_property PACKAGE_PIN AE1      [get_ports "GND"] ;# Bank 224 - MGTHRXN3_224
set_property PACKAGE_PIN AJ2      [get_ports "GND"] ;# Bank 224 - MGTHRXP0_224
set_property PACKAGE_PIN AG2      [get_ports "GND"] ;# Bank 224 - MGTHRXP1_224
set_property PACKAGE_PIN AF4      [get_ports "GND"] ;# Bank 224 - MGTHRXP2_224
set_property PACKAGE_PIN AE2      [get_ports "GND"] ;# Bank 224 - MGTHRXP3_224
set_property PACKAGE_PIN AH3      [get_ports "9N7412"] ;# Bank 224 - MGTHTXN0_224
set_property PACKAGE_PIN AG5      [get_ports "9N7408"] ;# Bank 224 - MGTHTXN1_224
set_property PACKAGE_PIN AE5      [get_ports "9N7404"] ;# Bank 224 - MGTHTXN2_224
set_property PACKAGE_PIN AD3      [get_ports "9N7400"] ;# Bank 224 - MGTHTXN3_224
set_property PACKAGE_PIN AH4      [get_ports "9N7411"] ;# Bank 224 - MGTHTXP0_224
set_property PACKAGE_PIN AG6      [get_ports "9N7407"] ;# Bank 224 - MGTHTXP1_224
set_property PACKAGE_PIN AE6      [get_ports "9N7403"] ;# Bank 224 - MGTHTXP2_224
set_property PACKAGE_PIN AD4      [get_ports "9N7399"] ;# Bank 224 - MGTHTXP3_224
set_property PACKAGE_PIN AB7      [get_ports "9N7396"] ;# Bank 224 - MGTREFCLK0N_224
set_property PACKAGE_PIN AB8      [get_ports "9N7395"] ;# Bank 224 - MGTREFCLK0P_224
set_property PACKAGE_PIN AA9      [get_ports "9N7386"] ;# Bank 224 - MGTREFCLK1N_224
set_property PACKAGE_PIN AA10     [get_ports "9N7384"] ;# Bank 224 - MGTREFCLK1P_224
set_property PACKAGE_PIN AD10     [get_ports "MGTRREF_224"] ;# Bank 224 - MGTRREF_R
set_property PACKAGE_PIN AC1      [get_ports "GND"] ;# Bank 225 - MGTHRXN0_225
set_property PACKAGE_PIN AB3      [get_ports "GND"] ;# Bank 225 - MGTHRXN1_225
set_property PACKAGE_PIN AA1      [get_ports "GND"] ;# Bank 225 - MGTHRXN2_225
set_property PACKAGE_PIN W1       [get_ports "GND"] ;# Bank 225 - MGTHRXN3_225
set_property PACKAGE_PIN AC2      [get_ports "GND"] ;# Bank 225 - MGTHRXP0_225
set_property PACKAGE_PIN AB4      [get_ports "GND"] ;# Bank 225 - MGTHRXP1_225
set_property PACKAGE_PIN AA2      [get_ports "GND"] ;# Bank 225 - MGTHRXP2_225
set_property PACKAGE_PIN W2       [get_ports "GND"] ;# Bank 225 - MGTHRXP3_225
set_property PACKAGE_PIN AC5      [get_ports "38N7665"] ;# Bank 225 - MGTHTXN0_225
set_property PACKAGE_PIN AA5      [get_ports "38N7659"] ;# Bank 225 - MGTHTXN1_225
set_property PACKAGE_PIN Y3       [get_ports "38N7653"] ;# Bank 225 - MGTHTXN2_225
set_property PACKAGE_PIN W5       [get_ports "38N7647"] ;# Bank 225 - MGTHTXN3_225
set_property PACKAGE_PIN AC6      [get_ports "38N7663"] ;# Bank 225 - MGTHTXP0_225
set_property PACKAGE_PIN AA6      [get_ports "38N7657"] ;# Bank 225 - MGTHTXP1_225
set_property PACKAGE_PIN Y4       [get_ports "38N7651"] ;# Bank 225 - MGTHTXP2_225
set_property PACKAGE_PIN W6       [get_ports "38N7645"] ;# Bank 225 - MGTHTXP3_225
set_property PACKAGE_PIN Y7       [get_ports "38N7641"] ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN Y8       [get_ports "38N7639"] ;# Bank 225 - MGTREFCLK0P_225
set_property PACKAGE_PIN W9       [get_ports "38N7635"] ;# Bank 225 - MGTREFCLK1N_225
set_property PACKAGE_PIN W10      [get_ports "38N7633"] ;# Bank 225 - MGTREFCLK1P_225
set_property PACKAGE_PIN V3       [get_ports "GND"] ;# Bank 226 - MGTHRXN0_226
set_property PACKAGE_PIN U1       [get_ports "GND"] ;# Bank 226 - MGTHRXN1_226
set_property PACKAGE_PIN R1       [get_ports "GND"] ;# Bank 226 - MGTHRXN2_226
set_property PACKAGE_PIN P3       [get_ports "FMC_LPC_DP0_M2C_N"] ;# Bank 226 - MGTHRXN3_226
set_property PACKAGE_PIN V4       [get_ports "GND"] ;# Bank 226 - MGTHRXP0_226
set_property PACKAGE_PIN U2       [get_ports "GND"] ;# Bank 226 - MGTHRXP1_226
set_property PACKAGE_PIN R2       [get_ports "GND"] ;# Bank 226 - MGTHRXP2_226
set_property PACKAGE_PIN P4       [get_ports "FMC_LPC_DP0_M2C_P"] ;# Bank 226 - MGTHRXP3_226
set_property PACKAGE_PIN U5       [get_ports "38N7744"] ;# Bank 226 - MGTHTXN0_226
set_property PACKAGE_PIN T3       [get_ports "38N7740"] ;# Bank 226 - MGTHTXN1_226
set_property PACKAGE_PIN R5       [get_ports "38N8078"] ;# Bank 226 - MGTHTXN2_226
set_property PACKAGE_PIN N5       [get_ports "FMC_LPC_DP0_C2M_N"] ;# Bank 226 - MGTHTXN3_226
set_property PACKAGE_PIN U6       [get_ports "38N7743"] ;# Bank 226 - MGTHTXP0_226
set_property PACKAGE_PIN T4       [get_ports "38N7739"] ;# Bank 226 - MGTHTXP1_226
set_property PACKAGE_PIN R6       [get_ports "38N8077"] ;# Bank 226 - MGTHTXP2_226
set_property PACKAGE_PIN N6       [get_ports "FMC_LPC_DP0_C2M_P"] ;# Bank 226 - MGTHTXP3_226
set_property PACKAGE_PIN V7       [get_ports "FMC_LPC_GBTCLK0_M2C_C_N"] ;# Bank 226 - MGTREFCLK0N_226
set_property PACKAGE_PIN V8       [get_ports "FMC_LPC_GBTCLK0_M2C_C_P"] ;# Bank 226 - MGTREFCLK0P_226
set_property PACKAGE_PIN U9       [get_ports "HDMI_DRU_CLOCK_C_N"] ;# Bank 226 - MGTREFCLK1N_226
set_property PACKAGE_PIN U10      [get_ports "HDMI_DRU_CLOCK_C_P"] ;# Bank 226 - MGTREFCLK1P_226
set_property PACKAGE_PIN N1       [get_ports "HDMI_RX0_C_N"] ;# Bank 227 - MGTHRXN0_227
set_property PACKAGE_PIN L1       [get_ports "HDMI_RX1_C_N"] ;# Bank 227 - MGTHRXN1_227
set_property PACKAGE_PIN J1       [get_ports "HDMI_RX2_C_N"] ;# Bank 227 - MGTHRXN2_227
set_property PACKAGE_PIN G1       [get_ports "GND"] ;# Bank 227 - MGTHRXN3_227
set_property PACKAGE_PIN N2       [get_ports "HDMI_RX0_C_P"] ;# Bank 227 - MGTHRXP0_227
set_property PACKAGE_PIN L2       [get_ports "HDMI_RX1_C_P"] ;# Bank 227 - MGTHRXP1_227
set_property PACKAGE_PIN J2       [get_ports "HDMI_RX2_C_P"] ;# Bank 227 - MGTHRXP2_227
set_property PACKAGE_PIN G2       [get_ports "GND"] ;# Bank 227 - MGTHRXP3_227
set_property PACKAGE_PIN M3       [get_ports "HDMI_TX0_N"] ;# Bank 227 - MGTHTXN0_227
set_property PACKAGE_PIN L5       [get_ports "HDMI_TX1_N"] ;# Bank 227 - MGTHTXN1_227
set_property PACKAGE_PIN K3       [get_ports "HDMI_TX2_N"] ;# Bank 227 - MGTHTXN2_227
set_property PACKAGE_PIN H3       [get_ports "38N8088"] ;# Bank 227 - MGTHTXN3_227
set_property PACKAGE_PIN M4       [get_ports "HDMI_TX0_P"] ;# Bank 227 - MGTHTXP0_227
set_property PACKAGE_PIN L6       [get_ports "HDMI_TX1_P"] ;# Bank 227 - MGTHTXP1_227
set_property PACKAGE_PIN K4       [get_ports "HDMI_TX2_P"] ;# Bank 227 - MGTHTXP2_227
set_property PACKAGE_PIN H4       [get_ports "38N8087"] ;# Bank 227 - MGTHTXP3_227
set_property PACKAGE_PIN T7       [get_ports "HDMI_8T49N241_OUT_C_N"] ;# Bank 227 - MGTREFCLK0N_227
set_property PACKAGE_PIN T8       [get_ports "HDMI_8T49N241_OUT_C_P"] ;# Bank 227 - MGTREFCLK0P_227
set_property PACKAGE_PIN R9       [get_ports "HDMI_RX_CLK_C_N"] ;# Bank 227 - MGTREFCLK1N_227
set_property PACKAGE_PIN R10      [get_ports "HDMI_RX_CLK_C_P"] ;# Bank 227 - MGTREFCLK1P_227

# Clock Constraints

# Clock group constraint to ensure correct clock skew for ISERDES
set_property CLOCK_DELAY_GROUP ioclockGroup_rx1 [get_nets "rx_channel1/rx_clkdiv*"]

set_false_path -to [get_pins "ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxc_gen/iserdes_m/D"]
set_false_path -to [get_pins "ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxc_gen/iserdes_s/D"]
set_false_path -to [get_pins {ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxc_gen/px_reset_sync_reg[*]/PRE}] 
set_false_path -to [get_pins {ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxc_gen/px_rx_ready_sync_reg[*]/CLR}] 
set_false_path -to [get_pins {ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxc_gen/px_data_reg[*]/D}]
set_false_path -to [get_pins {ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxc_gen/px_rd_last_reg[*]/D}]
set_false_path -to [get_pins {ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxd[*].sipo/px_data_reg[*]/D}]
set_false_path -to [get_pins {ZCU104_Main_blk_i/clink_intf/inst/clink_X_7to1/rxd[*].sipo/px_rd_last_reg[*]/D}]

create_clock -period 12.195  [get_ports "FMC_LPC_LA13_P"] ;#

