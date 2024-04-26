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
    parameter AXI_ADDR_WIDTH                    = 32,
    parameter DRAM_DATA_WIDTH                   = 512,
    parameter AXI_DATA_WIDTH                    = DRAM_DATA_WIDTH,
    parameter AXI_STROBE_WIDTH                  = AXI_DATA_WIDTH >> 3,
    parameter AXI_STROBE_LEN                    = $clog2(AXI_STROBE_WIDTH) // LOG(AXI_STROBE_WDITH)
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
    output  reg m_axi_rready,
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
    // DRAM Data Interface
    //////////////////////////////////////////////////////////////////////////////////
    input  wire [AXI_ADDR_WIDTH - 1:0] dram_read_addr,
    input  wire [7:0] dram_read_len,
    input  wire dram_read_en,
    
    input  wire [AXI_ADDR_WIDTH - 1:0] dram_write_addr,
    input  wire [7:0] dram_write_len,
    input  wire dram_write_en,
    input  wire [AXI_DATA_WIDTH - 1:0] dram_write_data,
    
    output  reg [DRAM_DATA_WIDTH - 1:0] dram_read_data,
    output  reg dram_read_data_valid,
    output  reg dram_write_busy,
    output  reg dram_read_busy
);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 WRITE Address Space
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// AXI4 READ Address Space
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write, Read FSM State & reg definition
//////////////////////////////////////////////////////////////////////////////////
localparam AXI_STATE_LEN         = 6;

localparam IDLE                  = AXI_STATE_LEN'(6'h0);
localparam WRITE_DRAM            = AXI_STATE_LEN'(6'h1);
localparam WRITE_DRAM_WDATA      = AXI_STATE_LEN'(6'h11);
localparam WRITE_DRAM_RESP       = AXI_STATE_LEN'(6'h21);
localparam READ_DRAM             = AXI_STATE_LEN'(6'h1);
localparam READ_DRAM_RDATA       = AXI_STATE_LEN'(6'h2);
localparam ERROR_STATE           = AXI_STATE_LEN'(6'hc);

reg [AXI_STATE_LEN - 1:0] axi_state_write;
reg [AXI_STATE_LEN - 1:0] axi_state_read;

