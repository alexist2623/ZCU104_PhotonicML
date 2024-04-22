`timescale 1ns / 1ps

module ImageSender
#(
    parameter FRAME_WIDTH                   = 2200,
    parameter FRAME_HEIGHT                  = 1125,
    parameter SCREEN_WIDTH                  = 1920,
    parameter SCREEN_HEIGHT                 = 1080,
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    parameter FIFO_DEPTH                    = 130000,
    parameter IMAGE_WIDTH                   = 100,
    parameter IMAGE_HEIGHT                  = 100,
    parameter IMAGE_BUFFER_THRESHOLD        = 3,
    parameter IMAGE_BUFFER_DEPTH            = 512
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // Image Sender interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire image_sender_reset,
    input  wire image_sender_flush,
    input  wire image_sender_write,
    input  wire [IMAGE_BUFFER_DEPTH - 1 : 0] image_sender_fifo_din,          // clk_pixel region
    input  wire clk_pixel,                              // clk_pixel = clk_pixel
    input  wire [BIT_WIDTH-1:0] cx,                     // Current Image x coordinate
    input  wire [BIT_HEIGHT-1:0] cy,                    // Current Image y coordinate
    input  wire auto_start,                             // Signal which initiate modules
    input  wire image_change,                           // External signal which requires new image(e.g. Camera )
    
    output wire image_sender_full,
    output wire image_sender_empty,
    output reg  [23:0] rgb,                             // rgb value
    output reg  require_new_data,                       // Signal which requires new image data to DRAM
    output reg  [FIFO_DEPTH-1:0] data_num
);

localparam BYTE_SIZE = 8;
localparam IMAGE_BUFFER_LEN = (IMAGE_BUFFER_DEPTH >> 3);
localparam IMAGE_BUFFER_WIDTH = $clog2(IMAGE_BUFFER_DEPTH);

wire rd_en;
wire [IMAGE_BUFFER_DEPTH-1:0] image_buffer;
wire [IMAGE_BUFFER_DEPTH-1:0] dout;
wire image_out;
reg  [IMAGE_BUFFER_WIDTH-1:0] image_buffer_index;
reg  image_send_start;
reg  image_change_buffer1;
reg  image_change_buffer2;
reg  [BIT_WIDTH - 1:0] cx_buffer = 0;
reg  [BIT_HEIGHT - 1:0] cy_buffer = 0;

assign image_out = ( ( (SCREEN_HEIGHT >> 1) - (IMAGE_HEIGHT >> 1) < cy_buffer ) && ( cy_buffer <= (SCREEN_HEIGHT >> 1) + (IMAGE_HEIGHT >> 1) ) ) 
                    && ( ( (SCREEN_WIDTH >> 1) - (IMAGE_WIDTH >> 1) < cx_buffer ) && ( cx_buffer <= (SCREEN_WIDTH >> 1) + (IMAGE_WIDTH >> 1) ) )
                    && (image_send_start == 1'b1);
assign rd_en = image_out && (image_buffer_index == (IMAGE_BUFFER_LEN - 1));
assign image_buffer = dout;

//////////////////////////////////////////////////////////////////////////////////
// FIFO for Image
//////////////////////////////////////////////////////////////////////////////////
fifo_generator_0 image_buffer( // 512 width, 256 depth, 250 program full
    .clk                                (clk_pixel),
    .srst                               (image_sender_reset | image_sender_flush),  // rst -> srst in Vivado 2020.2
    .din                                (image_sender_fifo_din),
    .wr_en                              (image_sender_write),
    .rd_en                              (rd_en),
    .dout                               (dout),
    .prog_full                          (image_sender_full),  // full -> prog_full to deal with full delay signal
    .empty                              (image_sender_empty)
);

//////////////////////////////////////////////////////////////////////////////////
// Image Process
//////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        image_buffer_index <= {IMAGE_BUFFER_DEPTH{1'b0}};
        require_new_data <= 1'b0;
        rgb <= 24'hffffff;
        image_send_start <= 1'b0;
        image_change_buffer1 <= 1'b1;
        image_change_buffer2 <= 1'b1;
    end
    else begin
        if( image_send_start == 1'b1 ) begin
            //////////////////////////////////////////////////////////////////////////////////
            // Image Send
            //////////////////////////////////////////////////////////////////////////////////
            if( image_out )begin
                image_buffer_index <= image_buffer_index + 1;
                rgb[7:0] <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[15:8] <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[23:16] <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
            end
            else begin
                rgb[23:0] <= 24'h0;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // Image Change setting
            //////////////////////////////////////////////////////////////////////////////////
            if( ( cx_buffer == (SCREEN_WIDTH - 1) ) && ( cy_buffer == (SCREEN_HEIGHT - 1) ) ) begin // Change image data only when state reached end of image
                image_change_buffer1 <= image_change;
                image_change_buffer2 <= image_change_buffer1;
            end
            else if( image_change == 1'b1 ) begin // To remeber when image_change get positive edge
                image_change_buffer1 <= 1'b1;
            end
        end
        
        if( ( cx == (SCREEN_WIDTH - 2) ) && ( cy == (SCREEN_HEIGHT - 1) ) ) begin
            image_send_start <= auto_start;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////
// Coordinate setiing
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clk_pixel) begin
    if (image_sender_reset) begin
        cx_buffer <= BIT_WIDTH'(0);
        cy_buffer <= BIT_HEIGHT'(0);
    end
    else begin
        if( auto_start && ( cx == (FRAME_WIDTH - 2) ) && ( cy == (FRAME_HEIGHT - 1) ) ) begin
            cx_buffer <= BIT_WIDTH'(0);
            cy_buffer <= BIT_HEIGHT'(0);
        end
        else begin
            cx_buffer <= (cx_buffer == FRAME_WIDTH-1'b1) ? BIT_WIDTH'(0) : cx_buffer + 1'b1;
            cy_buffer <= (cx_buffer == FRAME_WIDTH-1'b1) ? (cy_buffer == FRAME_HEIGHT-1'b1) ? BIT_HEIGHT'(0) : cy_buffer + 1'b1 : cy_buffer;
        end
    end
end

endmodule