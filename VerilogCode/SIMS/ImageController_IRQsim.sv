`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 00:22:58
// Design Name: 
// Module Name: ZCU104sim
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


module ZCU104sim;

reg [38:0]              S00_AXI_0_araddr;
reg [1:0]               S00_AXI_0_arburst;
reg [3:0]               S00_AXI_0_arcache;
reg [16:0]              S00_AXI_0_arid;
reg [7:0]               S00_AXI_0_arlen;
reg [0:0]               S00_AXI_0_arlock;
reg [2:0]               S00_AXI_0_arprot;
reg [3:0]               S00_AXI_0_arqos;
wire [0:0]              S00_AXI_0_arready;
reg [2:0]               S00_AXI_0_arsize;
reg [15:0]              S00_AXI_0_aruser;
reg [0:0]               S00_AXI_0_arvalid;
reg [38:0]              S00_AXI_0_awaddr;
reg [1:0]               S00_AXI_0_awburst;
reg [3:0]               S00_AXI_0_awcache;
reg [16:0]              S00_AXI_0_awid;
reg [7:0]               S00_AXI_0_awlen;
reg [0:0]               S00_AXI_0_awlock;
reg [2:0]               S00_AXI_0_awprot;
reg [3:0]               S00_AXI_0_awqos;
wire [0:0]              S00_AXI_0_awready;
reg [2:0]               S00_AXI_0_awsize;
reg [15:0]              S00_AXI_0_awuser;
reg [0:0]               S00_AXI_0_awvalid;
wire [16:0]             S00_AXI_0_bid;
reg [0:0]               S00_AXI_0_bready;
wire [1:0]              S00_AXI_0_bresp;
wire [0:0]              S00_AXI_0_bvalid;
wire [127:0]            S00_AXI_0_rdata;
wire [16:0]             S00_AXI_0_rid;
wire [0:0]              S00_AXI_0_rlast;
reg [0:0]               S00_AXI_0_rready;
wire [1:0]              S00_AXI_0_rresp;
wire [0:0]              S00_AXI_0_rvalid;
reg [127:0]             S00_AXI_0_wdata;
reg [0:0]               S00_AXI_0_wlast;
wire [0:0]              S00_AXI_0_wready;
reg [15:0]              S00_AXI_0_wstrb;
reg [0:0]               S00_AXI_0_wvalid;

reg                     clk_pixel;
reg                     s_axi_aclk;
reg                     s_axi_aresetn;
wire [9:0]              tmds0_10bit_0;
wire [9:0]              tmds1_10bit_0;
wire [9:0]              tmds2_10bit_0;
reg                     image_change;
wire                    irq_signal;

reg [127:0]             wdata_buffer;

ZCU104_Main_blk_wrapper zcu104_main_blk_wrapper_inst (
    .S00_AXI_0_araddr                   (S00_AXI_0_araddr),
    .S00_AXI_0_arburst                  (S00_AXI_0_arburst),
    .S00_AXI_0_arcache                  (S00_AXI_0_arcache),
    .S00_AXI_0_arlen                    (S00_AXI_0_arlen),
    .S00_AXI_0_arlock                   (S00_AXI_0_arlock),
    .S00_AXI_0_arprot                   (S00_AXI_0_arprot),
    .S00_AXI_0_arqos                    (S00_AXI_0_arqos),
    .S00_AXI_0_arready                  (S00_AXI_0_arready),
    .S00_AXI_0_arsize                   (S00_AXI_0_arsize),
    .S00_AXI_0_arvalid                  (S00_AXI_0_arvalid),
    .S00_AXI_0_awaddr                   (S00_AXI_0_awaddr),
    .S00_AXI_0_awburst                  (S00_AXI_0_awburst),
    .S00_AXI_0_awcache                  (S00_AXI_0_awcache),
    .S00_AXI_0_awlen                    (S00_AXI_0_awlen),
    .S00_AXI_0_awlock                   (S00_AXI_0_awlock),
    .S00_AXI_0_awprot                   (S00_AXI_0_awprot),
    .S00_AXI_0_awqos                    (S00_AXI_0_awqos),
    .S00_AXI_0_awready                  (S00_AXI_0_awready),
    .S00_AXI_0_awsize                   (S00_AXI_0_awsize),
    .S00_AXI_0_awvalid                  (S00_AXI_0_awvalid),
    .S00_AXI_0_bready                   (S00_AXI_0_bready),
    .S00_AXI_0_bresp                    (S00_AXI_0_bresp),
    .S00_AXI_0_bvalid                   (S00_AXI_0_bvalid),
    .S00_AXI_0_rdata                    (S00_AXI_0_rdata),
    .S00_AXI_0_rlast                    (S00_AXI_0_rlast),
    .S00_AXI_0_rready                   (S00_AXI_0_rready),
    .S00_AXI_0_rresp                    (S00_AXI_0_rresp),
    .S00_AXI_0_rvalid                   (S00_AXI_0_rvalid),
    .S00_AXI_0_wdata                    (S00_AXI_0_wdata),
    .S00_AXI_0_wlast                    (S00_AXI_0_wlast),
    .S00_AXI_0_wready                   (S00_AXI_0_wready),
    .S00_AXI_0_wstrb                    (S00_AXI_0_wstrb),
    .S00_AXI_0_wvalid                   (S00_AXI_0_wvalid),
    
    .clk_pixel                          (clk_pixel),
    .s_axi_aclk                         (s_axi_aclk),
    
    .s_axi_aresetn                      (s_axi_aresetn),
    .tmds0_10bit_0                      (tmds0_10bit_0),
    .tmds1_10bit_0                      (tmds1_10bit_0),
    .tmds2_10bit_0                      (tmds2_10bit_0),
    .image_change                       (image_change),
    .irq_signal                         (irq_signal)
);

// Clock generation
initial begin
    s_axi_aclk = 0;
    forever #4 s_axi_aclk = ~s_axi_aclk; // Toggle every 4ns for 125MHz clock
end

// Clock generation for clk_pixel (148.5MHz)
initial begin
    clk_pixel = 0;
    forever #3.367 clk_pixel = ~clk_pixel; // Toggle every 3.367ns for 148.5MHz clock
end
   

int i = 0; 
int j = 0;
//localparam DATA_LEN = 100;
localparam DATA_LEN = 4050;

initial begin
// Initialize write signals
    image_change <= 1'b0;    
    S00_AXI_0_araddr <= 39'h0;
    S00_AXI_0_arburst <= 2'b00;
    S00_AXI_0_arcache <= 4'b0000;
    S00_AXI_0_arid <= 17'h0;
    S00_AXI_0_arlen <= 8'h00;
    S00_AXI_0_arlock <= 1'b0;
    S00_AXI_0_arprot <= 3'h0;
    S00_AXI_0_arqos <= 4'h0;
    S00_AXI_0_arsize <= 3'h0;
    S00_AXI_0_aruser <= 16'h0;
    S00_AXI_0_arvalid <= 1'b0;
    S00_AXI_0_awaddr <= 39'h0;
    S00_AXI_0_awburst <= 2'b00;
    S00_AXI_0_awcache <= 4'h0;
    S00_AXI_0_awid <= 16'h0;
    S00_AXI_0_awlen <= 8'h0;
    S00_AXI_0_awlock <= 1'b0;
    S00_AXI_0_awprot <= 3'h0;
    S00_AXI_0_awqos <= 4'h0;
    S00_AXI_0_awsize <= 3'b100;
    S00_AXI_0_awuser <= 16'h0;
    S00_AXI_0_awvalid <= 1'b0;
    S00_AXI_0_bready <= 1'b0;
    S00_AXI_0_rready <= 1'b0;
    S00_AXI_0_wdata <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    S00_AXI_0_wlast <= 1'b0;
    S00_AXI_0_wstrb <= 16'hffff;
    S00_AXI_0_wvalid <= 1'b0;
    s_axi_aresetn <= 1'b0;

    #10000;
    s_axi_aresetn <= 1'b1;
    
    #10000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write RESET command to MasterController
    //////////////////////////////////////////////////////////////////////////////////
    S00_AXI_0_awsize <= 3'b100;
    S00_AXI_0_awaddr <= 39'h00_A000_0000; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= 128'(4'b0010); // Example write data
    S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
    S00_AXI_0_wlast <= 1;
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    wait(~S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 0;
    
    // Wait for BVALID and then de-assert BREADY
    wait(S00_AXI_0_bvalid);
    wait(~S00_AXI_0_bvalid);
    S00_AXI_0_bready <= 0;
        
    S00_AXI_0_awaddr <= 39'h0; // Example write address
    S00_AXI_0_awvalid <= 0;
    S00_AXI_0_wdata <= 128'h0; // Example write data
    S00_AXI_0_wstrb <= 16'h0; // All bytes are valid
    S00_AXI_0_wlast <= 0;
    S00_AXI_0_wvalid <= 0;
    S00_AXI_0_bready <= 0;
    #1000;
    
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write DISABLE RESET command to MasterController
    //////////////////////////////////////////////////////////////////////////////////
    S00_AXI_0_awaddr <= 39'h00_A000_0000; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= 128'(4'b0000); // Example write data
    S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
    S00_AXI_0_wlast <= 1;
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_rready <= 1;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    wait(~S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 0;
    
    // Wait for BVALID and then de-assert BREADY
    wait(S00_AXI_0_bvalid);
    wait(~S00_AXI_0_bvalid);
    S00_AXI_0_bready <= 0;
    
        
    S00_AXI_0_awaddr <= 39'h0; // Example write address
    S00_AXI_0_awvalid <= 0;
    S00_AXI_0_wdata <= 128'h0; // Example write data
    S00_AXI_0_wstrb <= 16'h0; // All bytes are valid
    S00_AXI_0_wlast <= 0;
    S00_AXI_0_wvalid <= 0;
    S00_AXI_0_bready <= 0;
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    S00_AXI_0_awaddr <= 39'h00_A001_0020; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= 128'h78000000438; // To align to 512 bit width of axi memory interface, 256 bit is shifted
    S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    S00_AXI_0_wlast <= 1;
    wait(~S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 0;
    S00_AXI_0_wlast <= 0;
    
    // Wait for BVALID and then de-assert BREADY
    wait(S00_AXI_0_bvalid);
    wait(~S00_AXI_0_bvalid);
    S00_AXI_0_bready <= 0;
    
    #1000;
    //////////////////////////////////////////////////////////////////////////////////
    // Write to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    S00_AXI_0_awaddr <= 39'h00_A001_0000; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= 128'(39'h04_0000_0000 | ( (39'h04_0000_0000 | 1920*1080) << 64 )); // Example write data
    S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    S00_AXI_0_wlast <= 1;
    wait(~S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 0;
    S00_AXI_0_wlast <= 0;
    
    // Wait for BVALID and then de-assert BREADY
    wait(S00_AXI_0_bvalid);
    wait(~S00_AXI_0_bvalid);
    S00_AXI_0_bready <= 0;
    
    #1000;
    //////////////////////////////////////////////////////////////////////////////////
    // Write AUTOSTART command to MasterController
    //////////////////////////////////////////////////////////////////////////////////
    S00_AXI_0_awaddr <= 39'h00_A000_0000; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= 128'(4'b1001); // Example write data
    S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
    S00_AXI_0_wlast <= 1;
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_rready <= 1;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    wait(~S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 0;
    
    // Wait for BVALID and then de-assert BREADY
    wait(S00_AXI_0_bvalid);
    wait(~S00_AXI_0_bvalid);
    S00_AXI_0_bready <= 0;
    
    #100;
    
    i = 0;
    forever begin
        wait(irq_signal);
        //////////////////////////////////////////////////////////////////////////////////
        // Capture interrupt signal
        //////////////////////////////////////////////////////////////////////////////////
        S00_AXI_0_araddr <= 39'h00_A001_0000; // Example read address
        S00_AXI_0_rready <= 1;
        S00_AXI_0_arvalid <= 1;
        
        wait(S00_AXI_0_arready);
        wait(~S00_AXI_0_arready);
        S00_AXI_0_arvalid <= 0;
        
        wait(S00_AXI_0_rlast);
        #8; // wait one clock cycle
        wdata_buffer <= S00_AXI_0_rdata;
        $display("Read data: %h", S00_AXI_0_rdata); 
        S00_AXI_0_rready <= 0;
        #8;
        //////////////////////////////////////////////////////////////////////////////////
        // Write to ImageController
        //////////////////////////////////////////////////////////////////////////////////
        S00_AXI_0_awaddr <= 39'h00_A001_0030; // Example write address
        S00_AXI_0_awvalid <= 1;
        S00_AXI_0_wdata <= 128'(i);
        S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
        S00_AXI_0_wvalid <= 1;
        S00_AXI_0_bready <= 1'b1;
        S00_AXI_0_awlen <= 8'( ( wdata_buffer >> 64 ) - 1);
        S00_AXI_0_wlast <= 0;
        $display("%d : Write len: %h",i,  8'( ( wdata_buffer >> 64 ) - 1)); 
        
        // Wait for AWREADY and then de-assert AWVALID
        wait(S00_AXI_0_awready);
        wait(~S00_AXI_0_awready);
        S00_AXI_0_awvalid <= 0;
        
        // Wait for WREADY and then de-assert WVALID
        for( j = 0 ; j <= S00_AXI_0_awlen; j++) begin
            i = i + 1;
            S00_AXI_0_wdata <= 128'(i);
            wait(S00_AXI_0_wready);
            S00_AXI_0_wvalid <= 1;
            if( j == S00_AXI_0_awlen) begin
                S00_AXI_0_wlast <= 1;
            end
            #8; // wait one cycle to remain wavlid high
        end
        
        wait(~S00_AXI_0_wready);
        S00_AXI_0_wvalid <= 0;
        S00_AXI_0_wlast <= 0;
        
        // Wait for BVALID and then de-assert BREADY
        wait(S00_AXI_0_bvalid);
        S00_AXI_0_bready <= 0;
    end
end

endmodule
