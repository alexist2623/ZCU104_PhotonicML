`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/17 20:11:13
// Design Name: 
// Module Name: DAC_Controller_UUT
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

`include "axi_interface.sv"

module ImageReader_UUT#(
    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter LINES                     = 4,
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH            = 6,
    parameter AXI_DATA_WIDTH            = 128,
    parameter AXI_STROBE_WIDTH          = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN            = 4 // LOG(AXI_STROBE_WDITH)
)
(
    axi_if axi_if_inst,
    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink X data Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    input  wire        clink_X_clk_p,         // Camera Link clock positive
    input  wire        clink_X_clk_n,         // Camera Link clock negative
    input  wire        clink_X_data_0_p,      // Camera Link data X channels positive
    input  wire        clink_X_data_0_n,      // Camera Link data X channels negative
    input  wire        clink_X_data_1_p,      // Camera Link data X channels positive
    input  wire        clink_X_data_1_n,      // Camera Link data X channels negative
    input  wire        clink_X_data_2_p,      // Camera Link data X channels positive
    input  wire        clink_X_data_2_n,      // Camera Link data X channels negative
    input  wire        clink_X_data_3_p,      // Camera Link data X channels positive
    input  wire        clink_X_data_3_n,      // Camera Link data X channels negative
    output wire        clink_X_ready,         // Indicates when pixel data is valid
    output wire [7 * LINES - 1:0] pixel_X,
    output wire        clink_X_clk,

    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink UART Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    output wire        tx_serial,            // UART transmit serial output
    input  wire        rx_serial            // UART receive serial input
);

// DAC_Controller ins
ImageReader #(
    .LINES(LINES),
    .AXI_ADDR_WIDTH(axi_if_inst.AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(axi_if_inst.AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH(axi_if_inst.AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN(axi_if_inst.AXI_STROBE_LEN)
) uut (
    .s_axi_awaddr(axi_if_inst.s_axi_awaddr),
    .s_axi_awid(axi_if_inst.s_axi_awid),
    .s_axi_awburst(axi_if_inst.s_axi_awburst),
    .s_axi_awsize(axi_if_inst.s_axi_awsize),
    .s_axi_awlen(axi_if_inst.s_axi_awlen),
    .s_axi_awvalid(axi_if_inst.s_axi_awvalid),
    .s_axi_awuser(axi_if_inst.s_axi_awuser),
    .s_axi_awready(axi_if_inst.s_axi_awready),
    .s_axi_bready(axi_if_inst.s_axi_bready),
    .s_axi_bresp(axi_if_inst.s_axi_bresp),
    .s_axi_bvalid(axi_if_inst.s_axi_bvalid),
    .s_axi_bid(axi_if_inst.s_axi_bid),
    .s_axi_wdata(axi_if_inst.s_axi_wdata),
    .s_axi_wstrb(axi_if_inst.s_axi_wstrb),
    .s_axi_wvalid(axi_if_inst.s_axi_wvalid),
    .s_axi_wlast(axi_if_inst.s_axi_wlast),
    .s_axi_wready(axi_if_inst.s_axi_wready),
    .s_axi_arburst(axi_if_inst.s_axi_arburst),
    .s_axi_arlen(axi_if_inst.s_axi_arlen),
    .s_axi_araddr(axi_if_inst.s_axi_araddr),
    .s_axi_arsize(axi_if_inst.s_axi_arsize),
    .s_axi_arvalid(axi_if_inst.s_axi_arvalid),
    .s_axi_arid(axi_if_inst.s_axi_arid),
    .s_axi_aruser(axi_if_inst.s_axi_aruser),
    .s_axi_arready(axi_if_inst.s_axi_arready),
    .s_axi_rid(axi_if_inst.s_axi_rid),
    .s_axi_rdata(axi_if_inst.s_axi_rdata),
    .s_axi_rresp(axi_if_inst.s_axi_rresp),
    .s_axi_rvalid(axi_if_inst.s_axi_rvalid),
    .s_axi_rlast(axi_if_inst.s_axi_rlast),
    .s_axi_rready(axi_if_inst.s_axi_rready),
    .s_axi_aclk(axi_if_inst.s_axi_aclk),
    .s_axi_aresetn(axi_if_inst.s_axi_aresetn),
    
    // Cameralink X data Configuration
    
    .clink_X_clk_p(clink_X_clk_p),           // Camera Link clock positive
    .clink_X_clk_n(clink_X_clk_n),           // Camera Link clock negative
    .clink_X_data_0_p(clink_X_data_0_p),     // Camera Link data X channel 0 positive
    .clink_X_data_0_n(clink_X_data_0_n),     // Camera Link data X channel 0 negative
    .clink_X_data_1_p(clink_X_data_1_p),     // Camera Link data X channel 1 positive
    .clink_X_data_1_n(clink_X_data_1_n),     // Camera Link data X channel 1 negative
    .clink_X_data_2_p(clink_X_data_2_p),     // Camera Link data X channel 2 positive
    .clink_X_data_2_n(clink_X_data_2_n),     // Camera Link data X channel 2 negative
    .clink_X_data_3_p(clink_X_data_3_p),     // Camera Link data X channel 3 positive
    .clink_X_data_3_n(clink_X_data_3_n),     // Camera Link data X channel 3 negative
    .clink_X_ready(clink_X_ready),           // Indicates when pixel data is valid
    .pixel_X(pixel_X),                       // Output pixel data
    .clink_X_clk(clink_X_clk),               // Camera Link clock

    // Cameralink UART Configuration
    
    .tx_serial(tx_serial),                   // UART transmit serial output
    .rx_serial(rx_serial)                    // UART receive serial input
);

endmodule