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
    parameter IMAGE_BUFFER_DEPTH            = 512,
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_ADDR_WIDTH                = 32,
    parameter DRAM_DATA_WIDTH               = 512
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
    output  reg  [23:0] rgb,                             // rgb value
    //////////////////////////////////////////////////////////////////////////////////
    // DRAM Data Interface
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [AXI_ADDR_WIDTH - 1:0] dram_read_addr,
    output  reg [7:0] dram_read_len,
    output  reg dram_read_en,
    
    output  reg [AXI_ADDR_WIDTH - 1:0] dram_write_addr,
    output  reg [7:0] dram_write_len,
    output  reg dram_write_en,
    output  reg [DRAM_DATA_WIDTH - 1:0] dram_write_data,
    
    input  wire [DRAM_DATA_WIDTH - 1:0] dram_read_data,
    input  wire dram_read_data_valid,
    input  wire dram_write_busy,
    input  wire dram_read_busy
);

localparam BYTE_SIZE = 8;
localparam IMAGE_BUFFER_LEN = (IMAGE_BUFFER_DEPTH >> 3);
localparam IMAGE_BUFFER_WIDTH = $clog2(IMAGE_BUFFER_DEPTH);


reg  image_send_start;
reg  image_change_buffer;
reg  image_change_trigger;
reg  [IMAGE_BUFFER_WIDTH-1:0] image_buffer_index;
reg  [BIT_WIDTH - 1:0] cx_buffer = 0;
reg  [BIT_HEIGHT - 1:0] cy_buffer = 0;
reg  [AXI_ADDR_WIDTH - 1:0] dram_last_addr;
reg  image_end_reached;

wire image_fifo_rd_en;
wire [IMAGE_BUFFER_DEPTH-1:0] image_buffer;
wire image_discharge_en;
wire dram_address_rd_en;
wire [AXI_ADDR_WIDTH - 1:0] image_addr_upper;
wire [AXI_ADDR_WIDTH - 1:0] image_addr_lower;
wire image_buffer_fifo_full;
wire image_end_reached;

assign image_discharge_en = ( ( (SCREEN_HEIGHT >> 1) - (IMAGE_HEIGHT >> 1) < cy_buffer ) && ( cy_buffer <= (SCREEN_HEIGHT >> 1) + (IMAGE_HEIGHT >> 1) ) ) 
                    && ( ( (SCREEN_WIDTH >> 1) - (IMAGE_WIDTH >> 1) < cx_buffer ) && ( cx_buffer <= (SCREEN_WIDTH >> 1) + (IMAGE_WIDTH >> 1) ) )
                    && (image_send_start == 1'b1);
assign image_fifo_rd_en = image_discharge_en && (image_buffer_index == (IMAGE_BUFFER_LEN - 1));
assign dram_address_rd_en = ( cx_buffer == (SCREEN_WIDTH - 1) ) && ( cy_buffer == (SCREEN_HEIGHT - 1) ) && image_change_buffer;

//////////////////////////////////////////////////////////////////////////////////
// FIFO for Image Address
//////////////////////////////////////////////////////////////////////////////////

fifo_generator_1 image_address( // 128 width, 256 depth, 250 program full
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
fifo_generator_0 image_data_buffer( // 512 width, 16 depth, 15 program full
    .clk                                (clk_pixel),
    .srst                               (image_sender_reset | image_sender_flush | dram_address_rd_en),  // rst -> srst 
    .din                                (dram_read_data),
    .wr_en                              (dram_read_data_valid),
    .rd_en                              (image_fifo_rd_en),
    .dout                               (image_buffer),
    .prog_full                          (),  // full -> prog_full to deal with full delay signal
    .empty                              (image_buffer_fifo_full)
);

//////////////////////////////////////////////////////////////////////////////////
// Image Buffer and Trigger Control
//////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        rgb <= 24'hffffff;
        
        image_buffer_index <= {IMAGE_BUFFER_DEPTH{1'b0}};
        image_send_start <= 1'b0;
        image_change_buffer <= 1'b1;
        image_change_trigger <= 1'b0;
    end
    else begin
        if( image_send_start == 1'b1 ) begin
            //////////////////////////////////////////////////////////////////////////////////
            // Image Send
            //////////////////////////////////////////////////////////////////////////////////
            if( image_discharge_en )begin
                image_buffer_index <= image_buffer_index + 1;
                rgb[7:0]   <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[15:8]  <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[23:16] <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
            end
            else begin
                rgb[23:0] <= 24'h0;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // Image Change setting
            //////////////////////////////////////////////////////////////////////////////////
            if( ( cx_buffer == (SCREEN_WIDTH - 1) ) && ( cy_buffer == (SCREEN_HEIGHT - 1) ) ) begin // Change image data only when state reached end of image
                image_change_buffer <= image_change;
                image_change_trigger <= image_change_buffer;
                image_end_reached <= 1'b1;
            end
            else if( image_change == 1'b1 ) begin // To remeber when image_change get positive edge
                image_change_buffer <= 1'b1;
            end
        end
        
        if( ( cx == (SCREEN_WIDTH - 2) ) && ( cy == (SCREEN_HEIGHT - 1) ) ) begin
            image_send_start <= auto_start;
        end
    end
end

            
//////////////////////////////////////////////////////////////////////////////////
// DRAM read Control
//////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        dram_read_addr <= AXI_ADDR_WIDTH'h0;
        dram_last_addr <= AXI_ADDR_WIDTH'h0;
        dram_read_en <= 1'b0;
        dram_read_len <= 8'h0;
    end
    else begin
        dram_read_en <= 1'b0;
        if( image_send_start == 1'b1 ) begin
            if( ( dram_last_addr < (image_addr_lower + cx_buffer + cy_buffer * IMAGE_WIDTH + 10) ) && 
                (dram_last_addr < image_addr_upper) && 
                ~dram_read_busy && 
                ~image_change_trigger &&
                ~image_buffer_fifo_full &&
                ~image_end_reached) begin // 10 buffer data is read from DRAM before discharge
                dram_read_addr <= dram_last_addr + 1;
                dram_last_addr <= dram_last_addr + 1;
                dram_read_en <= 1'b1;
                dram_read_len <= 8'h0;
            end
            
            if( image_end_reached == 1'b1 ) begin
                dram_last_addr <= image_addr_lower;
            end
        end
        
        if( ( cx == (SCREEN_WIDTH - 2) ) && ( cy == (SCREEN_HEIGHT - 1) ) ) begin
            if( auto_start == 1'b1 && image_send_start == 1'b0) begin
                dram_last_addr <= image_addr_lower;
            end
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