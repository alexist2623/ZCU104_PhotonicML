`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/18 16:37:21
// Design Name: 
// Module Name: AXI2COM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 128 bit slave AXI4 to command
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI2COM
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH = 6,
    parameter AXI_DATA_WIDTH = 128,
    parameter AXI_STROBE_WIDTH = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN = 4 // LOG(AXI_STROBE_WDITH)
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
    input wire [15:0] s_axi_awuser, // added to resolve wrapping error
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
    input wire [15:0] s_axi_arid, // added to resolve wrapping error
    input wire [15:0] s_axi_aruser, // added to resolve wrapping error
    output wire s_axi_arready,
    output reg [15:0] s_axi_rid, // added to resolve wrapping error
    
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
    // Timestamp Interface
    //////////////////////////////////////////////////////////////////////////////////
    output reg reset,
    output reg start,
    output reg [63:0] counter_offset,
    output reg offset_en,
    output reg auto_start
);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Address Space
//////////////////////////////////////////////////////////////////////////////////
parameter AXI_WRITE_COMMAND = {AXI_ADDR_WIDTH{1'b0}};
parameter AXI_WRITE_OFFSET = {AXI_ADDR_WIDTH{1'b0}} + 6'h10;

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write, Read FSM State & reg definition
//////////////////////////////////////////////////////////////////////////////////

parameter IDLE = 4'h0;
parameter WRITE_ADDRESS = 4'h1;
parameter WRITE_COMMAND = 4'h2;
parameter WRITE_OFFSET = 4'h3;
parameter ERROR_STATE = 4'h6;
parameter WRITE_RESPONSE = 4'h7;

parameter READ_ADDRESS = 4'h1;
parameter READ_DATA = 4'h2;

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
assign s_axi_wready = (axi_state_write == WRITE_COMMAND) || (axi_state_write == WRITE_OFFSET);
assign s_axi_arready = (axi_state_read == IDLE);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write FSM
// In AXI write, wlast signal has to be actived to end sending data. Only sending
// length of AXI signal does not work.
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
        axi_awid <= 16'h0;
        axi_awuser <= 16'h0;
        
        reset <= 1'b1;
        start <= 1'b0;
        counter_offset <= 64'h0;
        offset_en <= 1'b0;
        auto_start <= 1'b0;
    end
    
    else begin
        case(axi_state_write)
            IDLE: begin
                s_axi_bresp <= 2'b0;
                s_axi_bvalid <= 1'b0;
                axi_awid <= 16'h0;
                axi_awuser <= 16'h0;
                s_axi_bid <= 16'h0; // id value
                
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
                    
                    if( s_axi_awaddr == AXI_WRITE_COMMAND ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awid <= s_axi_awid;
                        axi_awuser <= s_axi_awuser;
                        
                        axi_state_write <= WRITE_COMMAND;
                    end
                    
                    else if( s_axi_awaddr == WRITE_OFFSET ) begin
                        axi_waddr <= s_axi_awaddr;
                        axi_waddr_base <= s_axi_awaddr;
                        axi_wlen <= s_axi_awlen;
                        axi_wsize <= s_axi_awsize;
                        axi_wburst <= s_axi_awburst;
                        axi_wlen_counter <= s_axi_awlen;
                        axi_wshift_size <= 8'h1 << s_axi_awsize;
                        axi_wshift_count <= 8'h0;
                        axi_awid <= s_axi_awid;
                        axi_awuser <= s_axi_awuser;
                        
                        axi_state_write <= WRITE_OFFSET;
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
                        axi_awid <= s_axi_awid;
                        axi_awuser <= s_axi_awuser;
                        axi_state_write <= ERROR_STATE;
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
                    axi_awid <= 16'h0;
                    axi_awuser <= 16'h0;
                    axi_state_write <= IDLE;
                end
            end
            
            WRITE_COMMAND: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    start <= s_axi_wdata[0];
                    reset <= s_axi_wdata[1];
                    offset_en <= s_axi_wdata[2];
                    auto_start <= s_axi_wdata[3];
                    
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            WRITE_OFFSET: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    counter_offset <= s_axi_wdata[63:0];
                    
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            
            ERROR_STATE: begin
                if( s_axi_bready == 1'b1 ) begin
                    s_axi_bresp <= 2'b10;
                    s_axi_bvalid <= 1'b1;
                    s_axi_bid <= axi_awid;
                    axi_state_write <= IDLE;
                end
            end
            
            WRITE_RESPONSE: begin
                if( s_axi_bready == 1'b1 ) begin
                    s_axi_bresp <= 2'b00;
                    s_axi_bvalid <= 1'b1;
                    s_axi_bid <= axi_awid;
                    axi_state_write <= IDLE;
                end
            end
        endcase
    end
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Read FSM
// AXI read only gives zero data to master from slave
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
    end
    
    else begin
        s_axi_rid <= 16'h0; // id value
        axi_arid <= 16'h0;
        axi_aruser <= 16'h0;
        
        case(axi_state_read)
            IDLE: begin
                s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
                s_axi_rresp <= 2'b0;
                s_axi_rvalid <= 1'b0;
                s_axi_rlast <= 1'b0;
                if( s_axi_arvalid == 1'b1 ) begin
                    axi_state_read <= READ_DATA;
                    axi_arid <= s_axi_arid;
                    axi_aruser <= s_axi_aruser;
                end
            end
            READ_DATA: begin
                if( s_axi_rready == 1'b1 ) begin
                    s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
                    s_axi_rresp <= 2'b0;
                    s_axi_rvalid <= 1'b1;
                    s_axi_rlast <= 1'b1;
                    s_axi_rid <= axi_arid;
                    axi_state_read <= IDLE;
                end
            end
        endcase
    end
end

endmodule