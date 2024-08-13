`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/17 20:10:17
// Design Name: 
// Module Name: axi_interface
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


interface axi_if#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH        = 32,
    parameter AXI_DATA_WIDTH        = 128,
    parameter AXI_STROBE_WIDTH      = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN        = $clog2(AXI_STROBE_WIDTH) // LOG(AXI_STROBE_WDITH)
)
(
    input bit s_axi_aclk
);
    logic [AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
    logic [15:0] s_axi_awid;
    logic [1:0] s_axi_awburst;
    logic [2:0] s_axi_awsize;
    logic [7:0] s_axi_awlen;
    logic s_axi_awvalid;
    logic [15:0] s_axi_awuser;
    logic s_axi_awready;
    
    logic s_axi_bready;
    logic [1:0] s_axi_bresp;
    logic s_axi_bvalid;
    logic [15:0] s_axi_bid;
    
    logic [127:0] s_axi_wdata;
    logic [15:0] s_axi_wstrb;
    logic s_axi_wvalid;
    logic s_axi_wlast;
    logic s_axi_wready;
    
    logic [1:0] s_axi_arburst;
    logic [7:0] s_axi_arlen;
    logic [5:0] s_axi_araddr;
    logic [2:0] s_axi_arsize;
    logic s_axi_arvalid;
    logic [15:0] s_axi_arid;
    logic [15:0] s_axi_aruser;
    logic s_axi_arready;
    logic [15:0] s_axi_rid;
    
    logic s_axi_rready;
    logic [127:0] s_axi_rdata;
    logic [1:0] s_axi_rresp;
    logic s_axi_rvalid;
    logic s_axi_rlast;
    
    logic s_axi_aresetn;
    
    task automatic write(input[AXI_ADDR_WIDTH-1:0] addr, input[127:0] data);
        @(posedge s_axi_aclk);
        s_axi_awaddr <= addr;
        s_axi_awvalid <= 1;
        s_axi_wdata <= data;
        s_axi_wvalid <= 1;
        s_axi_wlast <= 1;
        
        wait (s_axi_awready);
        #8;
        wait (~s_axi_awready);
        s_axi_awvalid <= 0;
        
        wait(s_axi_wready);
        #8;
        wait(~s_axi_wready);
        s_axi_wlast <= 0;
        s_axi_wdata <= 0;
        s_axi_bready <= 1'b1;
        
        wait(s_axi_bvalid);
        #8;
        s_axi_wvalid <= 0;
        
        if( s_axi_bresp != 2'b00 ) begin
            $display("AXI RESPONSE IS NOT OKAY : %d",s_axi_bresp);
        end
        else begin
            $display("AXI WRITE");
        end
    endtask
    
    task automatic init();
        s_axi_awaddr = 0;
        s_axi_awid = 0;
        s_axi_awburst = 0;
        s_axi_awsize = 0;
        s_axi_awlen = 0;
        s_axi_awvalid = 0;
        s_axi_awuser = 0;
        s_axi_bready = 0;
        s_axi_wdata = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_wlast = 0;
        s_axi_arburst = 0;
        s_axi_arlen = 0;
        s_axi_araddr = 0;
        s_axi_arsize = 0;
        s_axi_arvalid = 0;
        s_axi_arid = 0;
        s_axi_aruser = 0;
        s_axi_rready = 0;
        s_axi_aresetn = 0;
        #100;
        s_axi_aresetn = 1;
    endtask
endinterface : axi_if
