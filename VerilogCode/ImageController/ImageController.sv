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
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH                = 6,
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_STROBE_WIDTH              = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                = 4, // LOG(AXI_STROBE_WDITH)
    parameter FIFO_DEPTH                    = 130000
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Address Write
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
    // AXI4 Slave Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_bready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    output wire [15:0] s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_DATA_WIDTH - 1:0] s_axi_wdata,
    input  wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input  wire s_axi_wvalid,
    input  wire s_axi_wlast,
    output wire s_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Slave Address Read
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
    // AXI4 Slave Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_rready,
    output wire [AXI_DATA_WIDTH - 1:0] s_axi_rdata,
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
    output wire [AXI_ADDR_WIDTH - 1:0] m_axi_awaddr,
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
    output wire [AXI_DATA_WIDTH - 1:0] m_axi_wdata,
    output wire [AXI_STROBE_WIDTH - 1:0] m_axi_wstrb,
    output wire m_axi_wvalid,
    output wire m_axi_wlast,
    input  wire m_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Read
    //////////////////////////////////////////////////////////////////////////////////
    output wire [1:0] m_axi_arburst,
    output wire [7:0] m_axi_arlen,
    output wire [AXI_ADDR_WIDTH - 1:0] m_axi_araddr,
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
    output wire [23:0] rgb
);


//////////////////////////////////////////////////////////////////////////////////
// RTO_Core interface
//////////////////////////////////////////////////////////////////////////////////
wire image_sender_reset;
wire image_sender_flush;
wire image_sender_write;
wire [127:0] image_sender_fifo_din;

wire image_sender_full;
wire image_sender_empty;

//////////////////////////////////////////////////////////////////////////////////
// RTI_Core interface
//////////////////////////////////////////////////////////////////////////////////
wire data_receiver_reset;
wire data_receiver_rd_en;
wire data_receiver_flush;

wire [127:0] data_receiver_fifo_dout;
wire data_receiver_full;
wire data_receiver_empty;
wire [FIFO_DEPTH - 1:0] data_num;

//////////////////////////////////////////////////////////////////////////////////
// AXI2FIFO Declaration
//////////////////////////////////////////////////////////////////////////////////

AXI2FIFO
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    .AXI_ADDR_WIDTH                 (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH                 (AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH               (AXI_STROBE_WIDTH ),
    .AXI_STROBE_LEN                 (AXI_STROBE_LEN)
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
    .data_num                       (data_num)
);

//////////////////////////////////////////////////////////////////////////////////
// ImageSender interface
//////////////////////////////////////////////////////////////////////////////////
wire require_new_image;

assign data_receiver_empty = 1'b1;
assign data_receiver_full = 1'b0;
assign data_receiver_fifo_dout = 128'h0;

ImageSender #(
    .BIT_WIDTH                      (BIT_WIDTH),
    .BIT_HEIGHT                     (BIT_HEIGHT),
    .FIFO_DEPTH                     (FIFO_DEPTH),
    .IMAGE_WIDTH                    (IMAGE_WIDTH),
    .IMAGE_HEIGHT                   (IMAGE_HEIGHT)
) ImageSender_0 (
    .image_sender_reset             (image_sender_reset | ~s_axi_aresetn),
    .image_sender_flush             (image_sender_flush),
    .image_sender_write             (image_sender_write),
    .image_sender_fifo_din          (image_sender_fifo_din),
    .image_sender_full              (image_sender_full),
    .image_sender_empty             (image_sender_empty),
    .clk_pixel                      (s_axi_aclk),
    .auto_start                     (auto_start),
    .cx                             (cx),
    .cy                             (cy),
    .rgb                            (rgb),
    .require_new_image              (require_new_image)
);

endmodule