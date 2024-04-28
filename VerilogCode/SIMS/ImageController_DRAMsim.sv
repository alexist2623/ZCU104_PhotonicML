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

reg [38:0]            S00_AXI_0_araddr;
reg [1:0]             S00_AXI_0_arburst;
reg [3:0]             S00_AXI_0_arcache;
reg [16:0]            S00_AXI_0_arid;
reg [7:0]             S00_AXI_0_arlen;
reg [0:0]             S00_AXI_0_arlock;
reg [2:0]             S00_AXI_0_arprot;
reg [3:0]             S00_AXI_0_arqos;
wire [0:0]            S00_AXI_0_arready;
reg [2:0]             S00_AXI_0_arsize;
reg [15:0]            S00_AXI_0_aruser;
reg [0:0]             S00_AXI_0_arvalid;
reg [38:0]            S00_AXI_0_awaddr;
reg [1:0]             S00_AXI_0_awburst;
reg [3:0]             S00_AXI_0_awcache;
reg [16:0]            S00_AXI_0_awid;
reg [7:0]             S00_AXI_0_awlen;
reg [0:0]             S00_AXI_0_awlock;
reg [2:0]             S00_AXI_0_awprot;
reg [3:0]             S00_AXI_0_awqos;
wire [0:0]            S00_AXI_0_awready;
reg [2:0]             S00_AXI_0_awsize;
reg [15:0]            S00_AXI_0_awuser;
reg [0:0]             S00_AXI_0_awvalid;
wire [16:0]           S00_AXI_0_bid;
reg [0:0]             S00_AXI_0_bready;
wire [1:0]            S00_AXI_0_bresp;
wire [0:0]            S00_AXI_0_bvalid;
wire [511:0]          S00_AXI_0_rdata;
wire [16:0]           S00_AXI_0_rid;
wire [0:0]            S00_AXI_0_rlast;
reg [0:0]             S00_AXI_0_rready;
wire [1:0]            S00_AXI_0_rresp;
wire [0:0]            S00_AXI_0_rvalid;
reg [511:0]           S00_AXI_0_wdata;
reg [0:0]             S00_AXI_0_wlast;
wire [0:0]            S00_AXI_0_wready;
reg [63:0]            S00_AXI_0_wstrb;
reg [0:0]             S00_AXI_0_wvalid;

reg                   clk_pixel;
reg                   s_axi_aclk;
reg                   s_axi_aresetn;
wire [9:0]            tmds0_10bit_0;
wire [9:0]            tmds1_10bit_0;
wire [9:0]            tmds2_10bit_0;

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

