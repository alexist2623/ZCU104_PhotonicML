`timescale 1ns / 1ps

module ImageController
#(
    //////////////////////////////////////////////////////////////////////////////////
    // ImageSender Interface
    //////////////////////////////////////////////////////////////////////////////////
    parameter TEST_MODE                     = 1'b1,
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH                = 6,
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_STROBE_WIDTH              = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                = 4, // LOG(AXI_STROBE_WDITH)
    parameter FIFO_DEPTH                    = 9
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
    input wire [15:0] s_axi_awid, 
    input wire [1:0] s_axi_awburst,
    input wire [2:0] s_axi_awsize,
    input wire [7:0] s_axi_awlen,
    input wire s_axi_awvalid,
    input wire [15:0] s_axi_awuser, // added to resolve wrapping error
    output wire s_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_bready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    output wire [15:0] s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input wire [AXI_DATA_WIDTH - 1:0] s_axi_wdata,
    input wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    input wire s_axi_wlast,
    output wire s_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    input wire [1:0] s_axi_arburst,
    input wire [7:0] s_axi_arlen,
    input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr,
    input wire [2:0] s_axi_arsize,
    input wire s_axi_arvalid,
    input wire [15:0] s_axi_arid, // added to resolve wrapping error
    input wire [15:0] s_axi_aruser, // added to resolve wrapping error
    output wire s_axi_arready,
    output wire [15:0] s_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_rready,
    output wire [AXI_DATA_WIDTH - 1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    output wire s_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_aresetn,
    
    //////////////////////////////////////////////////////////////////////////////////  
    // TimeController interface
    //////////////////////////////////////////////////////////////////////////////////
    input wire auto_start,
    input wire [63:0] counter,
    
    //////////////////////////////////////////////////////////////////////////////////  
    // ImageSender interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire rtio_clk,
    input  wire [BIT_WIDTH-1:0] cx,
    input  wire [BIT_HEIGHT-1:0] cy,
    input  wire [BIT_WIDTH-1:0] frame_width,
    input  wire [BIT_HEIGHT-1:0] frame_height,
    input  wire [BIT_WIDTH-1:0] screen_width,
    input  wire [BIT_HEIGHT-1:0] screen_height,
    output wire [23:0] rgb
);


//////////////////////////////////////////////////////////////////////////////////
// RTO_Core interface
//////////////////////////////////////////////////////////////////////////////////
wire rto_core_reset;                      // pixel_clk region
wire rto_core_flush;                      // pixel_clk region
wire rto_core_write;                     // pixel_clk region
wire [127:0] rto_core_fifo_din;          // pixel_clk region

wire rto_core_full;                       // pixel_clk region
wire rto_core_empty;                      // pixel_clk region

//////////////////////////////////////////////////////////////////////////////////
// RTI_Core interface
//////////////////////////////////////////////////////////////////////////////////
wire rti_core_reset;
wire rti_core_rd_en;
wire rti_core_flush;

wire [127:0] rti_core_fifo_dout;
wire rti_core_full;
wire rti_core_empty;
wire [FIFO_DEPTH - 1:0] data_num;

//////////////////////////////////////////////////////////////////////////////////
// AXI2FIFO Declaration
//////////////////////////////////////////////////////////////////////////////////

AXI2FIFO
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH(AXI_STROBE_WIDTH ),
    .AXI_STROBE_LEN(AXI_STROBE_LEN)
)
axi2fifo_0
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awid(s_axi_awid),
    .s_axi_awburst(s_axi_awburst),
    .s_axi_awsize(s_axi_awsize),
    .s_axi_awlen(s_axi_awlen),
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
    // RTO_Core interface
    //////////////////////////////////////////////////////////////////////////////////
    .rto_core_reset(rto_core_reset),
    .rto_core_flush(rto_core_flush),
    .rto_core_write(rto_core_write),
    .rto_core_fifo_din(rto_core_fifo_din),
    
    .rto_core_full(rto_core_full),
    .rto_core_empty(rto_core_empty),
    .rtio_clk(rtio_clk)
);

ImageSender #(
    .TEST_MODE(TEST_MODE),  // Example: Overriding the default parameter with 1'b0 for non-test mode
    .BIT_WIDTH(BIT_WIDTH),
    .BIT_HEIGHT(BIT_HEIGHT),
    .FIFO_DEPTH(FIFO_DEPTH)
) imageSenderInstance (
    .rto_core_reset(rto_core_reset),
    .rto_core_flush(rto_core_flush),
    .rto_core_write(rto_core_write),
    .rto_core_fifo_din(rto_core_fifo_din),
    .rto_core_full(rto_core_full),
    .rto_core_empty(rto_core_empty),
    .rti_core_reset(rti_core_reset),
    .rti_core_rd_en(rti_core_rd_en),
    .rti_core_flush(rti_core_flush),
    .rti_core_fifo_dout(rti_core_fifo_dout),
    .rti_core_full(rti_core_full),
    .rti_core_empty(rti_core_empty),
    .data_num(data_num),
    .rtio_clk(rtio_clk),
    .cx(cx),
    .cy(cy),
    .frame_width(frame_width),
    .frame_height(frame_height),
    .screen_width(screen_width),
    .screen_height(screen_height),
    .rgb(rgb)
);

endmodule