`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 00:22:58
// Design Name: 
// Module Name: ZCU104sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ZCU104sim;
wire HDMI_TX0_N;
wire HDMI_TX0_P;
wire HDMI_TX1_N;
wire HDMI_TX1_P;
wire HDMI_TX2_N;
wire HDMI_TX2_P;
wire HDMI_TX_EN;
wire HDMI_TX_LVDS_OUT_N;
wire HDMI_TX_LVDS_OUT_P;
wire HDMI_DRU_CLOCK_C_N;
reg HDMI_DRU_CLOCK_C_P;

wire                  sys_rst; //Common port for all controllers
wire                  c0_init_calib_complete;
wire                  c0_data_compare_error;
wire                  c0_sys_clk_p;
wire                  c0_sys_clk_n;
wire                  c0_ddr4_act_n;
wire  [16:0]          c0_ddr4_adr;
wire  [1:0]           c0_ddr4_ba;
wire  [1:0]           c0_ddr4_bg;
wire  [0:0]           c0_ddr4_cke;
wire  [0:0]           c0_ddr4_odt;
wire  [0:0]           c0_ddr4_cs_n;
wire  [0:0]           c0_ddr4_ck_t;
wire  [0:0]           c0_ddr4_ck_c;
wire                  c0_ddr4_reset_n;
wire  [7:0]           c0_ddr4_dm_dbi_n;
wire  [63:0]          c0_ddr4_dq;
wire  [7:0]           c0_ddr4_dqs_c;
wire  [7:0]           c0_ddr4_dqs_t;

ZCU104_Main_blk_wrapper tb
(
    .HDMI_DRU_CLOCK_C_N                 (HDMI_DRU_CLOCK_C_N),
    .HDMI_DRU_CLOCK_C_P                 (HDMI_DRU_CLOCK_C_P),
    .HDMI_TX0_N                         (HDMI_TX0_N),
    .HDMI_TX0_P                         (HDMI_TX0_P),
    .HDMI_TX1_N                         (HDMI_TX1_N),
    .HDMI_TX1_P                         (HDMI_TX1_P),
    .HDMI_TX2_N                         (HDMI_TX2_N),
    .HDMI_TX2_P                         (HDMI_TX2_P),
    .HDMI_TX_EN                         (HDMI_TX_EN),
    .HDMI_TX_LVDS_OUT_N                 (HDMI_TX_LVDS_OUT_N),
    .HDMI_TX_LVDS_OUT_P                 (HDMI_TX_LVDS_OUT_P),
    .clk_300mhz_clk_n                   (c0_sys_clk_n),
    .clk_300mhz_clk_p                   (c0_sys_clk_p),
    .ddr4_sdram_act_n                   (c0_ddr4_act_n),
    .ddr4_sdram_adr                     (c0_ddr4_adr),
    .ddr4_sdram_ba                      (c0_ddr4_ba),
    .ddr4_sdram_bg                      (c0_ddr4_bg),
    .ddr4_sdram_ck_c                    (c0_ddr4_ck_c),
    .ddr4_sdram_ck_t                    (c0_ddr4_ck_t),
    .ddr4_sdram_cke                     (c0_ddr4_cke),
    .ddr4_sdram_cs_n                    (c0_ddr4_cs_n),
    .ddr4_sdram_dm_n                    (c0_ddr4_dm_dbi_n),
    .ddr4_sdram_dq                      (c0_ddr4_dq),
    .ddr4_sdram_dqs_c                   (c0_ddr4_dqs_c),
    .ddr4_sdram_dqs_t                   (c0_ddr4_dqs_t),
    .ddr4_sdram_odt                     (c0_ddr4_odt),
    .ddr4_sdram_reset_n                 (c0_ddr4_reset_n)
);

dram_sim dram_sim_0(
    .sys_rst                            (sys_rst), //Common port for all controllers

    .c0_init_calib_complete             (c0_init_calib_complete),
    .c0_data_compare_error              (c0_data_compare_error),
    .c0_sys_clk_p                       (c0_sys_clk_p),
    .c0_sys_clk_n                       (c0_sys_clk_n),
    .c0_ddr4_act_n                      (c0_ddr4_act_n),
    .c0_ddr4_adr                        (c0_ddr4_adr),
    .c0_ddr4_ba                         (c0_ddr4_ba),
    .c0_ddr4_bg                         (c0_ddr4_bg),
    .c0_ddr4_cke                        (c0_ddr4_cke),
    .c0_ddr4_odt                        (c0_ddr4_odt),
    .c0_ddr4_cs_n                       (c0_ddr4_cs_n),
    .c0_ddr4_ck_t                       (c0_ddr4_ck_t),
    .c0_ddr4_ck_c                       (c0_ddr4_ck_c),
    .c0_ddr4_reset_n                    (c0_ddr4_reset_n),
    .c0_ddr4_dm_dbi_n                   (c0_ddr4_dm_dbi_n),
    .c0_ddr4_dq                         (c0_ddr4_dq),
    .c0_ddr4_dqs_c                      (c0_ddr4_dqs_c),
    .c0_ddr4_dqs_t                      (c0_ddr4_dqs_t)
);

// Clock generation
initial begin
    HDMI_DRU_CLOCK_C_P = 0;
    forever #3.2 HDMI_DRU_CLOCK_C_P = ~HDMI_DRU_CLOCK_C_P; // 156.25MHz clock period
end

assign HDMI_DRU_CLOCK_C_N = ~HDMI_DRU_CLOCK_C_P;

reg [31:0] IMAGE_CONTROLLER_ADDR = 32'ha001_0000; // Starting ADDRess of the write burst
reg [31:0] MASTER_CONTROLLER_ADDR = 32'ha000_0000; // Starting ADDRess of the write burst
reg [7:0] LEN = 8'h0F;           // Burst length (e.g., 16 transfers)
reg [2:0] SIZE = 3'b100;         // Burst size (e.g., 4 bytes per transfer)
reg [1:0] BURST = 2'b00;         // Burst type (e.g., INCR for incremental burst)
reg [1:0] LOCK = 2'b00;          // Lock type
reg [3:0] CACHE = 4'b0011;       // Cache type
reg [2:0] PROT = 3'b010;         // Protection type
reg [127:0] DATA = {128{1'b1}}; // Data to send
reg [7:0] DATASIZE = 128 / 8; // Size in bytes of the valid data contained in the DATA vector
reg [1:0] response1;
reg [1:0] response2;
    
initial begin
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    #2000;
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
    #2000;
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.fpga_soft_reset(4'hf);
    #4000;
    //minimum 16 clock pulse width delay
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    #4000;
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.fpga_soft_reset(4'h0);
    #15000;
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.write_burst(IMAGE_CONTROLLER_ADDR, LEN, SIZE, BURST, LOCK, CACHE, PROT, DATA, DATASIZE, response1);
    #15000;
    //reset in clk_pixel region
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.write_data(MASTER_CONTROLLER_ADDR, 8'h10, 128'h00000000000000000000000000000000 + 4'b0010, response2);
    #100;
    //reset end
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.write_data(MASTER_CONTROLLER_ADDR, 8'h10, 128'h00000000000000000000000000000000 + 4'b0000, response2);
    //auto start
    #100;
    tb.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.write_data(MASTER_CONTROLLER_ADDR, 8'h10, 128'h00000000000000000000000000000000 + 4'b1001, response2);
end

endmodule
