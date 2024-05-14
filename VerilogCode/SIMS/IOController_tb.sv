`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/14 23:09:08
// Design Name: 
// Module Name: IOController_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// IOController Interface delcaration
//////////////////////////////////////////////////////////////////////////////////
interface io_controller_if;
    logic [5:0] s_axi_awaddr;
    logic [15:0] s_axi_awid;
    logic [1:0] s_axi_awburst;
    logic [2:0] s_axi_awsize;
    logic [7:0] s_axi_awlen;
    logic s_axi_awvalid;
    logic [15:0] s_axi_awuser;
    logic s_axi_awready;
    
    logic s_axi_bready;
    logic [1:0] s_axi_bresp;
    logic s_axi_bvalid;
    logic [15:0] s_axi_bid;
    
    logic [127:0] s_axi_wdata;
    logic [15:0] s_axi_wstrb;
    logic s_axi_wvalid;
    logic s_axi_wlast;
    logic s_axi_wready;
    
    logic [1:0] s_axi_arburst;
    logic [7:0] s_axi_arlen;
    logic [5:0] s_axi_araddr;
    logic [2:0] s_axi_arsize;
    logic s_axi_arvalid;
    logic [15:0] s_axi_arid;
    logic [15:0] s_axi_aruser;
    logic s_axi_arready;
    logic [15:0] s_axi_rid;
    
    logic s_axi_rready;
    logic [127:0] s_axi_rdata;
    logic [1:0] s_axi_rresp;
    logic s_axi_rvalid;
    logic s_axi_rlast;
    
    logic s_axi_aclk;
    logic s_axi_aresetn;
 
    logic auto_start;
    logic input_signal;
    logic output_signal;

endinterface : io_controller_if
//////////////////////////////////////////////////////////////////////////////////
// module delcaration
//////////////////////////////////////////////////////////////////////////////////
module io_controller_tb;
localparam AXI_ADDR_WIDTH                    = 6;
localparam AXI_DATA_WIDTH                    = 128;
localparam MAX_DELAY                         = 1000000000;
localparam DELAY_WIDTH                       = $clog2(MAX_DELAY);
localparam MAX_EVENT                         = 10;
localparam EVENT_WIDTH                       = $clog2(MAX_EVENT);
localparam AXI_WRITE_COMMAND                 = AXI_ADDR_WIDTH'(6'h00);
localparam AXI_WRITE_DELAY                   = AXI_ADDR_WIDTH'(6'h10);
localparam AXI_WRITE_EVENT                   = AXI_ADDR_WIDTH'(6'h20);
localparam AXI_WRITE_POLARITY                = AXI_ADDR_WIDTH'(6'h30);
int event_num = 10;

reg clk;

io_controller_if ioc_if();
 
IOController #(
    .MAX_DELAY(1000000000),
    .DELAY_WIDTH(30),
    .MAX_EVENT(10),
    .EVENT_WIDTH(4),
    .AXI_ADDR_WIDTH(6),
    .AXI_DATA_WIDTH(128),
    .AXI_STROBE_WIDTH(16),
    .AXI_STROBE_LEN(4)
) dut (
    .s_axi_awaddr(ioc_if.s_axi_awaddr),
    .s_axi_awid(ioc_if.s_axi_awid),
    .s_axi_awburst(ioc_if.s_axi_awburst),
    .s_axi_awsize(ioc_if.s_axi_awsize),
    .s_axi_awlen(ioc_if.s_axi_awlen),
    .s_axi_awvalid(ioc_if.s_axi_awvalid),
    .s_axi_awuser(ioc_if.s_axi_awuser),
    .s_axi_awready(ioc_if.s_axi_awready),
    
    .s_axi_bready(ioc_if.s_axi_bready),
    .s_axi_bresp(ioc_if.s_axi_bresp),
    .s_axi_bvalid(ioc_if.s_axi_bvalid),
    .s_axi_bid(ioc_if.s_axi_bid),
    
    .s_axi_wdata(ioc_if.s_axi_wdata),
    .s_axi_wstrb(ioc_if.s_axi_wstrb),
    .s_axi_wvalid(ioc_if.s_axi_wvalid),
    .s_axi_wlast(ioc_if.s_axi_wlast),
    .s_axi_wready(ioc_if.s_axi_wready),
    
    .s_axi_arburst(ioc_if.s_axi_arburst),
    .s_axi_arlen(ioc_if.s_axi_arlen),
    .s_axi_araddr(ioc_if.s_axi_araddr),
    .s_axi_arsize(ioc_if.s_axi_arsize),
    .s_axi_arvalid(ioc_if.s_axi_arvalid),
    .s_axi_arid(ioc_if.s_axi_arid),
    .s_axi_aruser(ioc_if.s_axi_aruser),
    .s_axi_arready(ioc_if.s_axi_arready),
    .s_axi_rid(ioc_if.s_axi_rid),
    
    .s_axi_rready(ioc_if.s_axi_rready),
    .s_axi_rdata(ioc_if.s_axi_rdata),
    .s_axi_rresp(ioc_if.s_axi_rresp),
    .s_axi_rvalid(ioc_if.s_axi_rvalid),
    .s_axi_rlast(ioc_if.s_axi_rlast),
    
    .s_axi_aclk(ioc_if.s_axi_aclk),
    .s_axi_aresetn(ioc_if.s_axi_aresetn),
    
    .auto_start(ioc_if.auto_start),
    .input_signal(ioc_if.input_signal),
    .output_signal(ioc_if.output_signal)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

assign ioc_if.s_axi_aclk = clk;

//////////////////////////////////////////////////////////////////////////////////
// axi write task delcaration
//////////////////////////////////////////////////////////////////////////////////
task axi_write(input [5:0] awaddr, input [127:0] wdata);
    @(posedge clk);
    ioc_if.s_axi_awaddr <= awaddr;
    ioc_if.s_axi_awvalid <= 1;
    ioc_if.s_axi_wdata <= wdata;
    ioc_if.s_axi_wvalid <= 1;
    ioc_if.s_axi_wlast <= 1;
    
    wait (ioc_if.s_axi_awready);
    wait (~ioc_if.s_axi_awready);
    ioc_if.s_axi_awvalid <= 0;
    
    wait(ioc_if.s_axi_wready);
    wait(~ioc_if.s_axi_wready);
    ioc_if.s_axi_wlast <= 0;
    ioc_if.s_axi_wdata <= 0;
    ioc_if.s_axi_bready <= 1'b1;
    
    wait(ioc_if.s_axi_bvalid);
    ioc_if.s_axi_wvalid <= 0;
    
    if( ioc_if.s_axi_bresp != 2'b00 ) begin
        $display("AXI RESPONSE IS NOT OKAY : %d",ioc_if.s_axi_bresp);
    end
endtask
//////////////////////////////////////////////////////////////////////////////////
// random signal generation delcaration
//////////////////////////////////////////////////////////////////////////////////
task generate_random_signal();
    int duration = $urandom_range(10,1000);
    int width = $urandom_range(10,1000);
    
    ioc_if.input_signal <= 0;
    #10;
    ioc_if.input_signal <= 1;
    #width;
    ioc_if.input_signal <= 0;
    #duration;
endtask

int i = 0 ;
//////////////////////////////////////////////////////////////////////////////////
// main simulation
//////////////////////////////////////////////////////////////////////////////////
initial begin
    ioc_if.s_axi_aresetn = 0;
    ioc_if.input_signal = 0;
    
    ioc_if.s_axi_awaddr = 0;
    ioc_if.s_axi_awid = 0;
    ioc_if.s_axi_awburst = 0;
    ioc_if.s_axi_awsize = 0;
    ioc_if.s_axi_awlen = 0;
    ioc_if.s_axi_awvalid = 0;
    ioc_if.s_axi_awuser = 0;
    
    ioc_if.s_axi_bready = 0;
    
    ioc_if.s_axi_wdata = 0;
    ioc_if.s_axi_wstrb = 0;
    ioc_if.s_axi_wvalid = 0;
    ioc_if.s_axi_wlast = 0;
    ioc_if.auto_start = 0;
    
    
    #100 ioc_if.s_axi_aresetn = 1;
    
    #1000;
    
    axi_write(AXI_WRITE_DELAY, AXI_DATA_WIDTH'(1000));
    axi_write(AXI_WRITE_EVENT, AXI_DATA_WIDTH'(event_num));

    
    #1000;
    ioc_if.auto_start = 1;
    #1000;
    
    
    for( i = 0 ; i < event_num; i ++) begin
        generate_random_signal();
        $display("%d th random signal generated",i);
    end
    $display("Random Signal Generation END");

    // End simulation after tests
    wait(ioc_if.output_signal);
    $display("output signal detected");
    #1000;
    $display("End Simulation");
    $finish;
end

endmodule : io_controller_tb