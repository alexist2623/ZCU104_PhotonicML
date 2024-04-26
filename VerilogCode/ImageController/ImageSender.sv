`timescale 1ns / 1ps

module ImageSender
#(
    parameter FRAME_WIDTH                   = 2200,
    parameter FRAME_HEIGHT                  = 1125,
    parameter SCREEN_WIDTH                  = 1920,
    parameter SCREEN_HEIGHT                 = 1080,
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    parameter FIFO_DEPTH                    = 256,
    parameter DRAM_DATA_WIDTH               = 512,
    parameter IMAGE_WIDTH                   = 100,
    parameter IMAGE_HEIGHT                  = 100,
    parameter IMAGE_BUFFER_FIFO_DIV         = 4,
    parameter IMAGE_BUFFER_DEPTH            = DRAM_DATA_WIDTH >> $clog2(IMAGE_BUFFER_FIFO_DIV),
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_ADDR_WIDTH                = 32,
    parameter BUFFER_THRESHOLD              = 14
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
localparam IMAGE_BUFFER_FIFO_DIV_LEN = $clog2(IMAGE_BUFFER_FIFO_DIV);


reg  image_send_start;
reg  image_change_buffer;
reg  [IMAGE_BUFFER_WIDTH-1:0] image_buffer_index;
reg  [BIT_WIDTH - 1:0] cx_buffer = 0;
reg  [BIT_HEIGHT - 1:0] cy_buffer = 0;
reg  [AXI_ADDR_WIDTH - 1:0] image_current_addr;
reg  [AXI_ADDR_WIDTH - 1:0] dram_last_addr;
reg  image_end_reached;
reg  [DRAM_DATA_WIDTH - 1:0] dram_buffer;
reg  image_buffer_fifo_wr_en;
reg  [IMAGE_BUFFER_FIFO_DIV_LEN - 1:0] image_buffer_fifo_din_select;

wire image_buffer_fifo_rd_en;
wire [IMAGE_BUFFER_DEPTH-1:0] image_buffer;
wire image_discharge_en;
wire [AXI_ADDR_WIDTH - 1:0] image_addr_upper;
wire [AXI_ADDR_WIDTH - 1:0] image_addr_lower;
wire [IMAGE_BUFFER_DEPTH - 1:0] image_buffer_fifo_din;
wire image_buffer_fifo_full;
wire dram_address_rd_en;

assign image_discharge_en = ( ( (SCREEN_HEIGHT >> 1) - (IMAGE_HEIGHT >> 1) < cy_buffer ) && ( cy_buffer <= (SCREEN_HEIGHT >> 1) + (IMAGE_HEIGHT >> 1) ) ) 
                    && ( ( (SCREEN_WIDTH >> 1) - (IMAGE_WIDTH >> 1) < cx_buffer ) && ( cx_buffer <= (SCREEN_WIDTH >> 1) + (IMAGE_WIDTH >> 1) ) )
                    && (image_send_start == 1'b1);
assign image_buffer_fifo_rd_en = image_discharge_en && (image_buffer_index == (IMAGE_BUFFER_LEN - 1));
assign dram_address_rd_en = ( cx_buffer == (SCREEN_WIDTH - 1) ) && ( cy_buffer == (SCREEN_HEIGHT - 1) ) && image_change_buffer;
assign image_buffer_fifo_din[IMAGE_BUFFER_DEPTH - 1:0] = dram_buffer[image_buffer_fifo_din_select * IMAGE_BUFFER_DEPTH +:IMAGE_BUFFER_DEPTH];

//////////////////////////////////////////////////////////////////////////////////
// FIFO for Image Address
//////////////////////////////////////////////////////////////////////////////////

fifo_generator_1 image_address( // 128 width, 512 depth, 500 program full
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
fifo_generator_0 image_data_buffer( // 128 width, 512 depth, 510 program full
    .clk                                (clk_pixel),
    .srst                               (image_sender_reset | image_sender_flush | image_end_reached),  // rst -> srst 
    .din                                (image_buffer_fifo_din),
    .wr_en                              (image_buffer_fifo_wr_en),
    .rd_en                              (image_buffer_fifo_rd_en),
    .dout                               (image_buffer),
    .prog_full                          (image_buffer_fifo_full),  // full -> prog_full to deal with full delay signal
    .empty                              ()
);

//////////////////////////////////////////////////////////////////////////////////
// Image Buffer and Trigger Control
//////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        rgb <= 24'hffffff;
        
        image_buffer_index <= IMAGE_BUFFER_DEPTH'(0);
        image_send_start <= 1'b0;
        image_change_buffer <= 1'b0;
        image_end_reached <= 1'b0;
        image_current_addr <= AXI_ADDR_WIDTH'(0);
    end
    else begin
        image_end_reached <= 1'b0;
        if( image_send_start == 1'b1 ) begin
            //////////////////////////////////////////////////////////////////////////////////
            // Image Send
            //////////////////////////////////////////////////////////////////////////////////
            if( image_discharge_en )begin
                image_buffer_index <= image_buffer_index + 1;
                image_current_addr <= image_current_addr + 1;
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
                image_end_reached <= 1'b1;
                image_buffer_index <= IMAGE_BUFFER_DEPTH'(0);
                image_current_addr <= AXI_ADDR_WIDTH'(0);
            end
            else if( image_change == 1'b1 ) begin // To save image_change signal
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
        dram_read_addr <= AXI_ADDR_WIDTH'(0);
        dram_last_addr <= AXI_ADDR_WIDTH'(0);
        dram_read_en <= 1'b0;
        dram_read_len <= 8'h0;
    end
    else begin
        dram_read_en <= 1'b0;
        if( image_send_start == 1'b1 ) begin
            if( ( dram_last_addr < (image_addr_lower + image_current_addr + (DRAM_DATA_WIDTH >> 3) * BUFFER_THRESHOLD) ) && 
                (dram_last_addr <= image_addr_upper) && 
                ~dram_read_busy && 
                ~image_buffer_fifo_full) begin // 10 buffer data is read from DRAM before discharge
                dram_read_addr <= dram_last_addr + (DRAM_DATA_WIDTH >> 3);
                dram_last_addr <= dram_last_addr + (DRAM_DATA_WIDTH >> 3);
                dram_read_en <= 1'b1;
                dram_read_len <= 8'h0;
            end
            
            if( image_end_reached == 1'b1 ) begin
                dram_last_addr <= image_addr_lower;
                dram_read_addr <= image_addr_lower;
                dram_read_en <= 1'b1;
                dram_read_len <= 8'h0;
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
// FIFO write FSM
//////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_pixel) begin
    if( image_sender_reset == 1'b1 ) begin
        image_buffer_fifo_din_select <= IMAGE_BUFFER_FIFO_DIV_LEN'(0);
        image_buffer_fifo_wr_en <= 1'b0;
    end
    else begin
        image_buffer_fifo_din_select <= dram_read_data_valid;
        image_buffer_fifo_wr_en <= dram_read_data_valid;
        if( image_buffer_fifo_din_select != IMAGE_BUFFER_FIFO_DIV_LEN'(0) ) begin
            image_buffer_fifo_wr_en <= 1'b1;
            image_buffer_fifo_din_select <= image_buffer_fifo_din_select + 1;
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