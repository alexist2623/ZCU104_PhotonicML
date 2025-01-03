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
// Description: ImageReader module with camerlink X3-1Y 8 Bit pixel depth.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CameraLinkInterface
#(
    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter LINES                     = 4,
    parameter IMAGE_NUM_WIDTH           = 8,
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH            = 7,
    parameter AXI_DATA_WIDTH            = 128,
    parameter AXI_STROBE_WIDTH          = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN            = 4 // LOG(AXI_STROBE_WDITH)
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_ADDR_WIDTH - 1:0]  s_axi_awaddr,
    input  wire [15:0]                  s_axi_awid, 
    input  wire [1:0]                   s_axi_awburst,
    input  wire [2:0]                   s_axi_awsize,
    input  wire [7:0]                   s_axi_awlen,
    input  wire                         s_axi_awvalid,
    input  wire [15:0]                  s_axi_awuser, // added to resolve wrapping error
    output wire                         s_axi_awready, // Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input  wire                         s_axi_bready,
    output wire [1:0]                   s_axi_bresp,
    output wire                         s_axi_bvalid,
    output wire [15:0]                  s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_DATA_WIDTH - 1:0]  s_axi_wdata,
    input  wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input  wire                         s_axi_wvalid,
    input  wire                         s_axi_wlast,
    output wire                         s_axi_wready, // Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [1:0]                   s_axi_arburst,
    input  wire [7:0]                   s_axi_arlen,
    input  wire [AXI_ADDR_WIDTH - 1:0]  s_axi_araddr,
    input  wire [2:0]                   s_axi_arsize,
    input  wire                         s_axi_arvalid,
    input  wire [15:0]                  s_axi_arid, // added to resolve wrapping error
    input  wire [15:0]                  s_axi_aruser, // added to resolve wrapping error
    output wire                         s_axi_arready,
    output wire [15:0]                  s_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire                         s_axi_rready,
    output wire [AXI_DATA_WIDTH - 1:0]  s_axi_rdata,
    output wire [1:0]                   s_axi_rresp,
    output wire                         s_axi_rvalid,
    output wire                         s_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    input  wire        s_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire        s_axi_aresetn,
    
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

    output wire [7:0]  d0,
    output wire [7:0]  d1,
    output wire [7:0]  d2,
    output wire        lval,
    output wire        fval,
    output wire        dval,
    output wire        clink_X_ready,         // Indicates when pixel data is valid
    output wire        clink_X_clk_out,


    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink CC1-4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    output wire        cc1,
    output wire        cc2,
    output wire        cc3,
    output wire        cc4,
    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink UART Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    output wire        SerTC,            // UART transmit serial output
    input  wire        SerTFG,            // UART receive serial input
    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink Trigger and Image end
    //////////////////////////////////////////////////////////////////////////////////
    // input  wire        trigger, // will be used after Clink is tested
    output wire        image_end,

    output wire        clk_blink_0,
    output reg         clk_blink_1,
    //
    // Reset Sequence
    // dram_reset -> clink_reset
    //
    output wire        clink_resetn,
    output wire        dram_resetn,
    input  wire        clk_300mhz,
    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink Trigger and Image end
    //////////////////////////////////////////////////////////////////////////////////
    input wire         auto_start,  // Master Enable
    input wire [IMAGE_NUM_WIDTH-1:0] captured_image_num
);

// AXI2UART instance for handling AXI communication and UART interface
wire            rx_ready;               // data received and ready
wire [7:0]      rx_data;                // data received
wire            tx_start;               // Start transmission signal
wire [7:0]      tx_data;                // data to be transmitted
wire            tx_busy;                // Transmission in progress

// Wire for CameraLink interface
wire [27:0]     clink_rx_out;
wire [27:0]     pixel_X;

wire            idly_reset_int;
wire            rx_idelay_rdy;
wire            rx_reset_int;
wire            rx_cmt_locked;
wire            px_ready;

assign clink_X_ready        = px_ready;
assign clk_blink_0          = px_ready;
// 7:1 deserialized data to rx_out
assign clink_rx_out[0]      = pixel_X[6];
assign clink_rx_out[1]      = pixel_X[5];
assign clink_rx_out[2]      = pixel_X[4];
assign clink_rx_out[3]      = pixel_X[3];
assign clink_rx_out[4]      = pixel_X[2];
assign clink_rx_out[5]      = pixel_X[26];
assign clink_rx_out[6]      = pixel_X[1];
assign clink_rx_out[7]      = pixel_X[0];
assign clink_rx_out[8]      = pixel_X[13];
assign clink_rx_out[9]      = pixel_X[12];
assign clink_rx_out[10]     = pixel_X[25];
assign clink_rx_out[11]     = pixel_X[24];
assign clink_rx_out[12]     = pixel_X[11];
assign clink_rx_out[13]     = pixel_X[10];
assign clink_rx_out[14]     = pixel_X[9];
assign clink_rx_out[15]     = pixel_X[8];
assign clink_rx_out[16]     = pixel_X[23];
assign clink_rx_out[17]     = pixel_X[22];
assign clink_rx_out[18]     = pixel_X[7];
assign clink_rx_out[19]     = pixel_X[20];
assign clink_rx_out[20]     = pixel_X[19];
assign clink_rx_out[21]     = pixel_X[18];
assign clink_rx_out[22]     = pixel_X[17];
assign clink_rx_out[23]     = pixel_X[21];
assign clink_rx_out[24]     = pixel_X[16];
assign clink_rx_out[25]     = pixel_X[15];
assign clink_rx_out[26]     = pixel_X[14];
assign clink_rx_out[27]     = pixel_X[27];

