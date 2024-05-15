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
localparam MASTER_CONTROLLER_AXI_CMD              = 39'h00_A000_0000;
localparam IMAGE_CONTROLLER_AXI_WRITE_FIFO        = 39'h00_A001_0000;
localparam IMAGE_CONTROLLER_AXI_FLUSH_FIFO        = 39'h00_A001_0010;
localparam IMAGE_CONTROLLER_AXI_WRITE_IMAGE_SIZE  = 39'h00_A001_0020;
localparam IMAGE_CONTROLLER_AXI_WRITE_DATA_DONE   = 39'h00_A001_0030;
localparam IMAGE_CONTROLLER_AXI_WRITE_DATA_BUFFER = 39'h00_A001_0040;
localparam IMAGE_CONTROLLER_AXI_SET_NEW_IMAGE     = 39'h00_A001_0050;
localparam IMAGE_CONTROLLER_AXI_DEASSERT_IRQ      = 39'h00_A001_0060;
localparam EXPOSURE_START_AXI_SET_DELAY           = 39'h00_A003_0010;
localparam EXPOSURE_START_AXI_SET_EVENT           = 39'h00_A003_0020;
localparam EXPOSURE_END_AXI_SET_DELAY             = 39'h00_A002_0010;
localparam EXPOSURE_END_AXI_SET_EVENT             = 39'h00_A002_0020;
localparam int START_X                            = 0;
localparam int START_Y                            = 1000;
localparam BIT_WIDTH                              = 12;
localparam BIT_HEIGHT                             = 12;
localparam FRAME_WIDTH                            = 2200;
localparam FRAME_HEIGHT                           = 1125;

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
reg [BIT_WIDTH - 1:0]   cx;
reg [BIT_HEIGHT - 1:0]  cy;
wire [23:0]             rgb;
reg                     image_change;
wire                    camera_exposure;
wire                    irq_signal;

reg [127:0]             wdata_buffer;
reg                     write_data_resp;

int i = 0; 
int j = 0;
localparam DATA_LEN = 4050;


//////////////////////////////////////////////////////////////////////////////////
// Main Module Declaration
//////////////////////////////////////////////////////////////////////////////////
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
    
    .cx                                 (cx),
    .cy                                 (cy),
    
    .s_axi_aresetn                      (s_axi_aresetn),
    .rgb                                (rgb),
    .image_change                       (image_change),
    .camera_exposure                    (camera_exposure),
    .irq_signal                         (irq_signal)
);

//////////////////////////////////////////////////////////////////////////////////
// Clock generation
//////////////////////////////////////////////////////////////////////////////////
initial begin
    s_axi_aclk = 0;
    forever #4 s_axi_aclk = ~s_axi_aclk; // Toggle every 4ns for 125MHz clock
end

//////////////////////////////////////////////////////////////////////////////////
// Clock generation for clk_pixel (148.5MHz)
//////////////////////////////////////////////////////////////////////////////////
initial begin
    clk_pixel = 0;
    forever #3.367 clk_pixel = ~clk_pixel; // Toggle every 3.367ns for 148.5MHz clock
end


