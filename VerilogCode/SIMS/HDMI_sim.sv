`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 01:09:34
// Design Name: 
// Module Name: HDMI_sim
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


module HDMI_sim;

localparam VIDEO_ID_CODE = 16;
localparam IT_CONTENT = 1'b1;
localparam DVI_OUTPUT = 1'b0;
localparam VIDEO_REFRESH_RATE = 60;
localparam VENDOR_NAME = 64'h556E6B6E6F776E00; // "Unknown"
localparam PRODUCT_DESCRIPTION = 128'h46504741000000000000000000000000; // "FPGA"
localparam SOURCE_DEVICE_INFORMATION = 8'h00;
localparam START_X = 0;
localparam START_Y = 0;

// Calculate BIT_WIDTH and BIT_HEIGHT based on VIDEO_ID_CODE
localparam BIT_WIDTH  = 12;
localparam BIT_HEIGHT = 11;

// Testbench Signals
reg clk_pixel;
reg resetn;
reg [23:0] rgb;

wire [9:0] tmds0_10bit;
wire [9:0] tmds1_10bit;
wire [9:0] tmds2_10bit;

wire [BIT_WIDTH-1:0] cx;
wire [BIT_HEIGHT-1:0] cy;

wire [BIT_WIDTH-1:0] frame_width;
wire [BIT_HEIGHT-1:0] frame_height;
wire [BIT_WIDTH-1:0] screen_width;
wire [BIT_HEIGHT-1:0] screen_height;

// Instantiate the HDMIController module
HDMIController #(
    .VIDEO_ID_CODE(VIDEO_ID_CODE),
    .IT_CONTENT(IT_CONTENT),
    .DVI_OUTPUT(DVI_OUTPUT),
    .VIDEO_REFRESH_RATE(VIDEO_REFRESH_RATE),
    .VENDOR_NAME(VENDOR_NAME),
    .PRODUCT_DESCRIPTION(PRODUCT_DESCRIPTION),
    .SOURCE_DEVICE_INFORMATION(SOURCE_DEVICE_INFORMATION),
    .START_X(START_X),
    .START_Y(START_Y),
    .BIT_WIDTH(BIT_WIDTH),
    .BIT_HEIGHT(BIT_HEIGHT)
) uut (
    .clk_pixel(clk_pixel),
    .resetn(resetn),
    .rgb(rgb),
    .tmds0_10bit(tmds0_10bit),
    .tmds1_10bit(tmds1_10bit),
    .tmds2_10bit(tmds2_10bit),
    .cx(cx),
    .cy(cy),
    .frame_width(frame_width),
    .frame_height(frame_height),
    .screen_width(screen_width),
    .screen_height(screen_height)
);

// Clock Generation for clk_pixel
initial begin
    clk_pixel = 0;
    forever #4 clk_pixel = ~clk_pixel; // Generate a 125MHz clock (assuming clk_pixel is 125MHz for 1920x1080 resolution)
end

// Reset Generation
initial begin
    resetn = 0;
    #100; // Hold reset for 100ns
    resetn = 1; // Release reset
end

// RGB Pattern Generation
initial begin
    rgb = 24'hFFFFFF; // Start with white
    #200; // Wait for 200ns
    rgb = 24'hFF0000; // Change to red
    #200; // Wait for 200ns
    rgb = 24'h00FF00; // Change to green
    #200; // Wait for 200ns
    rgb = 24'h0000FF; // Change to blue
    // Continue with more patterns or a loop if desired
end


endmodule
