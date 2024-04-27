`timescale 1ns / 0.01ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 18:08:28
// Design Name: 
// Module Name: GTH_sim00
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


module GTH_sim00;

// Testbench signals
reg resetn;
reg [9:0] r;
reg [9:0] g;
reg [9:0] b;
reg gtrefclk00_in_p;
wire gtrefclk00_in_n;
wire [2:0] gthtxn_out;
wire [2:0] gthtxp_out;
wire gtwiz_reset_rx_cdr_stable_out;
wire gtwiz_reset_tx_done_out;
wire gtwiz_reset_rx_done_out;
wire [59:0] gtwiz_userdata_rx_out;
wire qpll0outclk_out;
wire qpll0outrefclk_out;
wire [2:0] gtpowergood_out;
wire [2:0] rxpmaresetdone_out;
wire [2:0] txpmaresetdone_out;
wire [2:0] txprgdivresetdone_out;
wire txoutclk_out;
wire txoutclk_pll_out;
wire locked;

wire tmds_clk_p;
wire tmds_clk_n;
wire gthtxn_out_0;
wire gthtxp_out_0;
wire gthtxn_out_1;
wire gthtxp_out_1;
wire gthtxn_out_2;
wire gthtxp_out_2;
wire out_en;

assign gtrefclk00_in_n = ~gtrefclk00_in_p;

// Instantiate the module under test (MUT)
GTH_serializer mut (
    .resetn(resetn),
    .r(r),
    .g(g),
    .b(b),
    .gtrefclk00_in_p(gtrefclk00_in_p),
    .gtrefclk00_in_n(gtrefclk00_in_n),
    .gthtxn_out_0(gthtxn_out_0),
    .gthtxp_out_0(gthtxp_out_0),
    .gthtxn_out_1(gthtxn_out_1),
    .gthtxp_out_1(gthtxp_out_1),
    .gthtxn_out_2(gthtxn_out_2),
    .gthtxp_out_2(gthtxp_out_2),
    .gtwiz_reset_rx_cdr_stable_out(gtwiz_reset_rx_cdr_stable_out),
    .gtwiz_reset_tx_done_out(gtwiz_reset_tx_done_out),
    .gtpowergood_out(gtpowergood_out),
    .rxpmaresetdone_out(rxpmaresetdone_out),
    .txpmaresetdone_out(txpmaresetdone_out),
    .txprgdivresetdone_out(txprgdivresetdone_out),
    .tmds_clk_p(tmds_clk_p),
    .tmds_clk_n(tmds_clk_n),
    .locked(locked),
    .out_en(out_en)
);

// Clock generation
initial begin
    gtrefclk00_in_p = 0;
    forever #3.2 gtrefclk00_in_p = ~gtrefclk00_in_p; // 74.25MHz clock period
end

// Initial block for reset and input stimulus
initial begin
    // Initialize inputs
    resetn = 0;
    r = 0;
    g = 0;
    b = 0;

    // Reset the system
    #3378;
    resetn = 1;

    // Apply test vectors
    #33.78;
    r = 10'h3FF;
    g = 10'h1FF;
    b = 10'h0FF;
end
endmodule
