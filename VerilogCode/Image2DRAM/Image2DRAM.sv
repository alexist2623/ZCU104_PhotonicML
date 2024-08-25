`timescale 1ns / 1ps

module Image2DRAM
#(
    //////////////////////////////////////////////////////////////////////////////////
    // DRAM Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter DRAM_ADDR_WIDTH               = 39,
    parameter DRAM_DATA_WIDTH               = 512,
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter MAXI_ADDR_WIDTH               = 39,
    parameter MAXI_DATA_WIDTH               = DRAM_DATA_WIDTH,
    parameter AXI_STROBE_WIDTH              = SAXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                = 4 // LOG(AXI_STROBE_WDITH)
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Write
    //////////////////////////////////////////////////////////////////////////////////
    output wire [MAXI_ADDR_WIDTH - 1:0] m_axi_awaddr,
    output wire [15:0] m_axi_awid, 
    output wire [1:0] m_axi_awburst,
    output wire [2:0] m_axi_awsize,
    output wire [7:0] m_axi_awlen,
    output wire m_axi_awvalid,
    output wire [15:0] m_axi_awuser, // added to resolve wrapping error
    input  wire m_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Write Response
    //////////////////////////////////////////////////////////////////////////////////
    output wire m_axi_bready,
    input  wire [1:0] m_axi_bresp,
    input  wire m_axi_bvalid,
    input  wire [15:0] m_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Data Write
    //////////////////////////////////////////////////////////////////////////////////
    output wire [MAXI_DATA_WIDTH - 1:0] m_axi_wdata,
    output wire [AXI_STROBE_WIDTH - 1:0] m_axi_wstrb,
    output wire m_axi_wvalid,
    output wire m_axi_wlast,
    input  wire m_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Read
    //////////////////////////////////////////////////////////////////////////////////
    output wire [1:0] m_axi_arburst,
    output wire [7:0] m_axi_arlen,
    output wire [MAXI_ADDR_WIDTH - 1:0] m_axi_araddr,
    output wire [2:0] m_axi_arsize,
    output wire m_axi_arvalid,
    output wire [15:0] m_axi_arid, // added to resolve wrapping error
    output wire [15:0] m_axi_aruser, // added to resolve wrapping error
    input  wire m_axi_arready,
    input  wire [15:0] m_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Data Read
    //////////////////////////////////////////////////////////////////////////////////
    output wire m_axi_rready,
    input  wire [MAXI_DATA_WIDTH - 1:0] m_axi_rdata,
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
    input  wire m_axi_aresetn,

    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [7:0]  d0,
    input  wire [7:0]  d1,
    input  wire [7:0]  d2,
    input  wire fval,
    input  wire dval,
    input  wire lval
);

wire [MAXI_ADDR_WIDTH - 1:0] dram_write_addr;
wire [7:0] dram_write_len;
wire dram_write_en;
wire [MAXI_DATA_WIDTH - 1:0] dram_write_data;

wire [MAXI_DATA_WIDTH - 1:0] dram_read_data;
wire dram_read_data_valid;
wire dram_write_busy;
wire dram_read_busy;

//////////////////////////////////////////////////////////////////////////////////
// DRAM Controller with axi interface
//////////////////////////////////////////////////////////////////////////////////

DRAM_Controller #(
    .AXI_ADDR_WIDTH                 (MAXI_ADDR_WIDTH),
    .DRAM_DATA_WIDTH                (DRAM_DATA_WIDTH),
    .AXI_DATA_WIDTH                 (DRAM_DATA_WIDTH),
    .AXI_STROBE_WIDTH               (AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN                 (AXI_STROBE_LEN)
) dram_controller_0 (
    .m_axi_awaddr                   (m_axi_awaddr),
    .m_axi_awid                     (m_axi_awid),
    .m_axi_awburst                  (m_axi_awburst),
    .m_axi_awsize                   (m_axi_awsize),
    .m_axi_awlen                    (m_axi_awlen),
    .m_axi_awvalid                  (m_axi_awvalid),
    .m_axi_awuser                   (m_axi_awuser),
    .m_axi_awready                  (m_axi_awready),
    .m_axi_bready                   (m_axi_bready),
    .m_axi_bresp                    (m_axi_bresp),
    .m_axi_bvalid                   (m_axi_bvalid),
    .m_axi_bid                      (m_axi_bid),
    .m_axi_wdata                    (m_axi_wdata),
    .m_axi_wstrb                    (m_axi_wstrb),
    .m_axi_wvalid                   (m_axi_wvalid),
    .m_axi_wlast                    (m_axi_wlast),
    .m_axi_wready                   (m_axi_wready),
    .m_axi_arburst                  (m_axi_arburst),
    .m_axi_arlen                    (m_axi_arlen),
    .m_axi_araddr                   (m_axi_araddr),
    .m_axi_arsize                   (m_axi_arsize),
    .m_axi_arvalid                  (m_axi_arvalid),
    .m_axi_arid                     (m_axi_arid),
    .m_axi_aruser                   (m_axi_aruser),
    .m_axi_arready                  (m_axi_arready),
    .m_axi_rready                   (m_axi_rready),
    .m_axi_rdata                    (m_axi_rdata),
    .m_axi_rresp                    (m_axi_rresp),
    .m_axi_rvalid                   (m_axi_rvalid),
    .m_axi_rlast                    (m_axi_rlast),
    .m_axi_aclk                     (m_axi_aclk),
    .m_axi_aresetn                  (m_axi_aresetn),
    
    .dram_read_addr                 (dram_read_addr),
    .dram_read_len                  (dram_read_len),
    .dram_read_en                   (dram_read_en),
    .dram_read_data                 (dram_read_data),
    .dram_read_data_valid           (dram_read_data_valid),
    .dram_read_busy                 (dram_read_busy),
    
    .dram_write_addr                (dram_write_addr),
    .dram_write_len                 (dram_write_len),
    .dram_write_en                  (dram_write_en),
    .dram_write_data                (dram_write_data),
    .dram_write_busy                (dram_write_busy)
);

BufferGearBox #(
    .DRAM_ADDR_LEN                  (DRAM_ADDR_LEN),
    .DRAM_ADDR_BASE                 (DRAM_ADDR_BASE),
    .DRAM_DATA_SIZE                 (DRAM_DATA_SIZE),
    .BUFFER_SIZE                    (BUFFER_SIZE),
    .INPUT_DATA_SIZE                (INPUT_DATA_SIZE),
    .INPUT_NUM                      (INPUT_NUM),
    .INPUT_NUM_WIDTH                (INPUT_NUM_WIDTH)
) buffer_gearbox_inst (
    .reset                          (~m_axi_aresetn),
    .clink_X_clk                    (m_axi_aclk),
    .d0                             (d0),
    .d1                             (d1),
    .d2                             (d2),
    .fval                           (fval),
    .dval                           (dval),
    .lval                           (lval),
    .async_fifo_out                 (dram_write_data),
    .dram_write_addr                (dram_write_addr),
    .dram_write_en                  (dram_write_en),
    .dram_write_busy                (dram_write_busy)
);
endmodule