ZCU104_Main_blk_wrapper zcu104_main_blk_wrapper_inst (
    .S00_AXI_0_araddr(S00_AXI_0_araddr),
    .S00_AXI_0_arburst(S00_AXI_0_arburst),
    .S00_AXI_0_arcache(S00_AXI_0_arcache),
    .S00_AXI_0_arid(S00_AXI_0_arid),
    .S00_AXI_0_arlen(S00_AXI_0_arlen),
    .S00_AXI_0_arlock(S00_AXI_0_arlock),
    .S00_AXI_0_arprot(S00_AXI_0_arprot),
    .S00_AXI_0_arqos(S00_AXI_0_arqos),
    .S00_AXI_0_arready(S00_AXI_0_arready),
    .S00_AXI_0_arsize(S00_AXI_0_arsize),
    .S00_AXI_0_aruser(S00_AXI_0_aruser),
    .S00_AXI_0_arvalid(S00_AXI_0_arvalid),
    .S00_AXI_0_awaddr(S00_AXI_0_awaddr),
    .S00_AXI_0_awburst(S00_AXI_0_awburst),
    .S00_AXI_0_awcache(S00_AXI_0_awcache),
    .S00_AXI_0_awid(S00_AXI_0_awid),
    .S00_AXI_0_awlen(S00_AXI_0_awlen),
    .S00_AXI_0_awlock(S00_AXI_0_awlock),
    .S00_AXI_0_awprot(S00_AXI_0_awprot),
    .S00_AXI_0_awqos(S00_AXI_0_awqos),
    .S00_AXI_0_awready(S00_AXI_0_awready),
    .S00_AXI_0_awsize(S00_AXI_0_awsize),
    .S00_AXI_0_awuser(S00_AXI_0_awuser),
    .S00_AXI_0_awvalid(S00_AXI_0_awvalid),
    .S00_AXI_0_bid(S00_AXI_0_bid),
    .S00_AXI_0_bready(S00_AXI_0_bready),
    .S00_AXI_0_bresp(S00_AXI_0_bresp),
    .S00_AXI_0_bvalid(S00_AXI_0_bvalid),
    .S00_AXI_0_rdata(S00_AXI_0_rdata),
    .S00_AXI_0_rid(S00_AXI_0_rid),
    .S00_AXI_0_rlast(S00_AXI_0_rlast),
    .S00_AXI_0_rready(S00_AXI_0_rready),
    .S00_AXI_0_rresp(S00_AXI_0_rresp),
    .S00_AXI_0_rvalid(S00_AXI_0_rvalid),
    .S00_AXI_0_wdata(S00_AXI_0_wdata),
    .S00_AXI_0_wlast(S00_AXI_0_wlast),
    .S00_AXI_0_wready(S00_AXI_0_wready),
    .S00_AXI_0_wstrb(S00_AXI_0_wstrb),
    .S00_AXI_0_wvalid(S00_AXI_0_wvalid),
    
    .clk_300mhz_clk_n(c0_sys_clk_n),
    .clk_300mhz_clk_p(c0_sys_clk_p),
    .clk_pixel(clk_pixel),
    .ddr4_sdram_act_n(c0_ddr4_act_n),
    .ddr4_sdram_adr(c0_ddr4_adr),
    .ddr4_sdram_ba(c0_ddr4_ba),
    .ddr4_sdram_bg(c0_ddr4_bg),
    .ddr4_sdram_ck_c(c0_ddr4_ck_c),
    .ddr4_sdram_ck_t(c0_ddr4_ck_t),
    .ddr4_sdram_cke(c0_ddr4_cke),
    .ddr4_sdram_cs_n(c0_ddr4_cs_n),
    .ddr4_sdram_dm_n(c0_ddr4_dm_dbi_n),
    .ddr4_sdram_dq(c0_ddr4_dq),
    .ddr4_sdram_dqs_c(c0_ddr4_dqs_c),
    .ddr4_sdram_dqs_t(c0_ddr4_dqs_t),
    .ddr4_sdram_odt(c0_ddr4_odt),
    .ddr4_sdram_reset_n(c0_ddr4_reset_n),
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .sys_rst(sys_rst),
    .tmds0_10bit_0(tmds0_10bit_0),
    .tmds1_10bit_0(tmds1_10bit_0),
    .tmds2_10bit_0(tmds2_10bit_0)
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
    s_axi_aclk = 0;
    forever #4 s_axi_aclk = ~s_axi_aclk; // Toggle every 4ns for 125MHz clock
end

// Clock generation for clk_pixel (148.5MHz)
initial begin
    clk_pixel = 0;
    forever #3.367 clk_pixel = ~clk_pixel; // Toggle every 3.367ns for 148.5MHz clock
end
    
initial begin
// Initialize write signals    
    S00_AXI_0_araddr <= 39'h0;
    S00_AXI_0_arburst <= 2'b00;
    S00_AXI_0_arcache <= 4'b0000;
    S00_AXI_0_arid <= 17'h0;
    S00_AXI_0_arlen <= 8'h00;
    S00_AXI_0_arlock <= 1'b0;
    S00_AXI_0_arprot <= 3'h0;
    S00_AXI_0_arqos <= 4'h0;
    S00_AXI_0_arsize <= 3'h0;
    S00_AXI_0_aruser <= 16'h0;
    S00_AXI_0_arvalid <= 1'b0;
    S00_AXI_0_awaddr <= 39'h0;
    S00_AXI_0_awburst <= 2'b00;
    S00_AXI_0_awcache <= 4'h0;
    S00_AXI_0_awid <= 16'h0;
    S00_AXI_0_awlen <= 8'h0;
    S00_AXI_0_awlock <= 1'b0;
    S00_AXI_0_awprot <= 3'h0;
    S00_AXI_0_awqos <= 4'h0;
    S00_AXI_0_awsize <= 3'b110;
    S00_AXI_0_awuser <= 16'h0;
    S00_AXI_0_awvalid <= 1'b0;
    S00_AXI_0_bready <= 1'b0;
    S00_AXI_0_rready <= 1'b0;
    S00_AXI_0_wdata <= 512'h0000_0000_0000_0000_0000_0000_0000_0000;
    S00_AXI_0_wlast <= 1'b0;
    S00_AXI_0_wstrb <= 64'hffff_ffff_ffff_ffff;
    S00_AXI_0_wvalid <= 1'b0;
    s_axi_aresetn <= 1'b0;

    #10000;
    s_axi_aresetn <= 1'b1;
    
    #10000;
    // Start write transaction
    S00_AXI_0_awaddr <= 39'h04_A000_0000; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= 'h1234_5678_1234_5678_1234_5678_FFFF_FFFF_1234_5678_1234_5678_1234_5678_FFFF_FFFF_1234_5678_1234_5678_1234_5678_FFFF_FFFF_1234_5678_1234_5678_1234_5678_FFFF_FFFF; // Example write data
    S00_AXI_0_wstrb <= 64'hFFFF_FFFF_FFFF_FFFF; // All bytes are valid
    S00_AXI_0_wlast <= 1;
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_rready <= 1;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    wait(~S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 0;
    
    // Wait for BVALID and then de-assert BREADY
    wait(S00_AXI_0_bvalid);
    wait(~S00_AXI_0_bvalid);
    S00_AXI_0_bready <= 0;
    
    #10000;
    
    // Initialize read signals
    S00_AXI_0_rready <= 1;
    
    // Start read transaction
    S00_AXI_0_araddr <= 39'h04_A000_0000; // Example read address
    S00_AXI_0_arvalid <= 1;
    
    // Wait for ARREADY and then de-assert ARVALID
    wait(S00_AXI_0_arready);
    wait(~S00_AXI_0_arready);
    S00_AXI_0_arvalid <= 0;
    
    // Wait for RVALID
    wait(S00_AXI_0_rlast);
    $display("Read data: %h", S00_AXI_0_rdata); 
    wait(~S00_AXI_0_rlast);
    S00_AXI_0_rready <= 0;
    // Do something with the read data
    $finish;
end

endmodule
