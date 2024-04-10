`timescale 1ns / 1ps

module ImageSender
#(
    parameter TEST_MODE                     = 1'b1,
    parameter int BIT_WIDTH                 = 12,
    parameter int BIT_HEIGHT                = 11,
    parameter FIFO_DEPTH                    = 9
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // RTO_Core interface
    //////////////////////////////////////////////////////////////////////////////////
    input  reg rto_core_reset,                      // pixel_clk region
    input  reg rto_core_flush,                      // pixel_clk region
    input  wire rto_core_write,                     // pixel_clk region
    input  wire [127:0] rto_core_fifo_din,          // pixel_clk region
    
    output wire rto_core_full,                       // pixel_clk region
    output wire rto_core_empty,                      // pixel_clk region
    
    //////////////////////////////////////////////////////////////////////////////////
    // RTI_Core interface
    //////////////////////////////////////////////////////////////////////////////////
    input  reg rti_core_reset,
    input  wire rti_core_rd_en,
    input  reg rti_core_flush,
    
    output wire [127:0] rti_core_fifo_dout,
    output wire rti_core_full,
    output wire rti_core_empty,
    output wire [FIFO_DEPTH - 1:0] data_num,
    
    //////////////////////////////////////////////////////////////////////////////////
    // Clock Domain Crossing Interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire rtio_clk,
    
    //////////////////////////////////////////////////////////////////////////////////  
    // ImageSender interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [BIT_WIDTH-1:0] cx,
    input  wire [BIT_HEIGHT-1:0] cy,
    input  wire [BIT_WIDTH-1:0] frame_width,
    input  wire [BIT_HEIGHT-1:0] frame_height,
    input  wire [BIT_WIDTH-1:0] screen_width,
    input  wire [BIT_HEIGHT-1:0] screen_height,
    output logic [23:0] rgb
);

generate
    if( TEST_MODE == 1'b1 ) begin:test_mode
        always@(*) begin
            if( cy < (screen_width >> 2) ) begin
                rgb <= {8'hff, 8'h0, 8'h0};
            end
            else if( cy < (screen_width >> 2) * 2 ) begin
                rgb <= {8'h0, 8'hff, 8'h0};
            end
            else if( cy < (screen_width >> 2) * 3 ) begin
                rgb <= {8'h0, 8'h0, 8'hff};
            end
            else begin
                rgb <= {8'hff, 8'hff, 8'hff};
            end
        end
    end
endgenerate

endmodule