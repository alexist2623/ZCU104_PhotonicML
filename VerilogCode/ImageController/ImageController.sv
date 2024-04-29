`timescale 1ns / 1ps

module ImageController
#(
    //////////////////////////////////////////////////////////////////////////////////
    // ImageSender Interface
    //////////////////////////////////////////////////////////////////////////////////
    parameter FRAME_WIDTH                   = 2200,
    parameter FRAME_HEIGHT                  = 1125,
    parameter SCREEN_WIDTH                  = 1920,
    parameter SCREEN_HEIGHT                 = 1080,
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    parameter IMAGE_WIDTH                   = 100,
    parameter IMAGE_HEIGHT                  = 100,
    //////////////////////////////////////////////////////////////////////////////////
    // DRAM Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter DRAM_DATA_WIDTH               = 512,
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter SAXI_ADDR_WIDTH               = 6,
    parameter MAXI_ADDR_WIDTH               = 39,
    parameter SAXI_DATA_WIDTH               = 128,
    parameter MAXI_DATA_WIDTH               = DRAM_DATA_WIDTH,
    parameter AXI_STROBE_WIDTH              = SAXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                = 4, // LOG(AXI_STROBE_WDITH)
    parameter FIFO_DEPTH                    = 512
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Address Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [SAXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
    input  wire [15:0] s_axi_awid, 
    input  wire [1:0] s_axi_awburst,
    input  wire [2:0] s_axi_awsize,
    input  wire [7:0] s_axi_awlen,
    input  wire s_axi_awvalid,
    input  wire [15:0] s_axi_awuser, // added to resolve wrapping error
    output wire s_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_bready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    output wire [15:0] s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [SAXI_DATA_WIDTH - 1:0] s_axi_wdata,
    input  wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input  wire s_axi_wvalid,
    input  wire s_axi_wlast,
    output wire s_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Address Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [1:0] s_axi_arburst,
    input  wire [7:0] s_axi_arlen,
    input  wire [SAXI_ADDR_WIDTH - 1:0] s_axi_araddr,
    input  wire [2:0] s_axi_arsize,
    input  wire s_axi_arvalid,
    input  wire [15:0] s_axi_arid, // added to resolve wrapping error
    input  wire [15:0] s_axi_aruser, // added to resolve wrapping error
    output wire s_axi_arready,
    output wire [15:0] s_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_rready,
    output wire [SAXI_DATA_WIDTH - 1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    output wire s_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Clock
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_aresetn,
    
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
    // TimeController interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire auto_start,
    input  wire [63:0] counter,
    
    //////////////////////////////////////////////////////////////////////////////////  
    // ImageSender interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [BIT_WIDTH-1:0] cx,
    input  wire [BIT_HEIGHT-1:0] cy,
    input  wire image_change,
    output wire [23:0] rgb
);


//////////////////////////////////////////////////////////////////////////////////
// Image Sender interface
//////////////////////////////////////////////////////////////////////////////////
wire image_sender_reset;
wire image_sender_flush;
wire image_sender_write;
wire [127:0] image_sender_fifo_din;
wire image_sender_full;
wire image_sender_empty;
wire [BIT_WIDTH-1:0] image_width;
wire [BIT_HEIGHT-1:0] image_height;

wire [MAXI_ADDR_WIDTH - 1:0] dram_read_addr;
wire [7:0] dram_read_len;
wire dram_read_en;

wire [MAXI_ADDR_WIDTH - 1:0] dram_write_addr;
wire [7:0] dram_write_len;
wire dram_write_en;
wire [SAXI_DATA_WIDTH - 1:0] dram_write_data;

wire [MAXI_DATA_WIDTH - 1:0] dram_read_data;
wire dram_read_data_valid;
wire dram_write_busy;
wire dram_read_busy;

//////////////////////////////////////////////////////////////////////////////////
// AXI2FIFO Declaration
//////////////////////////////////////////////////////////////////////////////////

AXI2FIFO
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    .AXI_ADDR_WIDTH                 (SAXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH                 (SAXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH               (AXI_STROBE_WIDTH ),
    .AXI_STROBE_LEN                 (AXI_STROBE_LEN),
    .BIT_WIDTH                      (BIT_WIDTH),
    .BIT_HEIGHT                     (BIT_HEIGHT)
)
axi2fifo_0
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_awaddr                   (s_axi_awaddr),
    .s_axi_awid                     (s_axi_awid),
    .s_axi_awburst                  (s_axi_awburst),
    .s_axi_awsize                   (s_axi_awsize),
    .s_axi_awlen                    (s_axi_awlen),
    .s_axi_awvalid                  (s_axi_awvalid),
    .s_axi_awuser                   (s_axi_awuser), // added to resolve wrapping error
    .s_axi_awready                  (s_axi_awready), //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_bready                   (s_axi_bready),
    .s_axi_bresp                    (s_axi_bresp),
    .s_axi_bvalid                   (s_axi_bvalid),
    .s_axi_bid                      (s_axi_bid), // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_wdata                    (s_axi_wdata),
    .s_axi_wstrb                    (s_axi_wstrb),
    .s_axi_wvalid                   (s_axi_wvalid),
    .s_axi_wlast                    (s_axi_wlast),
    .s_axi_wready                   (s_axi_wready),  //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_arburst                  (s_axi_arburst),
    .s_axi_arlen                    (s_axi_arlen),
    .s_axi_araddr                   (s_axi_araddr),
    .s_axi_arsize                   (s_axi_arsize),
    .s_axi_arvalid                  (s_axi_arvalid),
    .s_axi_arid                     (s_axi_arid), // added to resolve wrapping error
    .s_axi_aruser                   (s_axi_aruser), // added to resolve wrapping error
    .s_axi_arready                  (s_axi_arready),
    .s_axi_rid                      (s_axi_rid), // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_rready                   (s_axi_rready),
    .s_axi_rdata                    (s_axi_rdata),
    .s_axi_rresp                    (s_axi_rresp),
    .s_axi_rvalid                   (s_axi_rvalid),
    .s_axi_rlast                    (s_axi_rlast),
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_aclk                     (s_axi_aclk),
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_aresetn                  (s_axi_aresetn),
    
    //////////////////////////////////////////////////////////////////////////////////
    // ImageSender interface
    //////////////////////////////////////////////////////////////////////////////////
    .image_sender_reset             (image_sender_reset),
    .image_sender_flush             (image_sender_flush),
    .image_sender_write             (image_sender_write),
    .image_sender_fifo_din          (image_sender_fifo_din),
    
    .image_sender_full              (image_sender_full),
    .image_sender_empty             (image_sender_empty),
    .image_width                    (image_width),
    .image_height                   (image_height),
    .data_num                       (data_num)
);

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

//////////////////////////////////////////////////////////////////////////////////
// ImageSender interface
//////////////////////////////////////////////////////////////////////////////////
    
ImageSender #(
    .BIT_WIDTH                      (BIT_WIDTH),
    .BIT_HEIGHT                     (BIT_HEIGHT),
    .FIFO_DEPTH                     (FIFO_DEPTH),
    .AXI_DATA_WIDTH                 (SAXI_DATA_WIDTH),
    .DRAM_ADDR_WIDTH                (MAXI_ADDR_WIDTH)
) ImageSender_0 (
    .image_sender_reset             (image_sender_reset | ~s_axi_aresetn),
    .image_sender_flush             (image_sender_flush),
    .image_sender_write             (image_sender_write),
    .image_sender_fifo_din          (image_sender_fifo_din),
    .image_sender_full              (image_sender_full),
    .image_sender_empty             (image_sender_empty),
    .image_width                    (image_width),
    .image_height                   (image_height),
    .image_change                   (image_change),
    .clk_pixel                      (m_axi_aclk),
    .auto_start                     (auto_start),
    .cx                             (cx),
    .cy                             (cy),
    .rgb                            (rgb),
    
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

endmodule