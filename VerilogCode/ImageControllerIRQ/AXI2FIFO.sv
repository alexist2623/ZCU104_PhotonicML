`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/18 16:37:21
// Design Name: 
// Module Name: AXI2FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 128 bit slave AXI4 to native FIFO interface module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI2FIFO
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH                    = 7,
    parameter AXI_DATA_WIDTH                    = 128,
    parameter AXI_STROBE_WIDTH                  = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                    = 4, // LOG(AXI_STROBE_WDITH)
    parameter FIFO_DEPTH                        = 512,
    parameter int BIT_WIDTH                     = 12,
    parameter int BIT_HEIGHT                    = 11,
    parameter DRAM_ADDR_WIDTH                   = 39,
    parameter DRAM_DATA_WIDTH                   = 128
    
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
    input  wire [15:0] s_axi_awid, 
    input  wire [1:0] s_axi_awburst,
    input  wire [2:0] s_axi_awsize,
    input  wire [7:0] s_axi_awlen,
    input  wire s_axi_awvalid,
    input  wire [15:0] s_axi_awuser, 
    output wire s_axi_awready, //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_bready,
    output reg  [1:0] s_axi_bresp,
    output reg  s_axi_bvalid,
    output reg  [15:0] s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_DATA_WIDTH - 1:0] s_axi_wdata,
    input  wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input  wire s_axi_wvalid,
    input  wire s_axi_wlast,
    output wire s_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [1:0] s_axi_arburst,
    input  wire [7:0] s_axi_arlen,
    input  wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr,
    input  wire [2:0] s_axi_arsize,
    input  wire s_axi_arvalid,
    input  wire [15:0] s_axi_arid,
    input  wire [15:0] s_axi_aruser,
    output wire s_axi_arready,
    output reg  [15:0] s_axi_rid,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_rready,
    output reg  [AXI_DATA_WIDTH - 1:0] s_axi_rdata,
    output reg  [1:0] s_axi_rresp,
    output reg  s_axi_rvalid,
    output reg  s_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire s_axi_aresetn,
    
    //////////////////////////////////////////////////////////////////////////////////
    // Image Sender interface
    //////////////////////////////////////////////////////////////////////////////////
    output wire image_sender_reset, 
    output reg  image_sender_flush, 
    output reg  image_sender_write,  
    output reg  [127:0] image_sender_fifo_din,
    output reg  [BIT_WIDTH-1:0] image_width,
    output reg  [BIT_HEIGHT-1:0] image_height,
    
    input  wire image_sender_full,  
    input  wire image_sender_empty, 
    
    //////////////////////////////////////////////////////////////////////////////////
    // DRAM Data Interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [DRAM_ADDR_WIDTH - 1:0] dram_read_addr,
    input  wire [7:0] dram_read_len,
    input  wire dram_read_en,
    input  wire dram_buffer_full,
    
    input  wire [DRAM_ADDR_WIDTH - 1:0] dram_write_addr,
    input  wire [7:0] dram_write_len,
    input  wire dram_write_en,
    input  wire [DRAM_DATA_WIDTH - 1:0] dram_write_data,
    
    output reg  [DRAM_DATA_WIDTH - 1:0] dram_read_data,
    output reg  dram_read_data_valid,
    output reg  dram_write_busy,
    output reg  dram_read_busy,
    output reg  irq_signal
);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 WRITE Address Space
//////////////////////////////////////////////////////////////////////////////////
localparam AXI_WRITE_FIFO        = AXI_ADDR_WIDTH'(7'h00);
localparam AXI_FLUSH_FIFO        = AXI_ADDR_WIDTH'(7'h10);
localparam AXI_WRITE_IMAGE_SIZE  = AXI_ADDR_WIDTH'(7'h20);
localparam AXI_WRITE_DATA_BUFFER = AXI_ADDR_WIDTH'(7'h30);
localparam AXI_WRITE_DATA_DONE   = AXI_ADDR_WIDTH'(7'h40);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 READ Address Space
//////////////////////////////////////////////////////////////////////////////////
localparam AXI_READ_DRAM_ADDR    = AXI_ADDR_WIDTH'(7'h00);
localparam AXI_READ_RESOLUTION   = AXI_ADDR_WIDTH'(7'h10);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write, Read FSM State & reg definition
//////////////////////////////////////////////////////////////////////////////////
localparam IDLE                  = 4'h0;
localparam WRITE_FIFO            = 4'h2;
localparam WRITE_FLUSH_FIFO      = 4'h3;
localparam WRITE_IMAGE_SIZE      = 4'h4;
localparam WRITE_DATA_BUFFER     = 4'h5;
localparam WRITE_DATA_DONE       = 4'h6;
localparam ERROR_STATE           = 4'h7;
localparam WRITE_RESPONSE        = 4'h8;

localparam READ_DRAM_ADDR        = 4'h1;
localparam READ_RESOLUTION       = 4'h2;
localparam READ_ERROR_STATE      = 4'h3;

reg[3:0] axi_state_write;
reg[3:0] axi_state_read;

//////////////////////////////////////////////////////////////////////////////////
// AXI Data Buffer
//////////////////////////////////////////////////////////////////////////////////
reg [AXI_ADDR_WIDTH - 1:0] axi_waddr;
reg [AXI_ADDR_WIDTH - 1:0] axi_waddr_base;
reg [7:0] axi_wlen;
reg [7:0] axi_wlen_counter;
reg [2:0] axi_wsize;
reg [7:0] axi_wshift_size;
reg [7:0] axi_wshift_count;
reg [AXI_STROBE_LEN - 1:0] axi_wunaligned_data_num;
reg [AXI_STROBE_LEN - 1:0] axi_wunaligned_count;
reg [1:0] axi_wburst;

reg [AXI_DATA_WIDTH - 1:0] axi_wdata;
reg [AXI_STROBE_WIDTH - 1:0] axi_wstrb;
reg axi_wvalid;
reg [15:0] axi_awid;
reg [15:0] axi_awuser;
reg axi_wlast;

reg [1:0] axi_arburst;
reg [7:0] axi_arlen;
reg [AXI_ADDR_WIDTH - 1:0] axi_araddr;
reg [2:0] axi_arsize;
reg [15:0] axi_arid;
reg [15:0] axi_aruser;

//////////////////////////////////////////////////////////////////////////////////
// Miscellaneous Data Buffer
//////////////////////////////////////////////////////////////////////////////////
reg dram_read_busy_buffer;  // This register buffer is used to set dram_read_busy 
                            //value in AXI IDLE to guarantee AXI write transaction is ended

//////////////////////////////////////////////////////////////////////////////////
// AXI4 FSM State initialization
// For simulation, each state was initiated to IDLE state.
//////////////////////////////////////////////////////////////////////////////////
initial begin
    axi_state_write <= IDLE;
    axi_state_read <= IDLE;
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Output Assign Logic
//////////////////////////////////////////////////////////////////////////////////

assign s_axi_awready = (axi_state_write == IDLE);
assign s_axi_wready  = ((axi_state_write == WRITE_FIFO) 
                        && (image_sender_full == 1'b0)) 
                        || (axi_state_write == WRITE_FLUSH_FIFO)
                        || (axi_state_write == WRITE_IMAGE_SIZE)
                        || (axi_state_write == WRITE_DATA_BUFFER)
                        || (axi_state_write == WRITE_DATA_DONE);
assign s_axi_arready = (axi_state_read == IDLE);
assign image_sender_reset = ~s_axi_aresetn;

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write FSM
// In AXI write, wlast signal has to be actived to end sending data. Note that 
// AXI transfer with only wlen signal does not work in below code.
//////////////////////////////////////////////////////////////////////////////////

always @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_write <= IDLE;
        s_axi_bresp <= 2'b0;
        s_axi_bvalid <= 1'b0;
        axi_waddr <= AXI_ADDR_WIDTH'(0);
        axi_waddr_base <= AXI_ADDR_WIDTH'(0);
        axi_wlen <= 8'h0;
        axi_wsize <= 3'h0;
        axi_wburst <= 2'h0;
        axi_wlen_counter <= 8'h0;
        axi_wunaligned_data_num <= 4'h0;
        axi_wunaligned_count <= 4'h0;
        axi_wshift_size <= 8'h0;
        axi_wshift_count <= 8'h0;
        s_axi_bid <= 16'h0; // id value
        axi_awid <= 16'h0;
        axi_awuser <= 16'h0;
        dram_read_busy <= 1'b0;
        dram_read_busy_buffer <= 1'b0;
        irq_signal <= 1'b0;
    end
    
    else begin
        case(axi_state_write)
            IDLE: begin
                s_axi_bid <= 16'h0; // id value
                image_sender_write <= 1'b0;
                image_sender_flush <= 1'b0;
                image_sender_fifo_din <= AXI_DATA_WIDTH'(0);
                s_axi_bresp <= 2'b0;
                s_axi_bvalid <= 1'b0;
                axi_awuser <= 16'h0;
                axi_awid <= 16'h0;
                dram_read_data_valid <= 1'b0;
                dram_read_busy <= dram_read_busy_buffer;
                
                if( dram_read_en == 1'b1 ) begin
                    dram_read_busy_buffer <= 1'b1;
                    dram_read_busy <= 1'b1;
                    irq_signal <= 1'b1;
                end
                
                if( s_axi_awvalid == 1'b1 ) begin
                    axi_waddr <= AXI_ADDR_WIDTH'(0);
                    axi_waddr_base <= AXI_ADDR_WIDTH'(0);
                    axi_wlen <= 8'h0;
                    axi_wsize <= 3'h0;
                    axi_wburst <= 2'h0;
                    axi_wlen_counter <= 8'h0;
                    axi_wunaligned_data_num <= 4'h0;
                    axi_wunaligned_count <= 4'h0;
                    axi_wshift_size <= 8'h0;
                    axi_wshift_count <= 8'h0;
                    
                    if( s_axi_awaddr == AXI_WRITE_FIFO ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awuser <= s_axi_awuser;
                        axi_awid <= s_axi_awid;
                        
                        if( image_sender_full == 1'b0 ) begin
                            axi_state_write <= WRITE_FIFO;
                        end
                        
                        else begin
                            axi_state_write <= WRITE_FIFO;
                        end
                    end
                    
                    else if( s_axi_awaddr == AXI_FLUSH_FIFO ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awuser <= s_axi_awuser;
                        axi_awid <= s_axi_awid;
                        
                        axi_state_write <= WRITE_FLUSH_FIFO;
                    end
                    
                    else if( s_axi_awaddr == AXI_WRITE_IMAGE_SIZE ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awuser <= s_axi_awuser;
                        axi_awid <= s_axi_awid;
                        
                        axi_state_write <= WRITE_IMAGE_SIZE;
                    end
                    
                    else if( s_axi_awaddr == AXI_WRITE_DATA_BUFFER ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awuser <= s_axi_awuser;
                        axi_awid <= s_axi_awid;
                        
                        axi_state_write <= WRITE_DATA_BUFFER;
                        
                    end
                    
                    else if( s_axi_awaddr == AXI_WRITE_DATA_DONE ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awuser <= s_axi_awuser;
                        axi_awid <= s_axi_awid;
                        
                        axi_state_write <= WRITE_DATA_DONE;
                    end
                    
                    else begin
                        axi_waddr <= AXI_ADDR_WIDTH'(0);
                        axi_waddr_base <= AXI_ADDR_WIDTH'(0);
                        axi_wlen <= 8'h0;
                        axi_wsize <= 3'h0;
                        axi_wburst <= 2'h0;
                        axi_wlen_counter <= 8'h0;
                        axi_wshift_size <= 8'h0;
                        axi_wshift_count <= 8'h0;
                        axi_state_write <= ERROR_STATE;
                        axi_awuser <= s_axi_awuser;
                        axi_awid <= s_axi_awid;
                    end
                end
                
                else begin
                    axi_waddr <= AXI_ADDR_WIDTH'(0);
                    axi_waddr_base <= AXI_ADDR_WIDTH'(0);
                    axi_wlen <= 8'h0;
                    axi_wsize <= 3'h0;
                    axi_wburst <= 2'h0;
                    axi_wlen_counter <= 8'h0;
                    axi_wshift_size <= 8'h0;
                    axi_wshift_count <= 8'h0;
                    axi_state_write <= IDLE;
                    axi_awuser <= 16'h0;
                    axi_awid <= 16'h0;
                end
            end
            
            WRITE_FIFO: begin
                if( image_sender_full == 1'b0 ) begin
                    if( s_axi_wvalid == 1'b1 ) begin
                        image_sender_fifo_din <= s_axi_wdata;
                        image_sender_write <= 1'b1;
                        if( s_axi_wlast == 1'b1 ) begin
                            axi_state_write <= WRITE_RESPONSE;
                        end
                    end
                    else begin
                        image_sender_fifo_din <= s_axi_wdata;
                        image_sender_write <= 1'b0;
                    end
                end
                else begin
                    image_sender_fifo_din <= AXI_DATA_WIDTH'(0);
                    image_sender_write <= 1'b0;
                end
            end
            WRITE_FLUSH_FIFO: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    if( s_axi_wdata[0] == 1'b1 ) begin
                        image_sender_flush <= 1'b1;
                    end
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            
            WRITE_IMAGE_SIZE: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    image_width <= BIT_WIDTH'(s_axi_wdata[63:32]);
                    image_height <= BIT_HEIGHT'(s_axi_wdata[31:0]);
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            
            WRITE_DATA_BUFFER : begin
                if( dram_buffer_full == 1'b0 ) begin
                    if( s_axi_wvalid == 1'b1 ) begin
                        dram_read_data <= s_axi_wdata;
                        dram_read_data_valid <= 1'b1;                          
                        irq_signal <= 1'b0;
                        if( s_axi_wlast == 1'b1 ) begin
                            axi_state_write <= WRITE_RESPONSE;
                            dram_read_data_valid <= 1'b0;  
                        end
                    end
                    else begin
                        dram_read_data <= s_axi_wdata;
                        dram_read_data_valid <= 1'b0;
                    end
                end
                else begin
                    dram_read_data <= AXI_DATA_WIDTH'(0);
                    dram_read_data_valid <= 1'b0;                          
                    irq_signal <= 1'b0;
                end
            end
            
            WRITE_DATA_DONE : begin
                if( s_axi_wvalid == 1'b1 ) begin
                    dram_read_busy_buffer <= 1'b0;
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            
            ERROR_STATE: begin
                if( s_axi_bready == 1'b1 ) begin
                    s_axi_bresp <= 2'b10;
                    s_axi_bvalid <= 1'b1;
                    axi_state_write <= IDLE;
                    s_axi_bid <= axi_awid;
                end
            end
            
            WRITE_RESPONSE: begin
                image_sender_write <= 1'b0;
                image_sender_fifo_din <= AXI_DATA_WIDTH'(0);
                if( s_axi_bready == 1'b1 ) begin
                    s_axi_bresp <= 2'b00;
                    s_axi_bvalid <= 1'b1;
                    axi_state_write <= IDLE;
                    s_axi_bid <= axi_awid;
                end
            end
        endcase
    end
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Read FSM
//////////////////////////////////////////////////////////////////////////////////
always @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_read <= IDLE;
        s_axi_rdata <= AXI_DATA_WIDTH'(0);
        s_axi_rresp <= 2'b0;
        s_axi_rvalid <= 1'b0;
        s_axi_rlast <= 1'b0;
        s_axi_rid <= 16'h0; // id value
        
        axi_arid <= 16'h0;
        axi_aruser <= 16'h0;
        axi_arburst <= 2'b0;
        axi_arlen <= 8'b0;
        axi_araddr <= AXI_DATA_WIDTH'(0);
        axi_arsize <= 3'b0;
        axi_arid <= 16'b0;
        axi_aruser <= 16'b0;
    end
    
    else begin
        case(axi_state_read)
            IDLE: begin
                s_axi_rdata <= AXI_DATA_WIDTH'(0);
                s_axi_rresp <= 2'b0;
                s_axi_rvalid <= 1'b0;
                s_axi_rlast <= 1'b0;
                s_axi_rid <= 16'h0; // id value

                axi_arid <= 16'h0;
                axi_aruser <= 16'h0;
                axi_arburst <= 2'b0;
                axi_arlen <= 8'b0;
                axi_araddr <= AXI_ADDR_WIDTH'(0);
                axi_arsize <= 3'b0;
                axi_arid <= 16'b0;
                axi_aruser <= 16'b0;

                if( s_axi_arvalid == 1'b1 ) begin
                    axi_arid <= s_axi_arid;
                    axi_aruser <= s_axi_aruser;
                    axi_arburst <= s_axi_arburst;
                    axi_arlen <= s_axi_arlen;
                    axi_araddr <= s_axi_araddr;
                    axi_arsize <= s_axi_arsize;
                    axi_arid <= s_axi_arid;
                    axi_aruser <= s_axi_aruser;
                    
                    if( s_axi_araddr == AXI_READ_DRAM_ADDR ) begin
                        axi_state_read <= READ_DRAM_ADDR;
                    end
                    else if( s_axi_araddr == AXI_READ_RESOLUTION ) begin
                        axi_state_read <= READ_RESOLUTION;
                    end
                    else begin
                        axi_state_read <= READ_ERROR_STATE;
                    end
                end
            end
            READ_DRAM_ADDR: begin
                s_axi_rdata <= {64'(dram_read_len), 64'(dram_read_addr)};
                s_axi_rresp <= 2'b00;
                s_axi_rvalid <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_arlen <= axi_arlen - 1;
                if( axi_arlen == 0 ) begin
                    axi_state_read <= IDLE;
                    s_axi_rlast <= 1'b1;
                end
            end
            
            READ_RESOLUTION: begin
                s_axi_rdata <= {64'(0), 32'(image_width), 32'(image_height)};
                s_axi_rresp <= 2'b00;
                s_axi_rvalid <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_arlen <= axi_arlen - 1;
                if( axi_arlen == 0 ) begin
                    axi_state_read <= IDLE;
                    s_axi_rlast <= 1'b1;
                end
            end

            READ_ERROR_STATE: begin
                s_axi_rdata <= AXI_DATA_WIDTH'(0);
                s_axi_rresp <= 2'b10;
                s_axi_rvalid <= 1'b1;
                s_axi_rlast <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_state_read <= IDLE;
            end
        endcase
    end
end


endmodule