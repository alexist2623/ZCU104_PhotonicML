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
    parameter LINES         = 3
)
(
    input  wire        s_axi_aclk,          // System clock
    input  wire        s_axi_aresetn,       // Active low reset
    input  wire        clink_clk_p,         // Camera Link clock positive
    input  wire        clink_clk_n,         // Camera Link clock negative
    input  wire        fval,                // Frame valid
    input  wire        lval,                // Line valid
    input  wire        dval,                // Data valid
    input  wire [2:0]  clink_data_X_p,      // Camera Link data X channels positive
    input  wire [2:0]  clink_data_X_n,      // Camera Link data X channels negative
    output wire        clink_ready,         // Indicates when pixel data is valid
    output wire [7 * LINES - 1:0] pixel_X,
    output wire        clink_rx_clk,

    input  wire       tx_start,             // Start transmission signal
    input  wire [7:0] tx_data,              // Data to be transmitted
    output wire       tx_busy,              // Transmission in progress
    output wire       tx_serial,            // UART transmit serial output
    input  wire       rx_serial,            // UART receive serial input
    output wire       rx_ready,             // Data received and ready
    output wire [7:0] rx_data               // Data received

    output wire        uart_tx,             // UART transmit pin
    input  wire        uart_rx              // UART receive pin (for future expansion)
);

rx_channel_1to7 # (
   .LINES                   (3),            // Number of data lines 
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
   .clkin_p                 (clink_clk_p),      // Clock input LVDS P-side
   .clkin_n                 (clink_clk_n),      // Clock input LVDS N-side
   .datain_p                (clink_data_X_p),   // Data input LVDS P-side
   .datain_n                (clink_data_X_n),   // Data input LVDS N-side
   .reset                   (~s_axi_aresetn),   // Asynchronous interface reset
   .idelay_rdy              (),                 // Asynchronous IDELAYCTRL ready 
   .cmt_locked              (),                 // PLL/MMCM locked output
   //
   .px_clk                  (clink_rx_clk),     // Pixel clock output
   .px_data                 (pixel_X),          // Pixel data bus output
   .px_ready                (clink_ready)       // Pixel data ready
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
    .rx_data                (uart_rx)           // Data received
);


endmodule