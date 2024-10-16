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
    parameter IMAGE_BUFFER_FIFO_DIV         = 4,
    parameter IMAGE_BUFFER_DEPTH            = DRAM_DATA_WIDTH >> $clog2(IMAGE_BUFFER_FIFO_DIV),
    parameter IMAGE_CHANGE_TIME             = 10,
    parameter AXI_DATA_WIDTH                = 128,
    parameter AXI_ADDR_WIDTH                = 32,
    parameter BUFFER_THRESHOLD              = 14,
    parameter DRAM_ADDR_WIDTH               = 39
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
    
    input  wire [DRAM_DATA_WIDTH - 1:0] dram_read_data,
    input  wire dram_read_data_valid,
    input  wire dram_write_busy,
    input  wire dram_read_busy
);

localparam BYTE_SIZE = 8;
localparam IMAGE_BUFFER_LEN = (IMAGE_BUFFER_DEPTH >> 3);
localparam IMAGE_BUFFER_WIDTH = $clog2(IMAGE_BUFFER_LEN);
localparam IMAGE_BUFFER_FIFO_DIV_LEN = $clog2(IMAGE_BUFFER_FIFO_DIV);
localparam CX_BUFFER_TRIGGER_VALUE = (FRAME_WIDTH - 3);
localparam CX_BUFFER_SET_VALUE = (FRAME_WIDTH - 1);
localparam CY_BUFFER_TRIGGER_VALUE = (FRAME_HEIGHT - 2 - IMAGE_CHANGE_TIME);
localparam CY_BUFFER_SET_VALUE = (FRAME_HEIGHT - 2 - IMAGE_CHANGE_TIME);


reg  image_send_start;
reg  image_change_buffer;
reg  [IMAGE_BUFFER_WIDTH-1:0] image_buffer_index;
reg  image_buffer_fifo_wr_en;
reg  [IMAGE_BUFFER_FIFO_DIV_LEN - 1:0] image_buffer_fifo_din_select;
reg  image_flush_trigger_buffer;

reg  [BIT_WIDTH - 1:0] cx_buffer = 0;
reg  [BIT_HEIGHT - 1:0] cy_buffer = 0;

reg  [DRAM_ADDR_WIDTH - 1:0] dram_current_addr;
reg  [DRAM_ADDR_WIDTH - 1:0] dram_last_addr;
reg  [DRAM_DATA_WIDTH - 1:0] dram_buffer;

