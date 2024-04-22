`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/18 16:37:21
// Design Name: 
// Module Name: AXI2FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 128 bit slave AXI4 to native FIFO interface module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DRAM_Controller
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH                    = 6,
    parameter AXI_DATA_WIDTH                    = 128,
    parameter AXI_STROBE_WIDTH                  = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                    = 4 // LOG(AXI_STROBE_WDITH)
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Write
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [AXI_ADDR_WIDTH - 1:0] m_axi_awaddr,
    output  reg [15:0] m_axi_awid, 
    output  reg [1:0] m_axi_awburst,
    output  reg [2:0] m_axi_awsize,
    output  reg [7:0] m_axi_awlen,
    output  reg m_axi_awvalid,
    output  reg [15:0] m_axi_awuser, // added to resolve wrapping error
    input  wire m_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Write Response
    //////////////////////////////////////////////////////////////////////////////////
    output  reg m_axi_bready,
    input  wire [1:0] m_axi_bresp,
    input  wire m_axi_bvalid,
    input  wire [15:0] m_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Data Write
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [AXI_DATA_WIDTH - 1:0] m_axi_wdata,
    output  reg [AXI_STROBE_WIDTH - 1:0] m_axi_wstrb,
    output  reg m_axi_wvalid,
    output  reg m_axi_wlast,
    input  wire m_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Read
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [1:0] m_axi_arburst,
    output  reg [7:0] m_axi_arlen,
    output  reg [AXI_ADDR_WIDTH - 1:0] m_axi_araddr,
    output  reg [2:0] m_axi_arsize,
    output  reg m_axi_arvalid,
    output  reg [15:0] m_axi_arid, // added to resolve wrapping error
    output  reg [15:0] m_axi_aruser, // added to resolve wrapping error
    input  wire m_axi_arready,
    input  wire [15:0] m_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Data Read
    //////////////////////////////////////////////////////////////////////////////////
    output wire m_axi_rready,
    input  wire [AXI_DATA_WIDTH - 1:0] m_axi_rdata,
    input  wire [1:0] m_axi_rresp,
    input  wire m_axi_rvalid,
    input  wire m_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Clock
    //////////////////////////////////////////////////////////////////////////////////
    input  wire m_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire m_axi_aresetn
);

endmodule