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


module DRAM_Controller
#(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    parameter AXI_ADDR_WIDTH                    = 6,
    parameter AXI_DATA_WIDTH                    = 128,
    parameter AXI_STROBE_WIDTH                  = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                    = 4 // LOG(AXI_STROBE_WDITH)
)
(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Write
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [AXI_ADDR_WIDTH - 1:0] m_axi_awaddr,
    output  reg [15:0] m_axi_awid, 
    output  reg [1:0] m_axi_awburst,
    output  reg [2:0] m_axi_awsize,
    output  reg [7:0] m_axi_awlen,
    output  reg m_axi_awvalid,
    output  reg [15:0] m_axi_awuser, // added to resolve wrapping error
    input  wire m_axi_awready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Write Response
    //////////////////////////////////////////////////////////////////////////////////
    output  reg m_axi_bready,
    input  wire [1:0] m_axi_bresp,
    input  wire m_axi_bvalid,
    input  wire [15:0] m_axi_bid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Data Write
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [AXI_DATA_WIDTH - 1:0] m_axi_wdata,
    output  reg [AXI_STROBE_WIDTH - 1:0] m_axi_wstrb,
    output  reg m_axi_wvalid,
    output  reg m_axi_wlast,
    input  wire m_axi_wready,                                                        //Note that ready signal is wire
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Address Read
    //////////////////////////////////////////////////////////////////////////////////
    output  reg [1:0] m_axi_arburst,
    output  reg [7:0] m_axi_arlen,
    output  reg [AXI_ADDR_WIDTH - 1:0] m_axi_araddr,
    output  reg [2:0] m_axi_arsize,
    output  reg m_axi_arvalid,
    output  reg [15:0] m_axi_arid, // added to resolve wrapping error
    output  reg [15:0] m_axi_aruser, // added to resolve wrapping error
    input  wire m_axi_arready,
    input  wire [15:0] m_axi_rid, // added to resolve wrapping error
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Data Read
    //////////////////////////////////////////////////////////////////////////////////
    output reg  m_axi_rready,
    input  wire [AXI_DATA_WIDTH - 1:0] m_axi_rdata,
    input  wire [1:0] m_axi_rresp,
    input  wire m_axi_rvalid,
    input  wire m_axi_rlast,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Clock
    //////////////////////////////////////////////////////////////////////////////////
    input  wire m_axi_aclk,
    
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Master Reset
    //////////////////////////////////////////////////////////////////////////////////
    input  wire m_axi_aresetn,
    
    //////////////////////////////////////////////////////////////////////////////////
    // DMA Data Interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_DATA_WIDTH - 1:0] mm2s_addr,
    input  wire [AXI_DATA_WIDTH - 1:0] mm2s_len,
    input  wire mm2s_en,
    input  wire [AXI_DATA_WIDTH - 1:0] s2mm_addr,
    input  wire [AXI_DATA_WIDTH - 1:0] s2mm_len,
    input  wire s2mm_en,
    output  reg dram_controller_busy
);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 WRITE Address Space
//////////////////////////////////////////////////////////////////////////////////
localparam AXI_MM2S_DMACR        = AXI_ADDR_WIDTH'h00;
localparam AXI_MM2S_DMASR        = AXI_ADDR_WIDTH'h04;
localparam AXI_MM2S_SA           = AXI_ADDR_WIDTH'h18;
localparam AXI_MM2S_SA_MSB       = AXI_ADDR_WIDTH'h1C;
localparam AXI_MM2S_LENGTH       = AXI_ADDR_WIDTH'h28;

localparam AXI_S2MM_DMACR        = AXI_ADDR_WIDTH'h30;
localparam AXI_S2MM_DMASR        = AXI_ADDR_WIDTH'h34;
localparam AXI_S2MM_DA           = AXI_ADDR_WIDTH'h48;
localparam AXI_S2MM_DA_MSB       = AXI_ADDR_WIDTH'h4C;
localparam AXI_S2MM_LENGTH       = AXI_ADDR_WIDTH'h58;

