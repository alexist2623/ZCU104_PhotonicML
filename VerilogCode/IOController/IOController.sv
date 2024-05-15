module IOController
#(
    //////////////////////////////////////////////////////////////////////////////////
    // SignalShifter Interface
    //////////////////////////////////////////////////////////////////////////////////
    parameter MAX_DELAY                     = 1000000000,
    parameter MAX_EVENT                     = 1000,
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH                = 6,
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_STROBE_WIDTH              = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                = 4 // LOG(AXI_STROBE_WDITH)
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
    // SignalShifter Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire auto_start,
    input  wire input_signal,
    output wire output_signal
);

localparam DELAY_WIDTH                      = $clog2(MAX_DELAY);
localparam EVENT_WIDTH                      = $clog2(MAX_EVENT);

wire reset;
wire [DELAY_WIDTH-1:0] delay_value;
wire delay_set;
wire [EVENT_WIDTH-1:0] event_value;
wire event_set;
wire event_polarity_set;

AXI2IOControllerCOM #(
    .AXI_ADDR_WIDTH                         (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH                         (AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH                       (AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN                         (AXI_STROBE_LEN),
    .MAX_DELAY                              (MAX_DELAY),
    .MAX_EVENT                              (MAX_EVENT),
    .DELAY_WIDTH                            (DELAY_WIDTH),
    .EVENT_WIDTH                            (EVENT_WIDTH)
) axi2iocontrollercom_0 (
    .s_axi_awaddr                           (s_axi_awaddr),
    .s_axi_awid                             (s_axi_awid),
    .s_axi_awburst                          (s_axi_awburst),
    .s_axi_awsize                           (s_axi_awsize),
    .s_axi_awlen                            (s_axi_awlen),
    .s_axi_awvalid                          (s_axi_awvalid),
    .s_axi_awuser                           (s_axi_awuser),
    .s_axi_awready                          (s_axi_awready),
    
    .s_axi_bready                           (s_axi_bready),
    .s_axi_bresp                            (s_axi_bresp),
    .s_axi_bvalid                           (s_axi_bvalid),
    .s_axi_bid                              (s_axi_bid),
    
    .s_axi_wdata                            (s_axi_wdata),
    .s_axi_wstrb                            (s_axi_wstrb),
    .s_axi_wvalid                           (s_axi_wvalid),
    .s_axi_wlast                            (s_axi_wlast),
    .s_axi_wready                           (s_axi_wready),
    
    .s_axi_arburst                          (s_axi_arburst),
    .s_axi_arlen                            (s_axi_arlen),
    .s_axi_araddr                           (s_axi_araddr),
    .s_axi_arsize                           (s_axi_arsize),
    .s_axi_arvalid                          (s_axi_arvalid),
    .s_axi_arid                             (s_axi_arid),
    .s_axi_aruser                           (s_axi_aruser),
    .s_axi_arready                          (s_axi_arready),
    .s_axi_rid                              (s_axi_rid),
    
    .s_axi_rready                           (s_axi_rready),
    .s_axi_rdata                            (s_axi_rdata),
    .s_axi_rresp                            (s_axi_rresp),
    .s_axi_rvalid                           (s_axi_rvalid),
    .s_axi_rlast                            (s_axi_rlast),
    
    .s_axi_aclk                             (s_axi_aclk),
    .s_axi_aresetn                          (s_axi_aresetn),
    
    .reset                                  (reset),
    .delay_value                            (delay_value),
    .delay_set                              (delay_set),
    .event_value                            (event_value),
    .event_set                              (event_set),
    .event_polarity_set                     (event_polarity_set)
);

SignalShifter #(
    .MAX_DELAY                              (MAX_DELAY),
    .MAX_EVENT                              (MAX_EVENT),
    .DELAY_WIDTH                            (DELAY_WIDTH),
    .EVENT_WIDTH                            (EVENT_WIDTH)
) signal_shifter_0 (
    .auto_start                             (auto_start),
    .clk                                    (s_axi_aclk),
    .reset                                  (reset),
    .delay_value                            (delay_value),
    .delay_set                              (delay_set),
    .event_value                            (event_value),
    .event_set                              (event_set),
    .event_polarity_set                     (event_polarity_set),
    .input_signal                           (input_signal),
    .output_signal                          (output_signal)
);

endmodule