//////////////////////////////////////////////////////////////////////////////////
// AXI Data Buffer
//////////////////////////////////////////////////////////////////////////////////
    
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
        m_axi_awaddr <= AXI_ADDR_WIDTH'(2'h0);
        m_axi_awid <= 16'h0; 
        m_axi_awburst <= 2'h0;
        m_axi_awsize <= 3'h0;
        m_axi_awlen <= 8'h0;
        m_axi_awvalid <= 1'b0;
        m_axi_awuser <= 16'h0; // added to resolve wrapping error
        m_axi_bready <= 1'b0;
        m_axi_wdata <= AXI_DATA_WIDTH'(0);
        m_axi_wstrb <= AXI_STROBE_WIDTH'(0);
        m_axi_wvalid <= 1'b0;
        m_axi_wlast <= 1'b0;
        
        dram_write_busy <= 1'b0;
    end
    
    else begin
        case(axi_state_write)
            IDLE: begin
                axi_state_write <= IDLE;
                m_axi_awaddr <= AXI_ADDR_WIDTH'(0);
                m_axi_awid <= 16'h0; 
                m_axi_awburst <= 2'h0;
                m_axi_awsize <= 3'h0;
                m_axi_awlen <= 8'h0;
                m_axi_awvalid <= 1'b0;
                m_axi_awuser <= 16'h0; // added to resolve wrapping error
                m_axi_bready <= 1'b0;
                m_axi_wdata <= AXI_DATA_WIDTH'(0);
                m_axi_wstrb <= AXI_STROBE_WIDTH'(0);
                m_axi_wvalid <= 1'b0;
                m_axi_wlast <= 1'b0;
                
                dram_write_busy <= 1'b0;
                
                if( dram_write_en == 1'b1 )begin
                    axi_state_write <= WRITE_DRAM;
                    dram_write_busy <= 1'b1;
                    
                    m_axi_awaddr <= dram_write_addr;
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b010; // 4 byte data
                    m_axi_awlen <= dram_read_len;
                    m_axi_awvalid <= 1'b1;
                    m_axi_awuser <= 16'h0;
                                        
                    m_axi_wdata <= dram_write_data;
                    m_axi_wstrb <= AXI_STROBE_WIDTH'(128'hff_ff_ff_ff_ff_ff_ff_ff);
                    m_axi_wlast <= 1'b1;
                    m_axi_wvalid <= 1'b1;
                    
                    m_axi_bready <= 1'b1;
                end
            end
            //////////////////////////////////////////////////////////////////////////////////
            // DRAM Address Write
            //////////////////////////////////////////////////////////////////////////////////
            WRITE_DRAM: begin
                if( m_axi_awready == 1'b1 ) begin
                    axi_state_write <= WRITE_DRAM_WDATA;
                    
                    m_axi_awaddr <= AXI_ADDR_WIDTH'(0);
                    m_axi_awid <= 16'h0; 
                    m_axi_awburst <= 2'h0;
                    m_axi_awsize <= 3'b000;
                    m_axi_awlen <= 8'h0;
                    m_axi_awvalid <= 1'b0;
                    m_axi_awuser <= 16'h0;
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // DRAM Write Data
            //////////////////////////////////////////////////////////////////////////////////
            
            WRITE_DRAM_WDATA: begin
                if( m_axi_wready == 1'b1 ) begin
                    axi_state_write <= WRITE_DRAM_RESP;
                                        
                    m_axi_wdata <= AXI_DATA_WIDTH'(0);
                    m_axi_wstrb <= AXI_STROBE_WIDTH'(0);
                    m_axi_wlast <= 1'b0;
                    m_axi_wvalid <= 1'b0;
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // DRAM Response
            //////////////////////////////////////////////////////////////////////////////////
            
            WRITE_DRAM_RESP: begin
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
                m_axi_awaddr <= AXI_ADDR_WIDTH'(0);
                m_axi_awid <= 16'h0; 
                m_axi_awburst <= 2'h0;
                m_axi_awsize <= 3'h0;
                m_axi_awlen <= 8'h0;
                m_axi_awvalid <= 1'b0;
                m_axi_awuser <= 16'h0; // added to resolve wrapping error
                m_axi_bready <= 1'b0;
                m_axi_wdata <= AXI_DATA_WIDTH'(0);
                m_axi_wstrb <= AXI_STROBE_WIDTH'(0);
                m_axi_wvalid <= 1'b0;
                m_axi_wlast <= 1'b0;
                
                dram_write_busy <= 1'b0;
            end
        endcase
    end
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Read FSM
//////////////////////////////////////////////////////////////////////////////////
always @(posedge m_axi_aclk) begin
    if( m_axi_aresetn == 1'b0 ) begin
        axi_state_read <= IDLE;
        
        m_axi_arburst <= 2'h0;
        m_axi_arlen <= 8'h0;
        m_axi_araddr <= AXI_ADDR_WIDTH'(0);
        m_axi_arsize <= 3'h0;
        m_axi_arvalid <= 1'b0;
        m_axi_arid <= 16'h0;
        m_axi_aruser <= 16'h0;
        
        m_axi_rready <= 1'b0;
        
        dram_read_busy <= 1'b0;
    end
    
    else begin
        dram_read_data_valid <= 1'b0;
        case(axi_state_read)
            IDLE: begin
                axi_state_read <= IDLE;
                
                m_axi_arburst <= 2'h0;
                m_axi_arlen <= 8'h0;
                m_axi_araddr <= AXI_ADDR_WIDTH'(0);
                m_axi_arsize <= 3'h0;
                m_axi_arvalid <= 1'b0;
                m_axi_arid <= 16'h0;
                m_axi_aruser <= 16'h0;
                
                m_axi_rready <= 1'b0;
                
                dram_read_busy <= 1'b0;
                if( dram_read_en == 1'b1 ) begin
                    axi_state_read <= READ_DRAM;
                    
                    m_axi_arburst <= 2'h0;
                    m_axi_arlen <= dram_read_len;
                    m_axi_araddr <= dram_read_addr;
                    m_axi_arsize <= 3'h0; // ?
                    m_axi_arvalid <= 1'b1;
                    m_axi_arid <= 16'h0;
                    m_axi_aruser <= 16'h0;
                    
                    m_axi_rready <= 1'b1;
                    
                    dram_read_busy <= 1'b1;
                    
                end
            end
            READ_DRAM: begin
                if( m_axi_arready == 1'b1 ) begin
                    axi_state_read <= READ_DRAM_RDATA;
                    
                    m_axi_arburst <= 2'h0;
                    m_axi_arlen <= 8'h0;
                    m_axi_araddr <= AXI_ADDR_WIDTH'(0);
                    m_axi_arsize <= 3'h0; // ?
                    m_axi_arvalid <= 1'b0;
                    m_axi_arid <= 16'h0;
                    m_axi_aruser <= 16'h0;
                end
            end
            READ_DRAM_RDATA: begin
                if( m_axi_rready == 1'b1 ) begin
                    axi_state_read <= IDLE;
                    if( m_axi_rvalid == 1'b1 ) begin
                        dram_read_data <= m_axi_rdata;
                        if( m_axi_rlast == 1'b1 ) begin
                            m_axi_rready <= 1'b0;
                            if( m_axi_rresp == 2'b0 ) begin
                                axi_state_read <= IDLE;
                                dram_read_busy <= 1'b0;
                                dram_read_data_valid <= 1'b1;
                            end
                            else begin
                                axi_state_read <= ERROR_STATE;
                            end
                        end
                    end
                end
            end
            ERROR_STATE: begin
                axi_state_read <= IDLE;
                
                m_axi_arburst <= 2'h0;
                m_axi_arlen <= 8'h0;
                m_axi_araddr <= AXI_ADDR_WIDTH'(0);
                m_axi_arsize <= 3'h0;
                m_axi_arvalid <= 1'b0;
                m_axi_arid <= 16'h0;
                m_axi_aruser <= 16'h0;
                
                m_axi_rready <= 1'b0;
                
                dram_read_busy <= 1'b0;
                
                dram_read_data_valid <= 1'b0;
            end
        endcase
    end
end

endmodule