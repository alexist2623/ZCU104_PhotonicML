`timescale 1ns / 1ps

module ImageReader_tb;

localparam AXI_ADDR_WIDTH            = 6;
localparam AXI_DATA_WIDTH            = 128;
localparam AXI_STROBE_WIDTH          = AXI_DATA_WIDTH >> 3;
localparam AXI_STROBE_LEN            = $clog2(AXI_STROBE_WIDTH);
localparam DEST_VAL                  = 16'h0;
localparam CHANNEL_LENGTH            = 12;
localparam AXIS_DATA_WIDTH           = 256;
localparam LINES                     = 4;

localparam AXI_WRITE_FIFO            = AXI_ADDR_WIDTH'(0);
localparam AXI_FLUSH_FIFO            = AXI_ADDR_WIDTH'(0) + 6'h10;

reg  s_axi_aclk;
reg clink_X_clk_p;         // Camera Link clock positive
reg clink_X_clk_n;         // Camera Link clock negative
reg clink_X_data_0_p;      // Camera Link data X channels positive
reg clink_X_data_0_n;      // Camera Link data X channels negative
reg clink_X_data_1_p;      // Camera Link data X channels positive
reg clink_X_data_1_n;      // Camera Link data X channels negative
reg clink_X_data_2_p;      // Camera Link data X channels positive
reg clink_X_data_2_n;      // Camera Link data X channels negative
reg clink_X_data_3_p;      // Camera Link data X channels positive
reg clink_X_data_3_n;      // Camera Link data X channels negative
wire        clink_X_ready;         // Indicates when pixel data is valid
wire [7 * LINES - 1:0] pixel_X;
wire        clink_X_clk;

    //////////////////////////////////////////////////////////////////////////////////
    // Cameralink UART Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
wire        tx_serial;            // UART transmit serial output
reg rx_serial;            // UART receive serial input

axi_if #(
    .AXI_ADDR_WIDTH                 (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH                 (AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH               (AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN                 (AXI_STROBE_LEN)
)axi_if_inst(
    .s_axi_aclk                     (s_axi_aclk)
);

// Instantiate the Unit Under Test (UUT)
ImageReader_UUT #(
) uut
(
    .axi_if_inst                    (axi_if_inst),
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

// Clock Generation
initial begin
    s_axi_aclk = 0;
    forever #4 s_axi_aclk = ~s_axi_aclk;
end

initial begin
    clink_X_clk_p = 0;
    clink_X_clk_n = 1;
    forever begin
        #6.097 clink_X_clk_p = ~clink_X_clk_p;
        clink_X_clk_n = ~clink_X_clk_n;
    end
end

reg clk_x7;
initial begin
    clk_x7 = 0;
    forever begin
        #0.871 clk_x7 = ~clk_x7;
    end
end
reg [23:0] random_data;
always @(posedge clk_x7) begin
    random_data = $urandom;
    clink_X_data_0_p <= random_data[0];
    clink_X_data_0_n <= ~random_data[0];
    clink_X_data_1_p <= random_data[1];
    clink_X_data_1_n <= ~random_data[1];
    clink_X_data_2_p <= random_data[2];
    clink_X_data_2_n <= ~random_data[2];
end
/*
 * Cameralink Write
 */
initial begin
    clink_X_data_3_p <= 7'h00;
    clink_X_data_3_n <= 7'h7f;
    #10000;
    @(posedge clink_X_clk_p ) begin
        clink_X_data_3_p <= ~clink_X_data_3_p;
        clink_X_data_3_n <= ~clink_X_data_3_n;
    end
    #1000000;
    $finish;
end

initial begin
    axi_if_inst.init();
    #1000;
    axi_if_inst.write(AXI_ADDR_WIDTH'(6'h0), 8'b11001010);
end
endmodule
