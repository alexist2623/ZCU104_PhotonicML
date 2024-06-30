`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/30 21:45:25
// Design Name: 
// Module Name: TTLController_tb
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

module TTLController_tb;

// Parameters
parameter AXI_ADDR_WIDTH = 6;
parameter AXI_DATA_WIDTH = 128;
parameter AXI_STROBE_WIDTH = AXI_DATA_WIDTH >> 3;
parameter AXI_STROBE_LEN = 4;

// Inputs
reg [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
reg [15:0] s_axi_awid; 
reg [1:0] s_axi_awburst;
reg [2:0] s_axi_awsize;
reg [7:0] s_axi_awlen;
reg s_axi_awvalid;
reg [15:0] s_axi_awuser;
reg s_axi_bready;
reg [AXI_DATA_WIDTH - 1:0] s_axi_wdata;
reg [AXI_STROBE_WIDTH - 1:0] s_axi_wstrb;
reg s_axi_wvalid;
reg s_axi_wlast;
reg [1:0] s_axi_arburst;
reg [7:0] s_axi_arlen;
reg [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
reg [2:0] s_axi_arsize;
reg s_axi_arvalid;
reg [15:0] s_axi_arid;
reg [15:0] s_axi_aruser;
reg s_axi_rready;
reg s_axi_aclk;
reg s_axi_aresetn;

// Outputs
wire s_axi_awready;
wire [1:0] s_axi_bresp;
wire s_axi_bvalid;
wire [15:0] s_axi_bid;
wire s_axi_wready;
wire s_axi_arready;
wire [15:0] s_axi_rid;
wire [AXI_DATA_WIDTH - 1:0] s_axi_rdata;
wire [1:0] s_axi_rresp;
wire s_axi_rvalid;
wire s_axi_rlast;
wire ttl_out_00_p;
wire ttl_out_00_n;
wire ttl_out_01_p;
wire ttl_out_01_n;
wire ttl_out_02_p;
wire ttl_out_02_n;
wire ttl_out_03_p;
wire ttl_out_03_n;
wire ttl_out_04_p;
wire ttl_out_04_n;
wire ttl_out_05_p;
wire ttl_out_05_n;
wire ttl_out_06_p;
wire ttl_out_06_n;
wire ttl_out_07_p;
wire ttl_out_07_n;
wire ttl_out_08_p;
wire ttl_out_08_n;
wire ttl_out_09_p;
wire ttl_out_09_n;
wire ttl_out_10_p;
wire ttl_out_10_n;
wire ttl_out_11_p;
wire ttl_out_11_n;
wire ttl_out_12_p;
wire ttl_out_12_n;
wire ttl_out_13_p;
wire ttl_out_13_n;
wire ttl_out_14_p;
wire ttl_out_14_n;
wire ttl_out_15_p;
wire ttl_out_15_n;
wire ttl_out_16_p;
wire ttl_out_16_n;
wire ttl_out_17_p;
wire ttl_out_17_n;
wire ttl_out_18_p;
wire ttl_out_18_n;
wire ttl_out_19_p;
wire ttl_out_19_n;
wire ttl_out_20_p;
wire ttl_out_20_n;
wire ttl_out_21_p;
wire ttl_out_21_n;
wire ttl_out_22_p;
wire ttl_out_22_n;
wire ttl_out_23_p;
wire ttl_out_23_n;
wire ttl_out_24_p;
wire ttl_out_24_n;
wire ttl_out_25_p;
wire ttl_out_25_n;
wire ttl_out_26_p;
wire ttl_out_26_n;
wire ttl_out_27_p;
wire ttl_out_27_n;
wire ttl_out_28_p;
wire ttl_out_28_n;
wire ttl_out_29_p;
wire ttl_out_29_n;
wire ttl_out_30_p;
wire ttl_out_30_n;
wire ttl_out_31_p;
wire ttl_out_31_n;

// Instantiate the Unit Under Test (UUT)
TTLController #(
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STROBE_WIDTH(AXI_STROBE_WIDTH),
    .AXI_STROBE_LEN(AXI_STROBE_LEN)
) uut (
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awid(s_axi_awid),
    .s_axi_awburst(s_axi_awburst),
    .s_axi_awsize(s_axi_awsize),
    .s_axi_awlen(s_axi_awlen),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awuser(s_axi_awuser),
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
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .ttl_out_00_p(ttl_out_00_p),
    .ttl_out_00_n(ttl_out_00_n),
    .ttl_out_01_p(ttl_out_01_p),
    .ttl_out_01_n(ttl_out_01_n),
    .ttl_out_02_p(ttl_out_02_p),
    .ttl_out_02_n(ttl_out_02_n),
    .ttl_out_03_p(ttl_out_03_p),
    .ttl_out_03_n(ttl_out_03_n),
    .ttl_out_04_p(ttl_out_04_p),
    .ttl_out_04_n(ttl_out_04_n),
    .ttl_out_05_p(ttl_out_05_p),
    .ttl_out_05_n(ttl_out_05_n),
    .ttl_out_06_p(ttl_out_06_p),
    .ttl_out_06_n(ttl_out_06_n),
    .ttl_out_07_p(ttl_out_07_p),
    .ttl_out_07_n(ttl_out_07_n),
    .ttl_out_08_p(ttl_out_08_p),
    .ttl_out_08_n(ttl_out_08_n),
    .ttl_out_09_p(ttl_out_09_p),
    .ttl_out_09_n(ttl_out_09_n),
    .ttl_out_10_p(ttl_out_10_p),
    .ttl_out_10_n(ttl_out_10_n),
    .ttl_out_11_p(ttl_out_11_p),
    .ttl_out_11_n(ttl_out_11_n),
    .ttl_out_12_p(ttl_out_12_p),
    .ttl_out_12_n(ttl_out_12_n),
    .ttl_out_13_p(ttl_out_13_p),
    .ttl_out_13_n(ttl_out_13_n),
    .ttl_out_14_p(ttl_out_14_p),
    .ttl_out_14_n(ttl_out_14_n),
    .ttl_out_15_p(ttl_out_15_p),
    .ttl_out_15_n(ttl_out_15_n),
    .ttl_out_16_p(ttl_out_16_p),
    .ttl_out_16_n(ttl_out_16_n),
    .ttl_out_17_p(ttl_out_17_p),
    .ttl_out_17_n(ttl_out_17_n),
    .ttl_out_18_p(ttl_out_18_p),
    .ttl_out_18_n(ttl_out_18_n),
    .ttl_out_19_p(ttl_out_19_p),
    .ttl_out_19_n(ttl_out_19_n),
    .ttl_out_20_p(ttl_out_20_p),
    .ttl_out_20_n(ttl_out_20_n),
    .ttl_out_21_p(ttl_out_21_p),
    .ttl_out_21_n(ttl_out_21_n),
    .ttl_out_22_p(ttl_out_22_p),
    .ttl_out_22_n(ttl_out_22_n),
    .ttl_out_23_p(ttl_out_23_p),
    .ttl_out_23_n(ttl_out_23_n),
    .ttl_out_24_p(ttl_out_24_p),
    .ttl_out_24_n(ttl_out_24_n),
    .ttl_out_25_p(ttl_out_25_p),
    .ttl_out_25_n(ttl_out_25_n),
    .ttl_out_26_p(ttl_out_26_p),
    .ttl_out_26_n(ttl_out_26_n),
    .ttl_out_27_p(ttl_out_27_p),
    .ttl_out_27_n(ttl_out_27_n),
    .ttl_out_28_p(ttl_out_28_p),
    .ttl_out_28_n(ttl_out_28_n),
    .ttl_out_29_p(ttl_out_29_p),
    .ttl_out_29_n(ttl_out_29_n),
    .ttl_out_30_p(ttl_out_30_p),
    .ttl_out_30_n(ttl_out_30_n),
    .ttl_out_31_p(ttl_out_31_p),
    .ttl_out_31_n(ttl_out_31_n)
);

// Clock generation
initial begin
    s_axi_aclk = 0;
    forever #5 s_axi_aclk = ~s_axi_aclk;
end

integer i;
reg [127:0] random_data;

// Stimulus
initial begin
    // Initialize Inputs
    s_axi_awaddr = 0;
    s_axi_awid = 0;
    s_axi_awburst = 0;
    s_axi_awsize = 0;
    s_axi_awlen = 0;
    s_axi_awvalid = 0;
    s_axi_awuser = 0;
    s_axi_bready = 0;
    s_axi_wdata = 0;
    s_axi_wstrb = 0;
    s_axi_wvalid = 0;
    s_axi_wlast = 0;
    s_axi_arburst = 0;
    s_axi_arlen = 0;
    s_axi_araddr = 0;
    s_axi_arsize = 0;
    s_axi_arvalid = 0;
    s_axi_arid = 0;
    s_axi_aruser = 0;
    s_axi_rready = 0;
    s_axi_aresetn = 0;

    // Reset the system
    #100;
    s_axi_aresetn = 1;

    // Add stimulus here
    // Example AXI write transaction
    
    for( i = 0 ; i < 1000 ; i++) begin
        $display("%d th test",i);
        #10;
        s_axi_awaddr = 6'h0;
        s_axi_awsize = 3'b100;
        s_axi_awvalid = 1;
    
        wait(s_axi_awready);
        #10;
        s_axi_awvalid = 0;
    
        #10;
        random_data = $urandom;
        s_axi_wdata = random_data;
        s_axi_wstrb = 16'hFFFF;
        s_axi_wvalid = 1;
        s_axi_wlast = 1;
    
        wait(s_axi_wready);
        wait(~s_axi_wready);
        s_axi_wvalid = 0;
        s_axi_wlast = 0;
        
        #10;
        s_axi_bready = 1;
        wait(s_axi_bvalid);
        wait(~s_axi_bvalid);
        s_axi_bready = 0;
        
        $display("input : %x",random_data);
        #1000;
        if (ttl_out_00_p !== random_data[0]  ||
            ttl_out_01_p !== random_data[1]  ||
            ttl_out_02_p !== random_data[2]  ||
            ttl_out_03_p !== random_data[3]  ||
            ttl_out_04_p !== random_data[4]  ||
            ttl_out_05_p !== random_data[5]  ||
            ttl_out_06_p !== random_data[6]  ||
            ttl_out_07_p !== random_data[7]  ||
            ttl_out_08_p !== random_data[8]  ||
            ttl_out_09_p !== random_data[9]  ||
            ttl_out_10_p !== random_data[10] ||
            ttl_out_11_p !== random_data[11] ||
            ttl_out_12_p !== random_data[12] ||
            ttl_out_13_p !== random_data[13] ||
            ttl_out_14_p !== random_data[14] ||
            ttl_out_15_p !== random_data[15] ||
            ttl_out_16_p !== random_data[16] ||
            ttl_out_17_p !== random_data[17] ||
            ttl_out_18_p !== random_data[18] ||
            ttl_out_19_p !== random_data[19] ||
            ttl_out_20_p !== random_data[20] ||
            ttl_out_21_p !== random_data[21] ||
            ttl_out_22_p !== random_data[22] ||
            ttl_out_23_p !== random_data[23] ||
            ttl_out_24_p !== random_data[24] ||
            ttl_out_25_p !== random_data[25] ||
            ttl_out_26_p !== random_data[26] ||
            ttl_out_27_p !== random_data[27] ||
            ttl_out_28_p !== random_data[28] ||
            ttl_out_29_p !== random_data[29] ||
            ttl_out_30_p !== random_data[30] ||
            ttl_out_31_p !== random_data[31]) begin
            $display("ERROR!!!");
        end
    end

    // Example AXI read transaction
    #10;
    s_axi_araddr = 6'h0;
    s_axi_arsize = 3'b100;
    s_axi_arvalid = 1;

    wait(s_axi_arready);
    wait(~s_axi_arready);
    s_axi_arvalid = 0;

    #10;
    s_axi_rready = 1;
    wait(s_axi_rvalid);
    wait(~s_axi_rvalid);
    s_axi_rready = 0;

    // Finish the simulation
    #100;
    $finish;
end

endmodule

