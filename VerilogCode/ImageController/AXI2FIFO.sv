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
    parameter AXI_ADDR_WIDTH = 6,
    parameter AXI_DATA_WIDTH = 128,
    parameter AXI_STROBE_WIDTH = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN = 4, // LOG(AXI_STROBE_WDITH)
    parameter FIFO_DEPTH = 10
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Write
    //////////////////////////////////////////////////////////////////////////////////
    input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
    input wire [15:0] s_axi_awid, 
    input wire [1:0] s_axi_awburst,
    input wire [2:0] s_axi_awsize,
    input wire [7:0] s_axi_awlen,
    input wire s_axi_awvalid,
    input wire [15:0] s_axi_awuser, 
    output wire s_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Write Response
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_bready,
    output reg [1:0] s_axi_bresp,
    output reg s_axi_bvalid,
    output reg [15:0] s_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Write
    //////////////////////////////////////////////////////////////////////////////////
    input wire [AXI_DATA_WIDTH - 1:0] s_axi_wdata,
    input wire [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    input wire s_axi_wlast,
    output wire s_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Address Read
    //////////////////////////////////////////////////////////////////////////////////
    input wire [1:0] s_axi_arburst,
    input wire [7:0] s_axi_arlen,
    input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr,
    input wire [2:0] s_axi_arsize,
    input wire s_axi_arvalid,
    input wire [15:0] s_axi_arid,
    input wire [15:0] s_axi_aruser,
    output wire s_axi_arready,
    output reg [15:0] s_axi_rid,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Data Read
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_rready,
    output reg [AXI_DATA_WIDTH - 1:0] s_axi_rdata,
    output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid,
    output reg s_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Clock
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Reset
    //////////////////////////////////////////////////////////////////////////////////
    input wire s_axi_aresetn,
    
    //////////////////////////////////////////////////////////////////////////////////
    // RTO_Core interface
    //////////////////////////////////////////////////////////////////////////////////
    output reg rto_core_reset,                      // pixel_clk region
    output reg rto_core_flush,                      // pixel_clk region
    output wire rto_core_write,                     // pixel_clk region
    output wire [127:0] rto_core_fifo_din,          // pixel_clk region
    
    input wire rto_core_full,                       // pixel_clk region
    input wire rto_core_empty,                      // pixel_clk region
   
    //////////////////////////////////////////////////////////////////////////////////
    // RTI_Core interface
    //////////////////////////////////////////////////////////////////////////////////
    output reg rti_core_reset,
    output wire rti_core_rd_en,
    output reg rti_core_flush,

    input wire [127:0] rti_core_fifo_dout,
    input wire rti_core_full,
    input wire rti_core_empty,
    input wire [FIFO_DEPTH - 1:0] data_num,
    
    //////////////////////////////////////////////////////////////////////////////////
    // Clock Domain Crossing Interface
    //////////////////////////////////////////////////////////////////////////////////
    input wire rtio_clk
);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 WRITE Address Space
//////////////////////////////////////////////////////////////////////////////////
parameter AXI_WRITE_FIFO        = {AXI_ADDR_WIDTH{1'b0}};
parameter AXI_FLUSH_FIFO        = {AXI_ADDR_WIDTH{1'b0}} + 6'h10;

//////////////////////////////////////////////////////////////////////////////////
// AXI4 READ Address Space
//////////////////////////////////////////////////////////////////////////////////
parameter AXI_READ_ISEMPTY      = {AXI_ADDR_WIDTH{1'b0}} + 6'h10;
parameter AXI_READ_FIFO         = {AXI_ADDR_WIDTH{1'b0}};

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write, Read FSM State & reg definition
//////////////////////////////////////////////////////////////////////////////////

parameter IDLE                  = 4'h0;
parameter WRITE_DATA_WRITE_FIFO = 4'h2;
parameter WRITE_DATA_FLUSH_FIFO = 4'h3;
parameter ERROR_STATE           = 4'h4;
parameter WRITE_RESPONSE        = 4'h5;

parameter READ_DATA             = 4'h2;
parameter READ_ISEMPTY              = 4'h3;
parameter READ_ERROR_STATE      = 4'h5;

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
assign s_axi_wready = ((axi_state_write == WRITE_DATA_WRITE_FIFO) && (async_fifo_out_full == 1'b0)) || (axi_state_write == WRITE_DATA_FLUSH_FIFO);
assign s_axi_arready = (axi_state_read == IDLE);


//////////////////////////////////////////////////////////////////////////////////
// Asyncrhonous fifo for CDC (s_aclk -> rtio_clk)
//////////////////////////////////////////////////////////////////////////////////
wire async_fifo_out_full;               // s_aclk region
wire async_fifo_out_empty;              // pixel_clk region
wire [127:0] async_fifo_out_dout;       // pixel_clk region
reg [127:0] async_fifo_out_din;         // s_aclk region
reg async_fifo_out_write;               // s_aclk region
reg async_rto_core_flush;               // s_aclk region
reg rto_core_flush_buffer1;             // pixel_clk region
reg rto_core_flush_buffer2;             // pixel_clk region
reg async_rto_core_reset;               // s_aclk region
reg rto_core_reset_buffer1;             // pixel_clk region
reg rto_core_reset_buffer2;             // pixel_clk region

assign rto_core_write = (~rto_core_full) & (~async_fifo_out_empty);
assign rto_core_fifo_din = async_fifo_out_dout;

fifo_generator_1 async_fifo_out( // 512 depth, 504 program full
    .wr_clk(s_axi_aclk),
    .rd_clk(rtio_clk),
    .srst(async_rto_core_flush | async_rto_core_reset),  // rst -> srst in Vivado 2020.2
    .din(async_fifo_out_din),
    .wr_en(async_fifo_out_write),
    .rd_en((~rto_core_full) & (~async_fifo_out_empty)),
    .dout(async_fifo_out_dout),
    .prog_full(async_fifo_out_full),  // full -> prog_full to deal with full delay signal
    .overflow(),
    .empty(async_fifo_out_empty),
    .underflow()
);

always @(posedge rtio_clk) begin
    {rto_core_flush, rto_core_flush_buffer2, rto_core_flush_buffer1} <= {rto_core_flush_buffer2, rto_core_flush_buffer1, async_rto_core_flush};
    {rto_core_reset, rto_core_reset_buffer2, rto_core_reset_buffer1} <= {rto_core_reset_buffer2, rto_core_reset_buffer1, async_rto_core_reset};
end

//////////////////////////////////////////////////////////////////////////////////
// Asyncrhonous fifo for CDC (rtio_clk -> s_aclk)
//////////////////////////////////////////////////////////////////////////////////
wire async_fifo_in_full;
wire [127:0] async_fifo_in_dout;
wire async_fifo_in_empty;
reg async_fifo_in_rd_en;
reg async_rti_core_reset;
reg rti_core_reset_buffer1;
reg rti_core_reset_buffer2;
reg async_rti_core_flush;
reg rti_core_flush_buffer1;
reg rti_core_flush_buffer2;


assign rti_core_rd_en = (~rti_core_empty) & (~async_fifo_in_full);

fifo_generator_1 async_fifo_in( // 512 depth, 504 program full
    .wr_clk(rtio_clk),
    .rd_clk(s_axi_aclk),
    .srst(rti_core_reset | rti_core_flush),  // rst -> srst in Vivado 2020.2
    .din(rti_core_fifo_dout),
    .wr_en((~rti_core_empty) & (~async_fifo_in_full)),
    .rd_en(async_fifo_in_rd_en),
    .dout(async_fifo_in_dout),
    .prog_full(async_fifo_in_full),  // full -> prog_full to deal with full delay signal
    .overflow(),
    .empty(async_fifo_in_empty),
    .underflow()
);

always @(posedge rtio_clk) begin
    {rti_core_flush, rti_core_flush_buffer2, rti_core_flush_buffer1} <= {rti_core_flush_buffer2, rti_core_flush_buffer1, async_rti_core_flush};
    {rti_core_reset, rti_core_reset_buffer2, rti_core_reset_buffer1} <= {rti_core_reset_buffer2, rti_core_reset_buffer1, async_rti_core_reset};
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write FSM
// In AXI write, wlast signal has to be actived to end sending data. Only sending
// length of AXI signal does not work in below code.
//////////////////////////////////////////////////////////////////////////////////

always @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_write <= IDLE;
        s_axi_bresp <= 2'b0;
        s_axi_bvalid <= 1'b0;
        axi_waddr <= {AXI_ADDR_WIDTH{1'b0}};
        axi_waddr_base <= {AXI_ADDR_WIDTH{1'b0}};
        axi_wlen <= 8'h0;
        axi_wsize <= 3'h0;
        axi_wburst <= 2'h0;
        axi_wlen_counter <= 8'h0;
        axi_wunaligned_data_num <= 4'h0;
        axi_wunaligned_count <= 4'h0;
        axi_wshift_size <= 8'h0;
        axi_wshift_count <= 8'h0;
        s_axi_bid <= 16'h0; // id value
        async_fifo_out_din <= 128'h0;
        async_rto_core_flush <= 1'b0;
        async_rti_core_flush <= 1'b0;
        axi_awid <= 16'h0;
        axi_awuser <= 16'h0;
    end
    
    else begin
        case(axi_state_write)
            IDLE: begin
                s_axi_bid <= 16'h0; // id value
                async_fifo_out_write <= 1'b0;
                async_rto_core_flush <= 1'b0;
                async_rti_core_flush <= 1'b0;
                async_fifo_out_din <= 128'h0;
                s_axi_bresp <= 2'b0;
                s_axi_bvalid <= 1'b0;
                axi_awuser <= 16'h0;
                axi_awid <= 16'h0;
                
                if( s_axi_awvalid == 1'b1 ) begin
                    axi_waddr <= {AXI_ADDR_WIDTH{1'b0}};
                    axi_waddr_base <= {AXI_ADDR_WIDTH{1'b0}};
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
                        
                        if( async_fifo_out_full == 1'b0 ) begin
                            axi_state_write <= WRITE_DATA_WRITE_FIFO;
                        end
                        
                        else begin
                            axi_state_write <= WRITE_DATA_WRITE_FIFO;
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
                        
                        axi_state_write <= WRITE_DATA_FLUSH_FIFO;
                    end
                    
                    else begin
                        axi_waddr <= {AXI_ADDR_WIDTH{1'b0}};
                        axi_waddr_base <= {AXI_ADDR_WIDTH{1'b0}};
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
                    axi_waddr <= {AXI_ADDR_WIDTH{1'b0}};
                    axi_waddr_base <= {AXI_ADDR_WIDTH{1'b0}};
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
            
            WRITE_DATA_WRITE_FIFO: begin
                if( async_fifo_out_full == 1'b0 ) begin
                    if( s_axi_wvalid == 1'b1 ) begin
                        async_fifo_out_din <= s_axi_wdata;
                        async_fifo_out_write <= 1'b1;
                        if( s_axi_wlast == 1'b1 ) begin
                            axi_state_write <= WRITE_RESPONSE;
                        end
                    end
                    else begin
                        async_fifo_out_din <= s_axi_wdata;
                        async_fifo_out_write <= 1'b0;
                    end
                end
                else begin
                    async_fifo_out_din <= 128'h0;
                    async_fifo_out_write <= 1'b0;
                end
            end
            WRITE_DATA_FLUSH_FIFO: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    if( s_axi_wdata[0] == 1'b1 ) begin
                        async_rto_core_flush <= 1'b1;
                    end
                    if( s_axi_wdata[1] == 1'b1 ) begin
                        async_rti_core_flush <= 1'b1;
                    end
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
                async_fifo_out_write <= 1'b0;
                async_fifo_out_din <= 128'h0;
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

reg [15:0] axi_arid;
reg [15:0] axi_aruser;

always @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_read <= IDLE;
        s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
        s_axi_rresp <= 2'b0;
        s_axi_rvalid <= 1'b0;
        s_axi_rlast <= 1'b0;
        s_axi_rid <= 16'h0; // id value
        
        axi_arid <= 16'h0;
        axi_aruser <= 16'h0;
        axi_arburst <= 2'b0;
        axi_arlen <= 8'b0;
        axi_araddr <= {AXI_ADDR_WIDTH{1'b0}};
        axi_arsize <= 3'b0;
        axi_arid <= 16'b0;
        axi_aruser <= 16'b0;

        async_fifo_in_rd_en <= 1'b0;
    end
    
    else begin
        case(axi_state_read)
            IDLE: begin
                s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
                s_axi_rresp <= 2'b0;
                s_axi_rvalid <= 1'b0;
                s_axi_rlast <= 1'b0;
                s_axi_rid <= 16'h0; // id value

                axi_arid <= 16'h0;
                axi_aruser <= 16'h0;
                axi_arburst <= 2'b0;
                axi_arlen <= 8'b0;
                axi_araddr <= {AXI_ADDR_WIDTH{1'b0}};
                axi_arsize <= 3'b0;
                axi_arid <= 16'b0;
                axi_aruser <= 16'b0;
        
                async_fifo_in_rd_en <= 1'b0;


                if( s_axi_arvalid == 1'b1 ) begin
                    axi_arid <= s_axi_arid;
                    axi_aruser <= s_axi_aruser;
                    axi_arburst <= s_axi_arburst;
                    axi_arlen <= s_axi_arlen;
                    axi_araddr <= s_axi_araddr;
                    axi_arsize <= s_axi_arsize;
                    axi_arid <= s_axi_arid;
                    axi_aruser <= s_axi_aruser;
                    
                    if( s_axi_araddr == AXI_READ_ISEMPTY ) begin
                        axi_state_read <= READ_ISEMPTY;
                    end
                    else if( s_axi_araddr == AXI_READ_FIFO ) begin
                        if( async_fifo_in_empty == 1'b1 ) begin
                            axi_state_read <= READ_ERROR_STATE;
                        end
                        else begin                            
                            async_fifo_in_rd_en <= 1'b1;
                            axi_state_read <= READ_DATA;
                        end

                    end
                    else begin
                        axi_state_read <= READ_ERROR_STATE;
                    end
                end
            end
            READ_DATA: begin
                s_axi_rdata <= async_fifo_in_dout;
                s_axi_rresp <= 2'b0;
                s_axi_rvalid <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_arlen <= axi_arlen - 1;
                if( axi_arlen == 0 ) begin
                    axi_state_read <= IDLE;
                    async_fifo_in_rd_en <= 1'b0;
                    s_axi_rlast <= 1'b1;
                end
            end

            READ_ISEMPTY: begin
                s_axi_rdata <= { {(AXI_DATA_WIDTH-1){1'b0}}, async_fifo_in_empty };
                s_axi_rresp <= 2'b0;
                s_axi_rvalid <= 1'b1;
                s_axi_rlast <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_state_read <= IDLE;
            end

            READ_ERROR_STATE: begin
                s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
                s_axi_rresp <= 2'b10;
                s_axi_rvalid <= 1'b1;
                s_axi_rlast <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_state_read <= IDLE;
            end
        endcase
    end
end


//////////////////////////////////////////////////////////////////////////////////
// AXI4 Reset
//////////////////////////////////////////////////////////////////////////////////

always @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        async_rto_core_reset <= 1'b1;
        async_rti_core_reset <= 1'b1;
    end
    else begin
        async_rto_core_reset <= 1'b0;
        async_rti_core_reset <= 1'b0;
    end
end

endmodule