//////////////////////////////////////////////////////////////////////////////////
// cx, cy generation
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clk_pixel) begin
    if (~s_axi_aresetn) begin
        cx <= BIT_WIDTH'(START_X);
        cy <= BIT_HEIGHT'(START_Y);
    end
    else begin
        cx <= (cx == FRAME_WIDTH-1'b1) ? BIT_WIDTH'(0) : cx + 1'b1;
        cy <= (cx == FRAME_WIDTH-1'b1) ? (cy == FRAME_HEIGHT-1'b1) ? BIT_HEIGHT'(0) : cy + 1'b1 : cy;
    end
end

//////////////////////////////////////////////////////////////////////////////////
// random signal generation delcaration
//////////////////////////////////////////////////////////////////////////////////
task generate_random_signal();
    int duration = $urandom_range(10,1000);
    int width = $urandom_range(10,1000);
    
    image_change <= 0;
    #10;
    image_change <= 1;
    #width;
    image_change <= 0;
    #duration;
endtask
   
//////////////////////////////////////////////////////////////////////////////////
// axi write task
//////////////////////////////////////////////////////////////////////////////////

task automatic axi_write(input [38:0] addr, input [127:0] data);
    S00_AXI_0_awsize <= 3'b100;
    S00_AXI_0_awaddr <= addr; // Example write address
    S00_AXI_0_awvalid <= 1;
    S00_AXI_0_wdata <= data; // Example write data
    S00_AXI_0_wstrb <= 16'hFFFF; // All bytes are valid
    S00_AXI_0_wlast <= 0;
    S00_AXI_0_wvalid <= 0;
    S00_AXI_0_bready <= 1'b1;
    
    // Wait for AWREADY and then de-assert AWVALID
    wait(S00_AXI_0_awready);
    wait(~S00_AXI_0_awready);
    S00_AXI_0_awvalid <= 0;
    
    // Wait for WREADY and then de-assert WVALID
    wait(S00_AXI_0_wready);
    S00_AXI_0_wvalid <= 1;
    S00_AXI_0_wlast <= 1;
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
endtask

//////////////////////////////////////////////////////////////////////////////////
// IRQ procedure task
//////////////////////////////////////////////////////////////////////////////////
task automatic IRQ_procedure();
    int k = 0;
    //////////////////////////////////////////////////////////////////////////////////
    // Deassert IRQ signal to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    
    wait(irq_signal);
    #8;
    axi_write(IMAGE_CONTROLLER_AXI_DEASSERT_IRQ, 128'(1)); // Example write address
    #8;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Data to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    for( k = 0 ; k < 625; k++ ) begin
        axi_write(IMAGE_CONTROLLER_AXI_WRITE_DATA_BUFFER, 128'(k));
        $display("write %d th data",k);
        k = k + 1;
        #8;
    end
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Data Done to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    #8;
    axi_write(IMAGE_CONTROLLER_AXI_WRITE_DATA_DONE, 128'(1));
endtask

initial begin
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
    write_data_resp <= 1'b0;

    //////////////////////////////////////////////////////////////////////////////////
    // Deassert s_axi_aresetn
    //////////////////////////////////////////////////////////////////////////////////
    #10000;
    s_axi_aresetn <= 1'b1;
    #10000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write ASSERT RESET command to MasterController
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(MASTER_CONTROLLER_AXI_CMD, 128'(4'b0010) );
    $display("WRITE ASSERT RESET CMD TO MASTERCONTROLLER");
    #1000;
        
    //////////////////////////////////////////////////////////////////////////////////
    // Write DEASSERT  RESET command to MasterController
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(MASTER_CONTROLLER_AXI_CMD,128'(4'b0000));
    $display("WRITE DEASSERT RESET CMD TO MASTERCONTROLLER");
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Delay time to Exposure Start
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(EXPOSURE_START_AXI_SET_DELAY,128'(1000));
    $display("SET EXPOSURE_START DELAY");
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Event time to Exposure Start
    ////////////////////////////////////////////////////////////////////////////////// 
    axi_write(EXPOSURE_START_AXI_SET_EVENT,128'(1));
    $display("SET EXPOSURE_START EVENT");
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Delay time to Exposure End
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(EXPOSURE_END_AXI_SET_DELAY,128'(0));
    $display("SET EXPOSURE_END DELAY");
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Event time to Exposure End
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(EXPOSURE_END_AXI_SET_EVENT,128'(10));
    $display("SET EXPOSURE_END EVENT");
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write Image Size Data to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(IMAGE_CONTROLLER_AXI_WRITE_IMAGE_SIZE,128'((100 << 32) | 100));
    #1000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Write to Memory address to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(MASTER_CONTROLLER_AXI_CMD, 128'(39'h04_0000_0000 | ( (39'h04_0000_0000 | 1920*1080) << 64 )));
    
    //////////////////////////////////////////////////////////////////////////////////
    //Write DATA to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    for( j = 0 ; j < 625; j++ ) begin
        axi_write(IMAGE_CONTROLLER_AXI_WRITE_DATA_BUFFER, 128'(i));
        $display("write %d th data",i);
        i = i + 1;
        #8;
    end
    //////////////////////////////////////////////////////////////////////////////////
    //Write DATA to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    for( j = 0 ; j < 625; j++ ) begin
        axi_write(IMAGE_CONTROLLER_AXI_WRITE_DATA_BUFFER, 128'(i));
        $display("write %d th data",i);
        i = i + 1;
        #8;
    end
    #1000;
    //////////////////////////////////////////////////////////////////////////////////
    // Write AUTOSTART command to MasterController
    //////////////////////////////////////////////////////////////////////////////////
    axi_write(MASTER_CONTROLLER_AXI_CMD, 128'(4'b1001)); // Example write address
    #40000000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // External Image Change Signal
    //////////////////////////////////////////////////////////////////////////////////
    for( j = 0 ; j < 10 ; j ++ ) begin
        generate_random_signal();
    end
    
    IRQ_procedure();
    #40000000;
    
    //////////////////////////////////////////////////////////////////////////////////
    // Set New image IRQ signal to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    #8;
    axi_write(IMAGE_CONTROLLER_AXI_SET_NEW_IMAGE, 128'(1));
    //////////////////////////////////////////////////////////////////////////////////
    // Deassert IRQ signal to ImageController
    //////////////////////////////////////////////////////////////////////////////////
    IRQ_procedure();
    
    $display("wait for 1frame discharges");
    #40000000;
    $display("End simulation");
    $finish;
end

endmodule
