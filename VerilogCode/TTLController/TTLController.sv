`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/24 11:15:28
// Design Name: 
// Module Name: MasterController
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


module TTLController
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH = 6,
    parameter AXI_DATA_WIDTH = 128,
    parameter AXI_STROBE_WIDTH = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN = 4 // LOG(AXI_STROBE_WDITH)
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
    input  wire [15:0] s_axi_awid, 
    input  wire [1:0] s_axi_awburst,
    input  wire [2:0] s_axi_awsize,
    input  wire [7:0] s_axi_awlen,
    input  wire s_axi_awvalid,
    input  wire [15:0] s_axi_awuser, // added to resolve wrapping error
    output wire s_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_bready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    output wire [15:0] s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_DATA_WIDTH - 1:0] s_axi_wdata,
    input  wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input  wire s_axi_wvalid,
    input  wire s_axi_wlast,
    output wire s_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [1:0] s_axi_arburst,
    input  wire [7:0] s_axi_arlen,
    input  wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr,
    input  wire [2:0] s_axi_arsize,
    input  wire s_axi_arvalid,
    input  wire [15:0] s_axi_arid, // added to resolve wrapping error
    input  wire [15:0] s_axi_aruser, // added to resolve wrapping error
    output wire s_axi_arready,
    output wire [15:0] s_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_rready,
    output wire [AXI_DATA_WIDTH - 1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    output wire s_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_aresetn,
    
    //////////////////////////////////////////////////////////////////////////////////
    // TTL Out
    //////////////////////////////////////////////////////////////////////////////////
    output wire  ttl_out_00_p,
    output wire  ttl_out_00_n,
    output wire  ttl_out_01_p,
    output wire  ttl_out_01_n,
    output wire  ttl_out_02_p,
    output wire  ttl_out_02_n,
    output wire  ttl_out_03_p,
    output wire  ttl_out_03_n,
    output wire  ttl_out_04_p,
    output wire  ttl_out_04_n,
    output wire  ttl_out_05_p,
    output wire  ttl_out_05_n,
    output wire  ttl_out_06_p,
    output wire  ttl_out_06_n,
    output wire  ttl_out_07_p,
    output wire  ttl_out_07_n,
    output wire  ttl_out_08_p,
    output wire  ttl_out_08_n,
    output wire  ttl_out_09_p,
    output wire  ttl_out_09_n,
    output wire  ttl_out_10_p,
    output wire  ttl_out_10_n,
    output wire  ttl_out_11_p,
    output wire  ttl_out_11_n,
    output wire  ttl_out_12_p,
    output wire  ttl_out_12_n,
    output wire  ttl_out_13_p,
    output wire  ttl_out_13_n,
    output wire  ttl_out_14_p,
    output wire  ttl_out_14_n,
    output wire  ttl_out_15_p,
    output wire  ttl_out_15_n,
    output wire  ttl_out_16_p,
    output wire  ttl_out_16_n,
    output wire  ttl_out_17_p,
    output wire  ttl_out_17_n,
    output wire  ttl_out_18_p,
    output wire  ttl_out_18_n,
    output wire  ttl_out_19_p,
    output wire  ttl_out_19_n,
    output wire  ttl_out_20_p,
    output wire  ttl_out_20_n,
    output wire  ttl_out_21_p,
    output wire  ttl_out_21_n,
    output wire  ttl_out_22_p,
    output wire  ttl_out_22_n,
    output wire  ttl_out_23_p,
    output wire  ttl_out_23_n,
    output wire  ttl_out_24_p,
    output wire  ttl_out_24_n,
    output wire  ttl_out_25_p,
    output wire  ttl_out_25_n,
    output wire  ttl_out_26_p,
    output wire  ttl_out_26_n,
    output wire  ttl_out_27_p,
    output wire  ttl_out_27_n,
    output wire  ttl_out_28_p,
    output wire  ttl_out_28_n,
    output wire  ttl_out_29_p,
    output wire  ttl_out_29_n,
    output wire  ttl_out_30_p,
    output wire  ttl_out_30_n,
    output wire  ttl_out_31_p,
    output wire  ttl_out_31_n
);

wire [31:0] ttl_out;

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_00(
    .I(ttl_out[0]),
    .O(ttl_out_00_p),
    .OB(ttl_out_00_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_01(
    .I(ttl_out[1]),
    .O(ttl_out_01_p),
    .OB(ttl_out_01_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_02(
    .I(ttl_out[2]),
    .O(ttl_out_02_p),
    .OB(ttl_out_02_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_03(
    .I(ttl_out[3]),
    .O(ttl_out_03_p),
    .OB(ttl_out_03_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_04(
    .I(ttl_out[4]),
    .O(ttl_out_04_p),
    .OB(ttl_out_04_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_05(
    .I(ttl_out[5]),
    .O(ttl_out_05_p),
    .OB(ttl_out_05_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_06(
    .I(ttl_out[6]),
    .O(ttl_out_06_p),
    .OB(ttl_out_06_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_07(
    .I(ttl_out[7]),
    .O(ttl_out_07_p),
    .OB(ttl_out_07_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_08(
    .I(ttl_out[8]),
    .O(ttl_out_08_p),
    .OB(ttl_out_08_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_09(
    .I(ttl_out[9]),
    .O(ttl_out_09_p),
    .OB(ttl_out_09_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_10(
    .I(ttl_out[10]),
    .O(ttl_out_10_p),
    .OB(ttl_out_10_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_11(
    .I(ttl_out[11]),
    .O(ttl_out_11_p),
    .OB(ttl_out_11_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_12(
    .I(ttl_out[12]),
    .O(ttl_out_12_p),
    .OB(ttl_out_12_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_13(
    .I(ttl_out[13]),
    .O(ttl_out_13_p),
    .OB(ttl_out_13_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_14(
    .I(ttl_out[14]),
    .O(ttl_out_14_p),
    .OB(ttl_out_14_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_15(
    .I(ttl_out[15]),
    .O(ttl_out_15_p),
    .OB(ttl_out_15_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_16(
    .I(ttl_out[16]),
    .O(ttl_out_16_p),
    .OB(ttl_out_16_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_17(
    .I(ttl_out[17]),
    .O(ttl_out_17_p),
    .OB(ttl_out_17_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_18(
    .I(ttl_out[18]),
    .O(ttl_out_18_p),
    .OB(ttl_out_18_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_19(
    .I(ttl_out[19]),
    .O(ttl_out_19_p),
    .OB(ttl_out_19_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_20(
    .I(ttl_out[20]),
    .O(ttl_out_20_p),
    .OB(ttl_out_20_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_21(
    .I(ttl_out[21]),
    .O(ttl_out_21_p),
    .OB(ttl_out_21_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_22(
    .I(ttl_out[22]),
    .O(ttl_out_22_p),
    .OB(ttl_out_22_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_23(
    .I(ttl_out[23]),
    .O(ttl_out_23_p),
    .OB(ttl_out_23_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_24(
    .I(ttl_out[24]),
    .O(ttl_out_24_p),
    .OB(ttl_out_24_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_25(
    .I(ttl_out[25]),
    .O(ttl_out_25_p),
    .OB(ttl_out_25_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_26(
    .I(ttl_out[26]),
    .O(ttl_out_26_p),
    .OB(ttl_out_26_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_27(
    .I(ttl_out[27]),
    .O(ttl_out_27_p),
    .OB(ttl_out_27_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_28(
    .I(ttl_out[28]),
    .O(ttl_out_28_p),
    .OB(ttl_out_28_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_29(
    .I(ttl_out[29]),
    .O(ttl_out_29_p),
    .OB(ttl_out_29_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_30(
    .I(ttl_out[30]),
    .O(ttl_out_30_p),
    .OB(ttl_out_30_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS")
) lvds_output_31(
    .I(ttl_out[31]),
    .O(ttl_out_31_p),
    .OB(ttl_out_31_n)
);

//////////////////////////////////////////////////////////////////////////////////
// AXI2COM
//////////////////////////////////////////////////////////////////////////////////

AXI2COM
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH(AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN(AXI_STROBE_LEN)
)
axi2com_0(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awid(s_axi_awid),
    .s_axi_awburst(s_axi_awburst),
    .s_axi_awsize(s_axi_awsize),
    .s_axi_awlen(s_axi_awsize),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awuser(s_axi_awuser), // added to resolve wrapping error
    .s_axi_awready(s_axi_awready),                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_bready(s_axi_bready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bid(s_axi_bid), // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wlast(s_axi_wlast),
    .s_axi_wready(s_axi_wready),                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_arburst(s_axi_arburst),
    .s_axi_arlen(s_axi_arlen),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arsize(s_axi_arsize),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arid(s_axi_arid), // added to resolve wrapping error
    .s_axi_aruser(s_axi_aruser), // added to resolve wrapping error
    .s_axi_arready(s_axi_arready),
    .s_axi_rid(s_axi_rid), // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_rready(s_axi_rready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rlast(s_axi_rlast),
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_aclk(s_axi_aclk),
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_aresetn(s_axi_aresetn),
    
    //////////////////////////////////////////////////////////////////////////////////
    // TTL Out
    //////////////////////////////////////////////////////////////////////////////////
    .ttl_out(ttl_out)
);


endmodule