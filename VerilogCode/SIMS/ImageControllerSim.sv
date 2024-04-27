`timescale 1ns / 1ps

module tb_ImageController;

// Parameters matching the DUT (Device Under Test)
localparam FRAME_WIDTH = 2200;
localparam FRAME_HEIGHT = 1125;
localparam SCREEN_WIDTH = 1920;
localparam SCREEN_HEIGHT = 1080;
localparam int BIT_WIDTH = 12;
localparam int BIT_HEIGHT = 11;
localparam IMAGE_WIDTH = 100;
localparam IMAGE_HEIGHT = 100;
localparam AXI_ADDR_WIDTH = 6;
localparam AXI_DATA_WIDTH = 128;
localparam AXI_STROBE_WIDTH = AXI_DATA_WIDTH >> 3;
localparam AXI_STROBE_LEN = 4; // LOG(AXI_STROBE_WIDTH)
localparam FIFO_DEPTH = 130000;

// Clock and reset signals
logic s_axi_clk;
logic s_axi_aresetn;
logic clk_pixel;
logic clk_pixel_resetn;

// AXI write address channel signals
logic [AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
logic [15:0] s_axi_awid;
logic [1:0] s_axi_awburst;
logic [2:0] s_axi_awsize;
logic [7:0] s_axi_awlen;
logic s_axi_awvalid;
logic s_axi_awready;

// AXI write data channel signals
logic [AXI_DATA_WIDTH-1:0] s_axi_wdata;
logic [AXI_STROBE_WIDTH-1:0] s_axi_wstrb;
logic s_axi_wvalid;
logic s_axi_wlast;
logic s_axi_wready;

// AXI write response channel signals
logic s_axi_bready;
logic [1:0] s_axi_bresp;
logic s_axi_bvalid;
logic [15:0] s_axi_bid;

// AXI read address channel signals
logic [AXI_ADDR_WIDTH-1:0] s_axi_araddr;
logic [15:0] s_axi_arid;
logic [1:0] s_axi_arburst;
logic [2:0] s_axi_arsize;
logic [7:0] s_axi_arlen;
logic s_axi_arvalid;
logic [15:0] s_axi_aruser;
logic s_axi_arready;
logic [15:0] s_axi_rid;

// AXI read data channel signals
logic s_axi_rready;
logic [AXI_DATA_WIDTH-1:0] s_axi_rdata;
logic [1:0] s_axi_rresp;
logic s_axi_rvalid;
logic s_axi_rlast;

// ImageController additional inputs and outputs
logic auto_start;
logic [63:0] counter;
logic [BIT_WIDTH-1:0] cx;
logic [BIT_HEIGHT-1:0] cy;
logic [23:0] rgb;

  // Instantiate the ImageController module
ImageController #(
    .FRAME_WIDTH(FRAME_WIDTH),
    .FRAME_HEIGHT(FRAME_HEIGHT),
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .SCREEN_HEIGHT(SCREEN_HEIGHT),
    .BIT_WIDTH(BIT_WIDTH),
    .BIT_HEIGHT(BIT_HEIGHT),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH(AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN(AXI_STROBE_LEN),
    .FIFO_DEPTH(FIFO_DEPTH)
) dut (
    .s_axi_aclk(s_axi_clk),
    .s_axi_aresetn(s_axi_aresetn),
    .clk_pixel(clk_pixel),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awid(s_axi_awid),
    .s_axi_awburst(s_axi_awburst),
    .s_axi_awsize(s_axi_awsize),
    .s_axi_awlen(s_axi_awlen),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awuser(16'h0000), // Added default value for simplicity
    .s_axi_awready(s_axi_awready),
    .s_axi_bready(s_axi_bready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bid(s_axi_bid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wlast(s_axi_wlast),
    .s_axi_wready(s_axi_wready),
    .s_axi_arburst(s_axi_arburst),
    .s_axi_arlen(s_axi_arlen),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arsize(s_axi_arsize),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arid(s_axi_arid),
    .s_axi_aruser(s_axi_aruser),
    .s_axi_arready(s_axi_arready),
    .s_axi_rid(s_axi_rid),
    .s_axi_rready(s_axi_rready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rlast(s_axi_rlast),
    
    .auto_start(auto_start),
    .counter(counter),
    .clk_pixel_resetn(clk_pixel_resetn),
    .cx(cx),
    .cy(cy),
    .rgb(rgb)
);

// Clock generation for s_axi_clk (125MHz)
initial begin
    s_axi_clk = 0;
    forever #4 s_axi_clk = ~s_axi_clk; // Toggle every 4ns for 125MHz clock
end

// Clock generation for clk_pixel (148.5MHz)
initial begin
    clk_pixel = 0;
    forever #3.367 clk_pixel = ~clk_pixel; // Toggle every 3.367ns for 148.5MHz clock
end
  
  // Increment cx and cy by 1 as auto_start signal goes HIGH
always @(posedge clk_pixel) begin // Synchronizing to pixel clock domain
    cx <= cx + 1;
    cy <= cy + 1;
end

  // Reset generation
initial begin
    cx <= 0;
    cy <= 0;
    s_axi_aresetn = 0;
    clk_pixel_resetn = 0;
    #100;
    s_axi_aresetn = 1;
    clk_pixel_resetn = 1;
end

// AXI write burst simulation
initial begin
    wait ( s_axi_aresetn && clk_pixel_resetn)
    // Wait for reset deassertion
    #10; // Small delay after reset
    
    // Initialize AXI signals
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;
    s_axi_bready = 0;
    auto_start = 0;
    
    // Simulate auto_start signal transition from LOW to HIGH
    // to trigger cx and cy increment
    wait ( s_axi_clk);
    #10;  // Small delay
    auto_start = 1; // Triggering transition
    
    
    
    // Start a burst write transaction
    // Set up write address channel signals
    s_axi_awaddr = 'h0000_0000; // Start address
    s_axi_awlen = 8'd255;       // 256-beat burst length
    s_axi_awsize = 'd3;         // 8-byte beat size
    s_axi_awburst = 2'b01;      // INCR type burst
    s_axi_awvalid = 1;
    
    // Wait for the address channel to be accepted
    wait (s_axi_awready && s_axi_awvalid);
    s_axi_awvalid = 0;
    
    // Start write data transmission
    for (int i = 0; i < 256; i++) begin
        s_axi_wdata = $urandom;   // Random data, replace with your data pattern if needed
        s_axi_wstrb = {AXI_STROBE_WIDTH{1'b1}}; // All byte lanes valid
        s_axi_wvalid = 1;
        s_axi_wlast = (i == 255); // Last signal asserted on the last beat
        wait (s_axi_wready && s_axi_wvalid);
        @(posedge s_axi_clk);
    end
    s_axi_wvalid = 0;
    
    // Finish the write transaction
    s_axi_bready = 1;
    wait (s_axi_bvalid && s_axi_bready);
    s_axi_bready = 0;
    
    // Check the write response
    if (s_axi_bresp != 2'b00) begin
      $display("Error: Write burst transaction failed with response: %b", s_axi_bresp);
      $finish;
    end
    
    $display("Write burst transaction completed successfully.");
    
    // Finish the testbench simulation
    #1000;
    $finish;
end

endmodule