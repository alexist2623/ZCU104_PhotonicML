`timescale 1ns / 1ps

module ImageSender
#(
    parameter FRAME_WIDTH                   = 2200,
    parameter FRAME_HEIGHT                  = 1125,
    parameter SCREEN_WIDTH                  = 1920,
    parameter SCREEN_HEIGHT                 = 1080,
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    parameter FIFO_DEPTH                    = 512,
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_ADDR_WIDTH                = 32,
    parameter DRAM_ADDR_WIDTH               = 39,
    parameter DRAM_DATA_WIDTH               = 128,
    parameter IMAGE_BUFFER_DEPTH            = DRAM_DATA_WIDTH,
    parameter IMAGE_CHANGE_TIME             = 40
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // Image Sender interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire image_sender_reset,
    input  wire image_sender_flush,
    input  wire image_sender_write,
    input  wire [IMAGE_BUFFER_DEPTH - 1 : 0] image_sender_fifo_din,
    input  wire clk_pixel, 
    input  wire [BIT_WIDTH-1:0] cx,                     // Current Image x coordinate
    input  wire [BIT_HEIGHT-1:0] cy,                    // Current Image y coordinate
    input  wire auto_start,                             // Signal which initiate modules
    input  wire image_change,                           // External signal which requires new image(e.g. Camera )
    input  wire [BIT_WIDTH-1:0] image_width,
    input  wire [BIT_HEIGHT-1:0] image_height,
    
    output wire image_sender_full,
    output wire image_sender_empty,
    output  reg  [23:0] rgb,                             // rgb value
    //////////////////////////////////////////////////////////////////////////////////
    // DRAM Data Interface
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [DRAM_ADDR_WIDTH - 1:0] dram_read_addr,
    output  reg [7:0] dram_read_len,
    output  reg dram_read_en,
    
    output  reg [DRAM_ADDR_WIDTH - 1:0] dram_write_addr,
    output  reg [7:0] dram_write_len,
    output  reg dram_write_en,
    output  reg [DRAM_DATA_WIDTH - 1:0] dram_write_data,
    output wire dram_buffer_full,
    output wire [127:0] debug_buffer_data,
    
    input  wire [DRAM_DATA_WIDTH - 1:0] dram_read_data,
    input  wire dram_read_data_valid,
    input  wire dram_write_busy,
    input  wire dram_read_busy
);

localparam BYTE_SIZE = 8;
localparam IMAGE_BUFFER_LEN = (IMAGE_BUFFER_DEPTH >> 3);
localparam IMAGE_BUFFER_WIDTH = $clog2(IMAGE_BUFFER_LEN);
localparam CX_BUFFER_TRIGGER_VALUE = (FRAME_WIDTH - 3);
localparam CX_BUFFER_SET_VALUE = (FRAME_WIDTH - 1);
localparam CY_BUFFER_TRIGGER_VALUE = (FRAME_HEIGHT - 2 - IMAGE_CHANGE_TIME);
localparam CY_BUFFER_SET_VALUE = (FRAME_HEIGHT - 2 - IMAGE_CHANGE_TIME);


reg  image_send_start;
reg  image_change_buffer;
reg  [IMAGE_BUFFER_WIDTH-1:0] image_buffer_index;
reg  image_buffer_fifo_wr_en;
reg  image_flush_trigger_buffer;
reg  image_read_en;
reg  load_new_image;

reg  [BIT_WIDTH - 1:0] cx_buffer = 0;
reg  [BIT_HEIGHT - 1:0] cy_buffer = 0;
reg  coordinate_buffer_set = 0;

reg  [DRAM_ADDR_WIDTH - 1:0] dram_current_addr;
reg  [DRAM_ADDR_WIDTH - 1:0] dram_last_addr;
reg  dram_read_en_buffer;

wire image_buffer_fifo_rd_en;
wire [IMAGE_BUFFER_DEPTH-1:0] image_buffer;
wire image_discharge_en;
wire [63:0] image_addr_upper;
wire [63:0] image_addr_lower;
wire [IMAGE_BUFFER_DEPTH - 1:0] image_buffer_fifo_din;
wire image_buffer_fifo_full;
wire image_flush_trigger;
wire image_buffer_empty;
wire [IMAGE_BUFFER_DEPTH-1:0] image_old;
wire [IMAGE_BUFFER_DEPTH-1:0] image_new;

wire dram_address_rd_en;

// for 10 x 10 size frame, 2 x 2 size image
// only 4, 5 index of image should be discharged
// so 10 >> 1 - 2 >> 1 = 4, 10 >> 1 + 2 >> 1 = 6
//  for 3 x 3 size image, 4, 5, 6 of index of image should be discharged
// so  10 >> - 3 >> 1 = 4 , 10 >> 1 + 3 >> 1 + 1= 7
assign image_discharge_en       = ( ( (SCREEN_HEIGHT >> 1) - (image_height >> 1) <= cy_buffer ) && ( cy_buffer < (SCREEN_HEIGHT >> 1) + (image_height >> 1) + image_height[0] ) ) 
                                    && ( ( (SCREEN_WIDTH >> 1) - (image_width >> 1) <= cx_buffer ) && ( cx_buffer < (SCREEN_WIDTH >> 1) + (image_width >> 1) + image_width[0] ) )
                                    && (image_send_start == 1'b1); // discharge image only when cx, and cy is in image section
assign image_buffer_fifo_rd_en  = image_discharge_en && (image_buffer_index == (IMAGE_BUFFER_LEN - 1));
assign image_flush_trigger      = ( cx_buffer == (FRAME_WIDTH - 1) ) && ( cy_buffer == (FRAME_HEIGHT - 1 - IMAGE_CHANGE_TIME) ) && (coordinate_buffer_set == 1'b1);
assign dram_address_rd_en       = (image_flush_trigger && image_change_buffer);
assign dram_buffer_full         = image_buffer_fifo_full;
assign debug_buffer_data        = image_buffer;
assign image_buffer             = (load_new_image == 1'b1)? image_new : image_old;

//////////////////////////////////////////////////////////////////////////////////
// FIFO for Image Address
//////////////////////////////////////////////////////////////////////////////////

image_address_fifo image_address_fifo_0 ( // 128 width, 512 depth, 500 program full
    .clk                                (clk_pixel),
    .srst                               (image_sender_reset | image_sender_flush),  // rst -> srst 
    .din                                (image_sender_fifo_din),
    .wr_en                              (image_sender_write),
    .rd_en                              (dram_address_rd_en),
    .dout                               ({image_addr_upper,image_addr_lower}),
    .prog_full                          (image_sender_full),  // full -> prog_full to deal with full delay signal
    .empty                              (image_sender_empty)
);

//////////////////////////////////////////////////////////////////////////////////
// FIFO for Image Data
//////////////////////////////////////////////////////////////////////////////////
image_data_save_buffer_fifo image_data_save_buffer_fifo_0 ( // 128 width, 2048 depth, 2000 program full. Image Buffer for Future
    .clk                                (clk_pixel),
    .srst                               (image_sender_reset | image_sender_flush),  // rst -> srst 
    .din                                (dram_read_data),
    .wr_en                              (dram_read_data_valid),
    .rd_en                              (image_buffer_fifo_rd_en & load_new_image),
    .dout                               (image_new),
    .prog_full                          (image_buffer_fifo_full),  // full -> prog_full to deal with full delay signal
    .empty                              ()
);

image_data_reuse_buffer_fifo image_data_reuse_buffer_fifo_1 ( // 128 width, 2048 depth, 2000 program full
    .clk                                (clk_pixel),
    // flsuh reuse fifo when load new image
    .srst                               (image_sender_reset | image_sender_flush | (image_flush_trigger_buffer & load_new_image) ),  // rst -> srst 
    .din                                (image_buffer),
    .wr_en                              (image_buffer_fifo_rd_en),
    .rd_en                              (image_buffer_fifo_rd_en & ~image_buffer_empty & ~load_new_image),
    .dout                               (image_old),
    .prog_full                          (),  // full -> prog_full to deal with full delay signal
    .empty                              (image_buffer_empty)
);
/*
 * Declared for verification
 */
int i = 0;

//////////////////////////////////////////////////////////////////////////////////
// Image Buffer and Trigger Control
//////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        rgb <= 24'hff_ff_ff;
        
        image_buffer_index <= IMAGE_BUFFER_DEPTH'(0);
        image_send_start <= 1'b0;
        image_change_buffer <= 1'b0;
        image_flush_trigger_buffer <= 1'b0;
        image_read_en <= 1'b0;
        image_change_buffer <= 1'b0;
        load_new_image <= 1'b0;
    end
    else begin
        image_flush_trigger_buffer <= image_flush_trigger; // make 1 cycle delayed image_flush_trigger 
        if( image_send_start == 1'b1 ) begin // image_send_start is used instead of auto_start not to stop image send during video period
            //////////////////////////////////////////////////////////////////////////////////
            // Image Send
            //////////////////////////////////////////////////////////////////////////////////
            if( image_discharge_en )begin
                image_buffer_index <= image_buffer_index + 1;
                rgb[7:0]   <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[15:8]  <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[23:16] <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                if( image_buffer_empty == 1'b1 )begin
                    rgb[23:0] <= 24'h00_ff_00;
                end
                if( image_buffer_index == IMAGE_BUFFER_WIDTH'(IMAGE_BUFFER_LEN - 1)) begin
                    image_buffer_index <= IMAGE_BUFFER_WIDTH'(0);
                end
                /************************Simulation Code***************************/
                i = i + 1;
                $display("cx : %d, cy : %d, i : %d, rgb : %d, buffer index : %d",
                    cx, cy, i, rgb[7:0], image_buffer_index);
                /******************************************************************/
            end
            else begin
                rgb[23:0] <= 24'hff_00_00;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // Image Change setting
            //////////////////////////////////////////////////////////////////////////////////
            if( image_flush_trigger ) begin // Change image data only when state reached end of image
                image_change_buffer <= image_change;    // reset image_change_buffer
                image_buffer_index <= IMAGE_BUFFER_DEPTH'(0);   // reset buffer index
                load_new_image <= image_change_buffer; // save image_change signal and maintain until image_flush_trigger signal
            end
            else if( image_change == 1'b1 ) begin // To save image_change signal
                image_change_buffer <= 1'b1;
            end
        end
        else begin
            rgb[23:0] <= 24'h00_00_ff;
        end
        
        if( image_flush_trigger ) begin // sense auto_start when there is enough time to get image data from DRAM
            image_send_start <= auto_start;
            if( image_send_start == 1'b0 && auto_start == 1'b1 ) begin // Load New image when machine starts
                load_new_image <= 1'b1;
            end
        end
    end
end

            
//////////////////////////////////////////////////////////////////////////////////
// DRAM read Control
//////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        dram_read_addr <= 64'h0;
        dram_last_addr <= 64'h0;
        dram_read_en <= 1'b0;
        dram_read_len <= 8'h0;
        dram_read_en_buffer <= 1'b0;
        dram_current_addr <= AXI_ADDR_WIDTH'(0);
    end
    else begin
        dram_read_en <= 1'b0;
        if( dram_address_rd_en ) begin
            dram_read_en_buffer <= 1'b1;
        end
        else if( ~dram_read_busy && ~image_buffer_fifo_full ) begin
            dram_read_en <= dram_read_en_buffer;
            dram_read_en_buffer <= 1'b0;
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
        coordinate_buffer_set <= 1'b0;
    end
    else begin
        if( ( cx == CX_BUFFER_TRIGGER_VALUE ) && ( cy == CY_BUFFER_TRIGGER_VALUE ) ) begin
            cx_buffer <= BIT_WIDTH'(CX_BUFFER_SET_VALUE);
            cy_buffer <= BIT_HEIGHT'(CY_BUFFER_SET_VALUE);
            coordinate_buffer_set <= 1'b1;
        end
        else begin
            cx_buffer <= (cx_buffer == FRAME_WIDTH-1'b1) ? BIT_WIDTH'(0) : cx_buffer + 1'b1;
            cy_buffer <= (cx_buffer == FRAME_WIDTH-1'b1) ? (cy_buffer == FRAME_HEIGHT-1'b1) ? BIT_HEIGHT'(0) : cy_buffer + 1'b1 : cy_buffer;
        end
    end
end

endmodule