//////////////////////////////////////////////////////////////////////////////////
// AXI4 READ Address Space
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write, Read FSM State & reg definition
// Note that MM2S is Memory Mapped to Stream
// and S2MM is Stream to Memory Mapped
//////////////////////////////////////////////////////////////////////////////////
localparam AXI_STATE_LEN         = 6;
localparam IDLE                  = AXI_STATE_LEN'h0;
localparam WRITE_MM2S_DMACR      = AXI_STATE_LEN'h1;
localparam WRITE_MM2S_DMASR      = AXI_STATE_LEN'h2;
localparam WRITE_MM2S_SA         = AXI_STATE_LEN'h3;
localparam WRITE_MM2S_SA_MSB     = AXI_STATE_LEN'h4;
localparam WRITE_MM2S_LENGTH     = AXI_STATE_LEN'h5;
localparam WRITE_S2MM_DMACR      = AXI_STATE_LEN'h6;
localparam WRITE_S2MM_DMASR      = AXI_STATE_LEN'h7;
localparam WRITE_S2MM_DA         = AXI_STATE_LEN'h8;
localparam WRITE_S2MM_DA_MSB     = AXI_STATE_LEN'h9;
localparam WRITE_S2MM_LENGTH     = AXI_STATE_LEN'ha;

localparam WRITE_MM2S_DMACR_WDATA = AXI_STATE_LEN'h11;
localparam WRITE_MM2S_DMASR_WDATA = AXI_STATE_LEN'h12;
localparam WRITE_MM2S_SA_WDATA    = AXI_STATE_LEN'h13;
localparam WRITE_MM2S_SA_MSB_WDATA= AXI_STATE_LEN'h14;
localparam WRITE_MM2S_LENGTH_WDATA= AXI_STATE_LEN'h15;
localparam WRITE_S2MM_DMACR_WDATA = AXI_STATE_LEN'h16;
localparam WRITE_S2MM_DMASR_WDATA = AXI_STATE_LEN'h17;
localparam WRITE_S2MM_DA_WDATA    = AXI_STATE_LEN'h18;
localparam WRITE_S2MM_DA_MSB_WDATA= AXI_STATE_LEN'h19;
localparam WRITE_S2MM_LENGTH_WDATA= AXI_STATE_LEN'h1a;

localparam WRITE_MM2S_DMACR_RESP = AXI_STATE_LEN'h21;
localparam WRITE_MM2S_DMASR_RESP = AXI_STATE_LEN'h22;
localparam WRITE_MM2S_SA_RESP    = AXI_STATE_LEN'h23;
localparam WRITE_MM2S_SA_MSB_RESP= AXI_STATE_LEN'h24;
localparam WRITE_MM2S_LENGTH_RESP= AXI_STATE_LEN'h25;
localparam WRITE_S2MM_DMACR_RESP = AXI_STATE_LEN'h26;
localparam WRITE_S2MM_DMASR_RESP = AXI_STATE_LEN'h27;
localparam WRITE_S2MM_DA_RESP    = AXI_STATE_LEN'h28;
localparam WRITE_S2MM_DA_MSB_RESP= AXI_STATE_LEN'h29;
localparam WRITE_S2MM_LENGTH_RESP= AXI_STATE_LEN'h2a;

localparam ERROR_STATE           = AXI_STATE_LEN'hc;

reg [AXI_STATE_LEN - 1:0] axi_state_write;
reg [AXI_STATE_LEN - 1:0] axi_state_read;

//////////////////////////////////////////////////////////////////////////////////
// AXI Data Buffer
//////////////////////////////////////////////////////////////////////////////////
reg [AXI_DATA_WIDTH - 1:0] axi_mm2s_addr;
reg [AXI_DATA_WIDTH - 1:0] axi_mm2s_len;
reg [AXI_DATA_WIDTH - 1:0] axi_s2mm_addr;
reg [AXI_DATA_WIDTH - 1:0] axi_s2mm_len;
    
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


//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write FSM
// In AXI write, wlast signal has to be actived to end sending data. Note that 
// AXI transfer with only wlen signal does not work in below code.
//////////////////////////////////////////////////////////////////////////////////

