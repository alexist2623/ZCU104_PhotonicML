`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 16:37:21
// Design Name: 
// Module Name: ImageReader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ImageReader module with camerlink
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ImageReader
#(
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
    // Cameralink X data Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    input  wire        clink_X_clk_p,         // Camera Link clock positive
    input  wire        clink_X_clk_n,         // Camera Link clock negative
    input  wire        fval,                // Frame valid
    input  wire        lval,                // Line valid
    input  wire        dval,                // Data valid
    input  wire [2:0]  clink_X_data_p,      // Camera Link data X channels positive
    input  wire [2:0]  clink_X_data_n,      // Camera Link data X channels negative
    output wire        clink_X_ready,         // Indicates when pixel data is valid
    output wire [7 * LINES - 1:0] pixel_X,
    output wire        clink_X_clk,

    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink UART Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    output wire        tx_serial,            // UART transmit serial output
    input  wire        rx_serial            // UART receive serial input
);

rx_channel_1to7 # (
   .LINES                   (LINES),            // Number of data lines 
   .CLKIN_PERIOD            (6.600),        // Clock period (ns) of input clock on clkin_p
   .REF_FREQ                (300.0),        // Reference clock frequency for idelay control
   .DIFF_TERM               ("TRUE"),       // Enable internal differential termination
   .USE_PLL                 ("FALSE"),      // Enable PLL use rather than MMCM use
   .DATA_FORMAT             ("PER_CLOCK"),  // Mapping input lines to output bus
   .CLK_PATTERN             (7'b1100011),   // Clock pattern for alignment
   .RX_SWAP_MASK            (16'b0),        // Allows P/N inputs to be invered to ease PCB routing
   .SIM_DEVICE              ("ULTRASCALE")  // Set for the family <ULTRASCALE | ULTRASCALE_PLUS>
)
clink_X_7to1
(
   .clkin_p                 (clink_X_clk_p),      // Clock input LVDS P-side
   .clkin_n                 (clink_X_clk_n),      // Clock input LVDS N-side
   .datain_p                (clink_X_data_p),   // Data input LVDS P-side
   .datain_n                (clink_X_data_n),   // Data input LVDS N-side
   .reset                   (~s_axi_aresetn),   // Asynchronous interface reset
   .idelay_rdy              (),                 // Asynchronous IDELAYCTRL ready 
   .cmt_locked              (),                 // PLL/MMCM locked output
   //
   .px_clk                  (clink_X_clk),     // Pixel clock output
   .px_data                 (pixel_X),          // Pixel data bus output
   .px_ready                (clink_X_ready)     // Pixel data ready
);

uart 
#(
    .CLK_FREQ               (125000000),
    .BAUD_RATE              (19200)
)    
uart_inst
(
    .clk                    (s_axi_aclk),       // System clock
    .rst_n                  (s_axi_aresetn),    // Active low reset
    .tx_start               (tx_start),         // Start transmission signal
    .tx_data                (tx_data),          // Data to be transmitted
    .tx_busy                (tx_busy),          // Transmission in progress
    .tx_serial              (tx_serial),        // UART transmit serial output
    .rx_serial              (rx_serial),        // UART receive serial input
    .rx_ready               (rx_ready),         // Data received and ready
    .rx_data                (rx_serial)           // Data received
);

// AXI2UART instance for handling AXI communication and UART interface
wire        rx_ready;             // Data received and ready
wire [7:0]  rx_data;               // Data received
wire        tx_start;             // Start transmission signal
wire [7:0]  tx_data;              // Data to be transmitted
wire        tx_busy;              // Transmission in progress
AXI2UART #(
    .AXI_ADDR_WIDTH         (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH         (AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH       (AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN         (AXI_STROBE_LEN)
)
axi2uart_inst (
    .s_axi_awaddr           (s_axi_awaddr),
    .s_axi_awid             (s_axi_awid),
    .s_axi_awburst          (s_axi_awburst),
    .s_axi_awsize           (s_axi_awsize),
    .s_axi_awlen            (s_axi_awlen),
    .s_axi_awvalid          (s_axi_awvalid),
    .s_axi_awuser           (s_axi_awuser),
    .s_axi_awready          (s_axi_awready),
    .s_axi_bready           (s_axi_bready),
    .s_axi_bresp            (s_axi_bresp),
    .s_axi_bvalid           (s_axi_bvalid),
    .s_axi_bid              (s_axi_bid),
    .s_axi_wdata            (s_axi_wdata),
    .s_axi_wstrb            (s_axi_wstrb),
    .s_axi_wvalid           (s_axi_wvalid),
    .s_axi_wlast            (s_axi_wlast),
    .s_axi_wready           (s_axi_wready),
    .s_axi_arburst          (s_axi_arburst),
    .s_axi_arlen            (s_axi_arlen),
    .s_axi_araddr           (s_axi_araddr),
    .s_axi_arsize           (s_axi_arsize),
    .s_axi_arvalid          (s_axi_arvalid),
    .s_axi_arid             (s_axi_arid),
    .s_axi_aruser           (s_axi_aruser),
    .s_axi_arready          (s_axi_arready),
    .s_axi_rid              (s_axi_rid),
    .s_axi_rready           (s_axi_rready),
    .s_axi_rdata            (s_axi_rdata),
    .s_axi_rresp            (s_axi_rresp),
    .s_axi_rvalid           (s_axi_rvalid),
    .s_axi_rlast            (s_axi_rlast),
    .s_axi_aclk             (s_axi_aclk),
    .s_axi_aresetn          (s_axi_aresetn),
    .tx_start               (tx_start),
    .tx_data                (tx_data),
    .tx_busy                (tx_busy),
    .rx_ready               (rx_ready),
    .rx_data                (rx_data)
);

endmodule