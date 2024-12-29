`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 23:25:29
// Design Name: 
// Module Name: ZCU104CameraSIM_tb
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
`include "axi_interface.sv"

module ZCU104CameraSIM_tb;

localparam DRAM_ADDR_BASE        = 32'h80000000;
localparam real CLINK_PERIOD_ON = 6.968641114982579;
localparam real CLINK_PERIOD_OFF= 5.2264808362369335;
localparam real CLINK_PERIODx7  = 0.8710801393728224;

wire SerTC;
wire cc1;
wire cc2;
wire cc3;
wire cc4;
logic  clink_X_clk_n;
logic  clink_X_clk_p;
logic  clink_X_data_0_n;
logic  clink_X_data_0_p;
logic  clink_X_data_1_n;
logic  clink_X_data_1_p;
logic  clink_X_data_2_n;
logic  clink_X_data_2_p;
logic  clink_X_data_3_n;
logic  clink_X_data_3_p;

reg  clink_X_clk;
reg  clink_X_data_0;
reg  clink_X_data_1;
reg  clink_X_data_2;
reg  clink_X_data_3;

wire GPIO_LED_0_LS;
wire GPIO_LED_1_LS;

reg  s_axi_aclk;

logic [127:0] axi_read_data;
logic [31:0] axi_read_addr;

assign clink_X_clk_p =  clink_X_clk;
assign clink_X_clk_n = ~clink_X_clk;
assign clink_X_data_0_p =  clink_X_data_0;
assign clink_X_data_0_n = ~clink_X_data_0;
assign clink_X_data_1_p =  clink_X_data_1;
assign clink_X_data_1_n = ~clink_X_data_1;
assign clink_X_data_2_p =  clink_X_data_2;
assign clink_X_data_2_n = ~clink_X_data_2;
assign clink_X_data_3_p =  clink_X_data_3;
assign clink_X_data_3_n = ~clink_X_data_3;

// Instantiate AXI interface
axi_if axi_if_inst(
    .s_axi_aclk         (s_axi_aclk)
);

// Instantiate ZCU104CaemraSIM_uut
ZCU104CaemraSIM_uut uut (
    .axi_if_inst        (axi_if_inst),
    .SerTC              (SerTC),
    .cc1                (cc1),
    .cc2                (cc2),
    .cc3                (cc3),
    .cc4                (cc4),
    .clink_X_clk_n      (clink_X_clk_n),
    .clink_X_clk_p      (clink_X_clk_p),
    .clink_X_data_0_n   (clink_X_data_0_n),
    .clink_X_data_0_p   (clink_X_data_0_p),
    .clink_X_data_1_n   (clink_X_data_1_n),
    .clink_X_data_1_p   (clink_X_data_1_p),
    .clink_X_data_2_n   (clink_X_data_2_n),
    .clink_X_data_2_p   (clink_X_data_2_p),
    .clink_X_data_3_n   (clink_X_data_3_n),
    .clink_X_data_3_p   (clink_X_data_3_p),
    .GPIO_LED_0_LS      (GPIO_LED_0_LS),
    .GPIO_LED_1_LS      (GPIO_LED_1_LS)
);

initial begin
    s_axi_aclk = 0;
    forever #4 s_axi_aclk = ~s_axi_aclk;
end

initial begin
    clink_X_clk <= 1'b0;
    forever begin
        // To generate 7'b1100011 clock
        #CLINK_PERIOD_OFF clink_X_clk <= 1'b1;
        #CLINK_PERIOD_ON  clink_X_clk <= 1'b0;
    end
end

reg clk_x7;
initial begin
    clk_x7 = 0;
    forever begin
        #CLINK_PERIODx7 clk_x7 = ~clk_x7;
    end
end

reg [23:0] random_data;

always @(posedge clk_x7) begin
    /*
     * Wait for stabilization of 7:1 deserializer
     */
     if (GPIO_LED_0_LS == 1'b1) begin
        random_data = $urandom;
        clink_X_data_0 <= random_data[0];
        clink_X_data_1 <= random_data[1];
        clink_X_data_2 <= random_data[2];
        clink_X_data_3 <= random_data[3];
    end
    else begin
        random_data = 0; 
    end
end

initial begin
    axi_if_inst.init();
    clink_X_data_0 <= 1'b0;
    clink_X_data_1 <= 1'b0;
    clink_X_data_2 <= 1'b0;
    clink_X_data_3 <= 1'b0;
    axi_read_addr <= DRAM_ADDR_BASE;
    
    #1000;
    axi_if_inst.init();
    
    wait(GPIO_LED_0_LS);
    $display("7:1 deserializer stabilized");
    
    #23000;
    #100;
    
    // axi_if_inst.read(axi_read_addr,axi_read_data);
    
    #100;
    $finish;
end

endmodule