// clink_rx_out data to actual cameralink data
assign d0[0]                = clink_rx_out[0]; // A0
assign d0[1]                = clink_rx_out[1]; // A1
assign d0[2]                = clink_rx_out[2]; // A2
assign d0[3]                = clink_rx_out[3]; // A3
assign d0[4]                = clink_rx_out[4]; // A4
assign d0[5]                = clink_rx_out[6]; // A5
assign d0[6]                = clink_rx_out[27];// A6
assign d0[7]                = clink_rx_out[5]; // A7

assign d1[0]                = clink_rx_out[7];
assign d1[1]                = clink_rx_out[8];
assign d1[2]                = clink_rx_out[9];
assign d1[3]                = clink_rx_out[12];
assign d1[4]                = clink_rx_out[13];
assign d1[5]                = clink_rx_out[14];
assign d1[6]                = clink_rx_out[10];
assign d1[7]                = clink_rx_out[11];

assign d2[0]                = clink_rx_out[15];
assign d2[1]                = clink_rx_out[18];
assign d2[2]                = clink_rx_out[19];
assign d2[3]                = clink_rx_out[20];
assign d2[4]                = clink_rx_out[21];
assign d2[5]                = clink_rx_out[22];
assign d2[6]                = clink_rx_out[16];
assign d2[7]                = clink_rx_out[17];

assign lval                 = clink_rx_out[24];
assign fval                 = clink_rx_out[25];
assign dval                 = clink_rx_out[26];

reg clink_reset_buffer1, clink_reset_buffer2;
reg auto_start_buffer1, auto_start_buffer2;

always @(posedge clink_X_clk_out) begin
    {clink_reset_buffer2, clink_reset_buffer1} <= {clink_reset_buffer1, ~s_axi_aresetn};
    {auto_start_buffer2, auto_start_buffer1} <= {auto_start_buffer1, auto_start};
    if (clink_reset_buffer2 == 1'b1) begin
        clk_blink_1         <= 1'b0;
    end
    else begin
        if (lval == 1'b1 && auto_start_buffer2 == 1'b1) begin
            clk_blink_1     <= 1'b1;
        end
    end
end
//-------------------------------------------------------------------------------


// Receiver reset Logic
assign rx_reset_int         = ~s_axi_aresetn;
assign idly_reset_int       = (rx_reset_int | !rx_cmt_locked);

//  Idelay control block
IDELAYCTRL #(                                   // Instantiate input delay control block
    .SIM_DEVICE             ("ULTRASCALE")      //ULTRASCALE should be used for both ULTRASCALE and ULTRASCALE+ devices
)
icontrol (
    .REFCLK                 (clk_300mhz),
    .RST                    (idly_reset_int),
    .RDY                    (rx_idelay_rdy)
);

rx_channel_1to7 # (
   .LINES                   (LINES),            // Number of data lines 
   // Basler ace Cmeralink 82MHz 
   .CLKIN_PERIOD            (12.195),           // Clock period (ns) of input clock on clkin_p
   .REF_FREQ                (300.0),            // Reference clock frequency for idelay control
   .DIFF_TERM               ("TRUE"),           // Enable internal differential termination
   .USE_PLL                 ("FALSE"),          // Enable PLL use rather than MMCM use
   .DATA_FORMAT             ("PER_LINE"),       // Mapping input lines to output bus
   .CLK_PATTERN             (7'b1100011),       // Clock pattern for alignment
   .RX_SWAP_MASK            (16'b0),            // Allows P/N inputs to be invered to ease PCB routing
   .SIM_DEVICE              ("ULTRASCALE_PLUS") // Set for the family <ULTRASCALE | ULTRASCALE_PLUS>
)
clink_X_7to1 (
   .clkin_p                 (clink_X_clk_p),    // Clock input LVDS P-side
   .clkin_n                 (clink_X_clk_n),    // Clock input LVDS N-side
   .datain_p                ({clink_X_data_3_p,
                            clink_X_data_2_p,
                            clink_X_data_1_p,
                            clink_X_data_0_p}), // Data input LVDS P-side
   .datain_n                ({clink_X_data_3_n,
                            clink_X_data_2_n,
                            clink_X_data_1_n,
                            clink_X_data_0_n}), // Data input LVDS N-side
   .reset                   (rx_reset_int),     // Asynchronous interface reset
   .idelay_rdy              (rx_idelay_rdy),    // Asynchronous IDELAYCTRL ready 
   .cmt_locked              (rx_cmt_locked),    // PLL/MMCM locked output
   .px_clk                  (clink_X_clk_out),  // Pixel clock output
   .px_data                 (pixel_X),          // Pixel data bus output
   .px_ready                (px_ready)          // Pixel data ready
);

uart 
#(
    .CLK_FREQ               (125000000),
    .BAUD_RATE              (9600)
)    
uart_inst (
    .clk                    (s_axi_aclk),       // System clock
    .rst_n                  (s_axi_aresetn),    // Active low reset
    .tx_start               (tx_start),         // Start transmission signal
    .tx_data                (tx_data),          // Data to be transmitted
    .tx_busy                (tx_busy),          // Transmission in progress
    .tx_serial              (SerTC),            // UART transmit serial output
    .rx_serial              (SerTFG),           // UART receive serial input
    .rx_ready               (rx_ready),         // Data received and ready
    .rx_data                (rx_data)           // Data received
);

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
    .rx_data                (rx_data),
    .clink_ready            (clink_X_ready),
    .clink_resetn           (clink_resetn),
    .dram_resetn            (dram_resetn),

    .CC1                    (cc1),
    .CC2                    (cc2),
    .CC3                    (cc3),
    .CC4                    (cc4),

    .captured_image_num     (captured_image_num)
);

endmodule