always @(posedge m_axi_aclk) begin
    if( m_axi_aresetn == 1'b0 ) begin
        axi_state_write <= IDLE;
        m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
        m_axi_awid <= 16'h0; 
        m_axi_awburst <= 2'h0;
        m_axi_awsize <= 3'h0;
        m_axi_awlen <= 8'h0;
        m_axi_awvalid <= 1'b0;
        m_axi_awuser <= 16'h0; // added to resolve wrapping error
        m_axi_bready <= 1'b0;
        m_axi_wdata <= AXI_DATA_WIDTH'h0;
        m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
        m_axi_wvalid <= 1'b0;
        m_axi_wlast <= 1'b0;
        
        dram_controller_busy <= 1'b0;
    end
    
    else begin
        case(axi_state_write)
            IDLE: begin
                axi_state_write <= IDLE;
                m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                m_axi_awid <= 16'h0; 
                m_axi_awburst <= 2'h0;
                m_axi_awsize <= 3'h0;
                m_axi_awlen <= 8'h0;
                m_axi_awvalid <= 1'b0;
                m_axi_awuser <= 16'h0; // added to resolve wrapping error
                m_axi_bready <= 1'b0;
                m_axi_wdata <= AXI_DATA_WIDTH'h0;
                m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                m_axi_wvalid <= 1'b0;
                m_axi_wlast <= 1'b0;
                
                dram_controller_busy <= 1'b0;
                
                if( mm2s_en == 1'b1 )begin
                    axi_state_write <= WRITE_MM2S_DMACR;
                    axi_s2mm_addr <= s2mm_addr;
                    axi_s2mm_len <= s2mm_len;
                    dram_controller_busy <= 1'b1;
                    
                    m_axi_awaddr <= AXI_MM2S_DMACR;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b010; // 4 byte data
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b1;
                    m_axi_awuser <= 16'h0;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h7001;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'hf;
                    m_axi_wlast <= 1'b1;
                    m_axi_wvalid <= 1'b1;
                    
                    m_axi_bready <= 1'b1;
                end
                
                else if( s2mm_en == 1'b1 )begin
                    axi_state_write <= WRITE_S2MM_DMACR;
                    axi_s2mm_addr <= s2mm_addr;
                    axi_s2mm_len <= s2mm_len;
                    dram_controller_busy <= 1'b1;
                    
                    m_axi_awaddr <= AXI_S2MM_DMACR;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b010; // 4 byte data
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b1;
                    m_axi_awuser <= 16'h0;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h80;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'hf;
                    m_axi_wlast <= 1'b1;
                    m_axi_wvalid <= 1'b1;
                    
                    m_axi_bready <= 1'b1;
                end
            end
            //////////////////////////////////////////////////////////////////////////////////
            // MM2S Write
            //////////////////////////////////////////////////////////////////////////////////
            WRITE_MM2S_DMACR: begin
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_M2SS_DMACR_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            WRITE_MM2S_DMASR: begin
                
            end
            WRITE_MM2S_SA: begin
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_MM2S_SA_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            WRITE_MM2S_SA_MSB: begin
                
            end
            WRITE_MM2S_LENGTH: begin
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_MM2S_LENGTH_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            //////////////////////////////////////////////////////////////////////////////////
            // S2MM Write
            //////////////////////////////////////////////////////////////////////////////////
            WRITE_S2MM_DMACR: begin
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_S2MM_DMACR_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            WRITE_S2MM_DMASR: begin
                
            end
            WRITE_S2MM_DA: begin               
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_S2MM_DA_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            WRITE_S2MM_DA_MSB: begin
                
            end
            WRITE_S2MM_LENGTH: begin
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_S2MM_LENGTH_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // MM2S Write Data
            //////////////////////////////////////////////////////////////////////////////////
            
            WRITE_MM2S_DMACR_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_MM2S_DMACR_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h0;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            WRITE_MM2S_DMASR_WDATA: begin
                
            end
            WRITE_MM2S_SA_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_MM2S_SA_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h0;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            WRITE_MM2S_SA_MSB_WDATA: begin
                
            end
            WRITE_MM2S_LENGTH_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_MM2S_LENGTH_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h0;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // S2MM Write Data
            //////////////////////////////////////////////////////////////////////////////////
            WRITE_S2MM_DMACR_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_S2MM_DMACR_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h0;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            WRITE_S2MM_DMASR_WDATA: begin
                
            end
            WRITE_S2MM_DA_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_S2MM_DA_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h0;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            WRITE_S2MM_DA_MSB_WDATA: begin
                
            end
            WRITE_S2MM_LENGTH_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_S2MM_LENGTH_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'h0;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // MM2S Response
            //////////////////////////////////////////////////////////////////////////////////
            
            WRITE_MM2S_DMACR_RESP: begin
                if( m_axi_bvalid == 1'b1 ) begin
                    m_axi_bready <= 1'b0;
                    if( m_axi_bresp == 2'b00 ) begin
                        axi_state_write <= WRITE_MM2S_SA;
                        
                        m_axi_awaddr <= AXI_MM2S_DA;
                        m_axi_awid <= 16'h0; 
                        m_axi_awburst <= 2'h0;
                        m_axi_awsize <= 3'b010; // 4 byte data
                        m_axi_awlen <= 8'h0;
                        m_axi_awvalid <= 1'b1;
                        m_axi_awuser <= 16'h0;
                                            
                        m_axi_wdata <= axi_mm2s_addr;
                        m_axi_wstrb <= AXI_STROBE_WIDTH'hf;
                        m_axi_wlast <= 1'b1;
                        m_axi_wvalid <= 1'b1;
                        
                        m_axi_bready <= 1'b1;
                    end
                    else begin
                        axi_state_write <= ERROR_STATE;
                    end
                end
            end
            WRITE_MM2S_DMASR_RESP: begin
                
            end
            WRITE_MM2S_SA_RESP: begin
                if( m_axi_bvalid == 1'b1 ) begin
                    m_axi_bready <= 1'b0;
                    if( m_axi_bresp == 2'b00 ) begin
                        axi_state_write <= WRITE_MM2S_LENGTH;
                        
                        m_axi_awaddr <= AXI_MM2S_LENGTH;
                        m_axi_awid <= 16'h0; 
                        m_axi_awburst <= 2'h0;
                        m_axi_awsize <= 3'b010; // 4 byte data
                        m_axi_awlen <= 8'h0;
                        m_axi_awvalid <= 1'b1;
                        m_axi_awuser <= 16'h0;
                                            
                        m_axi_wdata <= axi_mm2s_len;
                        m_axi_wstrb <= AXI_STROBE_WIDTH'hf;
                        m_axi_wlast <= 1'b1;
                        m_axi_wvalid <= 1'b1;
                        
                        m_axi_bready <= 1'b1;
                    end
                    else begin
                        axi_state_write <= ERROR_STATE;
                    end
                end
            end
            WRITE_MM2S_SA_MSB_RESP: begin
                
            end
            WRITE_MM2S_LENGTH_RESP: begin
                if( m_axi_bvalid == 1'b1 ) begin
                    m_axi_bready <= 1'b0;
                    if( m_axi_bresp == 2'b00 ) begin
                        axi_state_write <= IDLE;
                    end
                    else begin
                        axi_state_write <= ERROR_STATE;
                    end
                end
            end
            
            
            //////////////////////////////////////////////////////////////////////////////////
            // S2MM Response
            //////////////////////////////////////////////////////////////////////////////////
            
            WRITE_S2MM_DMACR_RESP: begin
                if( m_axi_bvalid == 1'b1 ) begin
                    m_axi_bready <= 1'b0;
                    if( m_axi_bresp == 2'b00 ) begin
                        axi_state_write <= WRITE_S2MM_DA;
                        
                        m_axi_awaddr <= AXI_S2MM_DA;
                        m_axi_awid <= 16'h0; 
                        m_axi_awburst <= 2'h0;
                        m_axi_awsize <= 3'b010; // 4 byte data
                        m_axi_awlen <= 8'h0;
                        m_axi_awvalid <= 1'b1;
                        m_axi_awuser <= 16'h0;
                                            
                        m_axi_wdata <= axi_s2mm_addr;
                        m_axi_wstrb <= AXI_STROBE_WIDTH'hf;
                        m_axi_wlast <= 1'b1;
                        m_axi_wvalid <= 1'b1;
                        
                        m_axi_bready <= 1'b1;
                    end
                    else begin
                        axi_state_write <= ERROR_STATE;
                    end
                end
            end
            WRITE_S2MM_DMASR_RESP: begin
                
            end
            WRITE_S2MM_DA_RESP: begin
                if( m_axi_bvalid == 1'b1 ) begin
                    m_axi_bready <= 1'b0;
                    if( m_axi_bresp == 2'b00 ) begin
                        axi_state_write <= WRITE_S2MM_LENGTH;
                        
                        m_axi_awaddr <= AXI_S2MM_LENGTH;
                        m_axi_awid <= 16'h0; 
                        m_axi_awburst <= 2'h0;
                        m_axi_awsize <= 3'b010; // 4 byte data
                        m_axi_awlen <= 8'h0;
                        m_axi_awvalid <= 1'b1;
                        m_axi_awuser <= 16'h0;
                                            
                        m_axi_wdata <= axi_s2mm_len;
                        m_axi_wstrb <= AXI_STROBE_WIDTH'hf;
                        m_axi_wlast <= 1'b1;
                        m_axi_wvalid <= 1'b1;
                        
                        m_axi_bready <= 1'b1;
                    end
                    else begin
                        axi_state_write <= ERROR_STATE;
                    end
                end
            end
            WRITE_S2MM_DA_MSB_RESP: begin
                
            end
            WRITE_S2MM_LENGTH_RESP: begin
                if( m_axi_bvalid == 1'b1 ) begin
                    m_axi_bready <= 1'b0;
                    if( m_axi_bresp == 2'b00 ) begin
                        axi_state_write <= IDLE;
                    end
                    else begin
                        axi_state_write <= ERROR_STATE;
                    end
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // Error Handle
            //////////////////////////////////////////////////////////////////////////////////
            
            ERROR_STATE: begin
                axi_state_write <= IDLE;
                m_axi_awaddr <= AXI_ADDR_WIDTH'h0;
                m_axi_awid <= 16'h0; 
                m_axi_awburst <= 2'h0;
                m_axi_awsize <= 3'h0;
                m_axi_awlen <= 8'h0;
                m_axi_awvalid <= 1'b0;
                m_axi_awuser <= 16'h0; // added to resolve wrapping error
                m_axi_bready <= 1'b0;
                m_axi_wdata <= AXI_DATA_WIDTH'h0;
                m_axi_wstrb <= AXI_STROBE_WIDTH'h0;
                m_axi_wvalid <= 1'b0;
                m_axi_wlast <= 1'b0;
                
                dram_controller_busy <= 1'b0;
            end
        endcase
    end
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Read FSM
//////////////////////////////////////////////////////////////////////////////////
always @(posedge m_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_read <= IDLE;
        
        m_axi_arburst <= 2'h0;
        m_axi_arlen <= 8'h0;
        m_axi_araddr <= AXI_ADDR_WIDTH'h0;
        m_axi_arsize <= 3'h0;
        m_axi_arvalid <= 1'b0;
        m_axi_arid <= 16'h0;
        m_axi_aruser <= 16'h0;
        
        m_axi_rready <= 1'b0;
    end
    
    else begin
        case(axi_state_read)
            IDLE: begin
                axi_state_read <= IDLE;
                
                m_axi_arburst <= 2'h0;
                m_axi_arlen <= 8'h0;
                m_axi_araddr <= AXI_ADDR_WIDTH'h0;
                m_axi_arsize <= 3'h0;
                m_axi_arvalid <= 1'b0;
                m_axi_arid <= 16'h0;
                m_axi_aruser <= 16'h0;
                
                m_axi_rready <= 1'b0;
            end
        endcase
    end
end

endmodule