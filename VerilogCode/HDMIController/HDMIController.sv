`timescale 1ns / 1ps
// DVI Output maker

module HDMIController 
#(
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    parameter int START_X                   = 0,
    parameter int START_Y                   = 0
)
(
    input  wire clk_pixel,
    input  wire clk_pixel_resetn,
    input  wire [23:0] rgb,

    output wire [9:0] tmds0_10bit,
    output wire [9:0] tmds1_10bit,
    output wire [9:0] tmds2_10bit,
    
    output reg [BIT_WIDTH-1:0]  cx,
    output reg [BIT_HEIGHT-1:0] cy
);

localparam FRAME_WIDTH                      = 1376;
localparam FRAME_HEIGHT                     = 810;
localparam SCREEN_WIDTH                     = 1024;
localparam SCREEN_HEIGHT                    = 768;
localparam HSYNC_PULSE_START                = 48;
localparam HSYNC_PULSE_SIZE                 = 48;
localparam VSYNC_PULSE_START                = 4;
localparam VSYNC_PULSE_SIZE                 = 3;
localparam INVERT                           = 0;

reg  [7:0] r_8bit;
reg  [7:0] g_8bit;
reg  [7:0] b_8bit;
wire de;
wire hsync;
wire vsync;

assign hsync = INVERT ^ (cx >= SCREEN_WIDTH + HSYNC_PULSE_START && cx < SCREEN_WIDTH + HSYNC_PULSE_START + HSYNC_PULSE_SIZE);
assign vsync = INVERT ^ (cy >= SCREEN_HEIGHT + VSYNC_PULSE_START && cy < SCREEN_HEIGHT + VSYNC_PULSE_START + VSYNC_PULSE_SIZE);
assign de = ((cx < SCREEN_WIDTH && 0 <= cx) && 
             (cy < SCREEN_HEIGHT && 0 <= cy));

always_ff @(posedge clk_pixel) begin
    if (~clk_pixel_resetn) begin
        cx <= BIT_WIDTH'(START_X);
        cy <= BIT_HEIGHT'(START_Y);
    end
    else begin
        cx <= (cx == FRAME_WIDTH-1) ? BIT_WIDTH'(0) : cx + 1;
        cy <= (cx == FRAME_WIDTH-1) ? (cy == FRAME_HEIGHT-1) ? BIT_HEIGHT'(0) : cy + 1 : cy;
    end
end

always_ff @(posedge clk_pixel) begin
    if (~clk_pixel_resetn) begin
        r_8bit <= 8'h0;
        g_8bit <= 8'h0;
        b_8bit <= 8'h0;
    end
    else begin
        r_8bit <= rgb[23:16];
        g_8bit <= rgb[15:8];
        b_8bit <= rgb[7:0];
    end
end

tmds_encoder_dvi tmds_inst_0(
    .clk_pixel                              (clk_pixel),
    .reset                                  (~clk_pixel_resetn),
    .data_8bit                              (r_8bit),
    .ctl                                    ({vsync, hsync}),
    .de                                     (de),
    .tmds                                   (tmds0_10bit)
);

tmds_encoder_dvi tmds_inst_1(
    .clk_pixel                              (clk_pixel),
    .reset                                  (~clk_pixel_resetn),
    .data_8bit                              (g_8bit),
    .ctl                                    (2'b0),
    .de                                     (de),
    .tmds                                   (tmds1_10bit)
);

tmds_encoder_dvi tmds_inst_2(
    .clk_pixel                              (clk_pixel),
    .reset                                  (~clk_pixel_resetn),
    .data_8bit                              (b_8bit),
    .ctl                                    (2'b0),
    .de                                     (de),
    .tmds                                   (tmds2_10bit)
);


endmodule
