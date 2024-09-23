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


module AXI2UART
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
    // Cameralink UART Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    output reg         tx_start,             // Start transmission signal
    output reg  [7:0]  tx_data,              // Data to be transmitted
    input  wire        tx_busy,              // Transmission in progress
    input  wire        rx_ready,             // Data received and ready
    output wire [7:0]  rx_data,              // Data received
    output reg         CC1,
    output reg         CC2,
    output reg         CC3,
    output reg         CC4,
    output reg         trigger_from_cpu
);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Address Space
//////////////////////////////////////////////////////////////////////////////////
localparam AXI_WRITE_UART       = {AXI_ADDR_WIDTH{6'h00}};
localparam AXI_WRITE_CC         = {AXI_ADDR_WIDTH{6'h10}};
localparam AXI_READ_UART        = {AXI_ADDR_WIDTH{6'h20}};
localparam AXI_READ_UART_VALID  = {AXI_ADDR_WIDTH{6'h30}};

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write, Read FSM State & reg definition
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic [6:0] {
    WRITE_IDLE, 
    WRITE_UART,
    WRITE_CC,
    WRITE_ERROR_STATE, 
    WRITE_RESPONSE} statetype_w;
statetype_w axi_state_write;

typedef enum logic [4:0] {
    READ_IDLE, 
    READ_UART, 
    READ_UART_VALID, 
    READ_ERROR_STATE} statetype_r;
statetype_r axi_state_read;

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
// AXI4 Output Assign Logic
//////////////////////////////////////////////////////////////////////////////////

assign s_axi_awready = (axi_state_write == WRITE_IDLE);
assign s_axi_wready  = ((axi_state_write == WRITE_UART) || (axi_state_write == WRITE_CC));
assign s_axi_arready = (axi_state_read == READ_IDLE);

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Write FSM
// In AXI write, wlast signal has to be actived to end sending data. Only sending
// length of AXI signal does not work.
//////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_write <= WRITE_IDLE;
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
        
        tx_start <= 1'b0;
        tx_data  <= 8'h0;
        {CC1,CC2,CC3,CC4} <= 4'h0;
    end
    
    else begin
        tx_start <= 1'b0;
        case(axi_state_write)
            WRITE_IDLE: begin
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
                    
                    if( s_axi_awaddr == AXI_WRITE_UART ) begin
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
                        
                        axi_state_write <= WRITE_UART;
                    end
                    
                    else if( s_axi_awaddr == AXI_WRITE_CC ) begin
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
                        
                        axi_state_write <= WRITE_CC;
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
                        axi_state_write <= WRITE_ERROR_STATE;
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
                    axi_state_write <= WRITE_IDLE;
                end
            end
            
            WRITE_UART: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    tx_data <= s_axi_wdata[7:0];
                    tx_start <= 1'b1;
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            
            WRITE_CC: begin
                if( s_axi_wvalid == 1'b1 ) begin
                    {CC4,CC3,CC2,CC1} <= s_axi_wdata[3:0];
                    if( s_axi_wlast == 1'b1 ) begin
                        axi_state_write <= WRITE_RESPONSE;
                    end
                end
            end
            
            WRITE_ERROR_STATE: begin
                if( s_axi_bready == 1'b1 ) begin
                    s_axi_bresp <= 2'b10;
                    s_axi_bvalid <= 1'b1;
                    s_axi_bid <= axi_awid;
                    axi_state_write <= WRITE_IDLE;
                end
            end
            
            WRITE_RESPONSE: begin
                if( s_axi_bready == 1'b1 ) begin
                    s_axi_bresp <= 2'b00;
                    s_axi_bvalid <= 1'b1;
                    s_axi_bid <= axi_awid;
                    axi_state_write <= WRITE_IDLE;
                end
            end
        endcase
    end
end

//////////////////////////////////////////////////////////////////////////////////
// UART RX buffer
//////////////////////////////////////////////////////////////////////////////////
reg [7:0] rx_data_buffer;
reg rx_data_valid;
reg rx_buffer_clear;

always_ff @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        rx_data_buffer <= 8'h0;
        rx_data_valid <= 1'b0;
    end
    else begin
        if( rx_ready == 1'b1 ) begin
            rx_data_buffer <= rx_data;
            rx_data_valid <= 1'b1;
        end
        if( rx_buffer_clear == 1'b1 ) begin
            rx_data_buffer <= 8'h0;
            rx_data_valid <= 1'b0;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////
// AXI4 Read FSM
// AXI read only gives zero data to master from slave
//////////////////////////////////////////////////////////////////////////////////
reg [15:0] axi_arid;
reg [15:0] axi_aruser;

always_ff @(posedge s_axi_aclk) begin
    if( s_axi_aresetn == 1'b0 ) begin
        axi_state_read <= READ_IDLE;
        s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
        s_axi_rresp <= 2'b0;
        s_axi_rvalid <= 1'b0;
        s_axi_rlast <= 1'b0;
        s_axi_rid <= 16'h0; // id value
        axi_arid <= 16'h0;
        axi_aruser <= 16'h0;

        rx_buffer_clear <= 1'b0;
    end
    
    else begin
        s_axi_rid <= 16'h0; // id value
        axi_arid <= 16'h0;
        axi_aruser <= 16'h0;
        rx_buffer_clear <= 1'b0;
        case(axi_state_read)
            READ_IDLE: begin
                s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
                s_axi_rresp <= 2'b0;
                s_axi_rvalid <= 1'b0;
                s_axi_rlast <= 1'b0;
                if( s_axi_arvalid == 1'b1 ) begin
                    if( s_axi_araddr == AXI_READ_UART ) begin
                        axi_state_read <= READ_UART;
                    end
                    else if( s_axi_araddr == AXI_READ_UART_VALID ) begin
                        axi_state_read <= READ_UART_VALID;
                    end
                    else begin
                        axi_state_read <= READ_ERROR_STATE;
                    end
                end
            end
            READ_UART: begin
                if( s_axi_rready == 1'b1  && rx_data_valid == 1'b1 ) begin
                    s_axi_rdata <= AXI_DATA_WIDTH'(rx_data_buffer);
                    s_axi_rresp <= 2'b0;
                    s_axi_rvalid <= 1'b1;
                    s_axi_rlast <= 1'b1;
                    s_axi_rid <= axi_arid;
                    axi_state_read <= READ_IDLE;

                    rx_buffer_clear <= 1'b1;
                end
            end
            READ_UART_VALID: begin
                if( s_axi_rready == 1'b1) begin
                    s_axi_rdata <= AXI_DATA_WIDTH'(rx_data_valid);
                    s_axi_rresp <= 2'b0;
                    s_axi_rvalid <= 1'b1;
                    s_axi_rlast <= 1'b1;
                    s_axi_rid <= axi_arid;
                    axi_state_read <= READ_IDLE;
                end
            end
            READ_ERROR_STATE: begin
                s_axi_rdata <= AXI_DATA_WIDTH'(0);
                s_axi_rresp <= 2'b10;
                s_axi_rvalid <= 1'b1;
                s_axi_rlast <= 1'b1;
                s_axi_rid <= axi_arid;
                axi_state_read <= READ_IDLE;
            end
        endcase
    end
end

endmodule