wire image_buffer_fifo_rd_en;
wire [IMAGE_BUFFER_DEPTH-1:0] image_buffer;
wire image_discharge_en;
wire [63:0] image_addr_upper;
wire [63:0] image_addr_lower;
wire [IMAGE_BUFFER_DEPTH - 1:0] image_buffer_fifo_din;
wire image_buffer_fifo_full;
wire image_flush_trigger;
wire image_initial_trigger;

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
assign image_flush_trigger      = ( cx_buffer == (FRAME_WIDTH - 1) ) && ( cy_buffer == (FRAME_HEIGHT - 1 - IMAGE_CHANGE_TIME) );
assign image_initial_trigger    = (auto_start == 1'b1 && image_send_start == 1'b0); // auto_start LOW -> HIGH sense signal
assign dram_address_rd_en       = (image_flush_trigger && image_change_buffer);
assign image_buffer_fifo_din[IMAGE_BUFFER_DEPTH - 1:0] = dram_buffer[image_buffer_fifo_din_select * IMAGE_BUFFER_DEPTH +:IMAGE_BUFFER_DEPTH];

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
image_data_buffer_fifo image_data_buffer_fifo_0 ( // 128 width, 512 depth, 510 program full
    .clk                                (clk_pixel),
    .srst                               (image_sender_reset | image_sender_flush | image_flush_trigger ),  // rst -> srst 
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
        rgb <= 24'hff_ff_ff;
        
        image_buffer_index <= IMAGE_BUFFER_DEPTH'(0);
        image_send_start <= 1'b0;
        image_change_buffer <= 1'b0;
        dram_current_addr <= AXI_ADDR_WIDTH'(0);
        image_flush_trigger_buffer <= 1'b0;
    end
    else begin
        image_flush_trigger_buffer <= image_flush_trigger;
        if( image_send_start == 1'b1 ) begin // image_send_start is used instead of auto_start not to stop image send during video period
            //////////////////////////////////////////////////////////////////////////////////
            // Image Send
            //////////////////////////////////////////////////////////////////////////////////
            if( image_discharge_en )begin
                image_buffer_index <= image_buffer_index + 1;
                dram_current_addr <= dram_current_addr + 1;
                rgb[7:0]   <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[15:8]  <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                rgb[23:16] <= image_buffer[image_buffer_index * BYTE_SIZE +: BYTE_SIZE];
                if( image_buffer_index == IMAGE_BUFFER_WIDTH'(IMAGE_BUFFER_LEN - 1)) begin
                    image_buffer_index <= IMAGE_BUFFER_WIDTH'(0);
                end
            end
            else begin
                rgb[23:0] <= 24'h0;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // Image Change setting
            //////////////////////////////////////////////////////////////////////////////////
            if( image_flush_trigger ) begin // Change image data only when state reached end of image
                image_change_buffer <= image_change;
                image_buffer_index <= IMAGE_BUFFER_DEPTH'(0);
            end
            else if( image_change == 1'b1 ) begin // To save image_change signal
                image_change_buffer <= 1'b1;
            end
        end
        
        if( image_flush_trigger ) begin // sense auto_start when there is enough time to get image data from DRAM
            image_send_start <= auto_start;
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
    end
    else begin
        dram_buffer <= dram_read_data;
        if(~dram_read_busy) begin
            dram_read_en <= 1'b0;
        end
        if( image_send_start == 1'b1 ) begin
            if( ( dram_last_addr < DRAM_ADDR_WIDTH'(dram_current_addr + (DRAM_DATA_WIDTH >> 3) * BUFFER_THRESHOLD) ) && 
                (dram_last_addr <= DRAM_ADDR_WIDTH'(image_addr_upper) ) && 
                ~dram_read_busy && 
                ~image_buffer_fifo_full) begin // 10 buffer data is read from DRAM before discharge
                dram_read_addr <= DRAM_ADDR_WIDTH'(dram_last_addr);
                dram_last_addr <= DRAM_ADDR_WIDTH'(dram_last_addr + (DRAM_DATA_WIDTH >> 3));
                dram_read_en <= 1'b1;
                dram_read_len <= 8'h0;
            end
            
            if( image_flush_trigger_buffer ) begin // To acquire image address value from fifo, one cycle delayed image_flush_trigger signal is used
                dram_read_addr <= DRAM_ADDR_WIDTH'(image_addr_lower);
                dram_last_addr <= DRAM_ADDR_WIDTH'(image_addr_lower + (DRAM_DATA_WIDTH >> 3));
                dram_read_en <= 1'b1;
                dram_read_len <= 8'h0;
                dram_current_addr <= image_addr_lower;
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
        if( image_buffer_fifo_wr_en ) begin
            image_buffer_fifo_din_select <= image_buffer_fifo_din_select + 1;
            if(image_buffer_fifo_din_select == IMAGE_BUFFER_FIFO_DIV_LEN'(4'hf)) begin
                image_buffer_fifo_din_select <= IMAGE_BUFFER_FIFO_DIV_LEN'(0);
                image_buffer_fifo_wr_en <= 1'b0;
            end
        end
        else begin
            image_buffer_fifo_din_select <= IMAGE_BUFFER_FIFO_DIV_LEN'(0);
            image_buffer_fifo_wr_en <= dram_read_data_valid;
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
        if( ( cx == CX_BUFFER_TRIGGER_VALUE ) && ( cy == CY_BUFFER_TRIGGER_VALUE ) ) begin
            cx_buffer <= BIT_WIDTH'(CX_BUFFER_SET_VALUE);
            cy_buffer <= BIT_HEIGHT'(CY_BUFFER_SET_VALUE);
        end
        else begin
            cx_buffer <= (cx_buffer == FRAME_WIDTH-1'b1) ? BIT_WIDTH'(0) : cx_buffer + 1'b1;
            cy_buffer <= (cx_buffer == FRAME_WIDTH-1'b1) ? (cy_buffer == FRAME_HEIGHT-1'b1) ? BIT_HEIGHT'(0) : cy_buffer + 1'b1 : cy_buffer;
        end
    end
end

endmodule