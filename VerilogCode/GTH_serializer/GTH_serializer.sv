module GTH_serializer (
    input  wire clk, // 148.5MHz
    input  wire resetn,
    input  wire [9:0] r,
    input  wire [9:0] g,
    input  wire [9:0] b, 
    output wire [2:0] gthtxn_out,
    output wire [2:0] gthtxp_out,
    output wire [0:0] gtwiz_reset_rx_cdr_stable_out,
    output wire [0:0] gtwiz_reset_tx_done_out,
    output wire [0:0] gtwiz_reset_rx_done_out,
    output wire [2:0] gtpowergood_out,
    output wire [2:0] rxpmaresetdone_out,
    output wire [2:0] txpmaresetdone_out,
    output wire [2:0] txprgdivresetdone_out,
    output wire txoutclk_out,
    output wire txoutclk_pll_out,
    output wire locked
);
    wire [0:0] qpll0outclk_out;
    wire [0:0] qpll0outrefclk_out;
    wire [59:0] gtwiz_userdata_rx_out;
    wire reset;
    assign reset = ~resetn;

    reg [59:0] gtwiz_userdata_tx_in; //74.25MHz
    reg [0:0] gtrefclk00_in = 1'b0; //74.25MHz
    wire [0:0] gtwiz_reset_rx_datapath_in;
    wire [0:0] gtwiz_reset_rx_pll_and_datapath_in;
    wire [0:0] gtwiz_reset_all_in;
    wire [0:0] gtwiz_reset_tx_pll_and_datapath_in;
    wire [0:0] gtwiz_reset_tx_datapath_in;
    wire [0:0] gtwiz_reset_clk_freerun_in;
    
    assign gtwiz_reset_all_in = reset;
    assign gtwiz_reset_rx_datapath_in = reset;
    assign gtwiz_reset_rx_pll_and_datapath_in = reset;
    assign gtwiz_reset_tx_pll_and_datapath_in = reset;
    assign gtwiz_reset_tx_datapath_in = reset;
    assign gtwiz_reset_clk_freerun_in = gtrefclk00_in;
    
    always@(posedge clk) begin
        gtrefclk00_in <= ~gtrefclk00_in;
        if( reset == 1'b1 ) begin
            gtrefclk00_in <= 1'b0;
            gtwiz_userdata_tx_in <= 60'h0;
        end
        else begin
            if( gtrefclk00_in == 1'b0 ) begin
                gtwiz_userdata_tx_in[9:0] <= r[9:0];
                gtwiz_userdata_tx_in[29:20] <= g[9:0];
                gtwiz_userdata_tx_in[49:40] <= b[9:0];
            end
            else begin
                gtwiz_userdata_tx_in[19:10] <= r[9:0];
                gtwiz_userdata_tx_in[39:30] <= g[9:0];
                gtwiz_userdata_tx_in[59:50] <= b[9:0];
            end
        end
    end
    
    wire [2:0] txusrclk_int;
    wire [2:0] txusrclk2_int;
    wire [2:0] txoutclk_int;
    wire [2:0] rxusrclk_int;
    wire [2:0] rxusrclk2_int;
    wire [2:0] rxoutclk_int;
    wire [2:0] gtpowergood_int;
    
    assign txoutclk_out = txoutclk_int[0];
    assign txusrclk_int  = {3{gtrefclk00_in}};
    assign txusrclk2_int = {3{gtrefclk00_in}};
    assign rxusrclk_int  = {3{gtrefclk00_in}};
    assign rxusrclk2_int = {3{gtrefclk00_in}};
    assign gtpowergood_out = gtpowergood_int;

gtwizard_ultrascale_0 gtwizard_ultrascale_0 (
    .gthrxn_in                               (3'b000),
    .gthrxp_in                               (3'b111),
    .gthtxn_out                              (gthtxn_out),
    .gthtxp_out                              (gthtxp_out),
    .gtwiz_userclk_tx_active_in              (~reset),
    .gtwiz_userclk_rx_active_in              (1'b0),
    .gtwiz_reset_clk_freerun_in              (gtwiz_reset_clk_freerun_in),
    .gtwiz_reset_all_in                      (gtwiz_reset_all_in),
    .gtwiz_reset_tx_pll_and_datapath_in      (gtwiz_reset_tx_pll_and_datapath_in),
    .gtwiz_reset_tx_datapath_in              (gtwiz_reset_tx_datapath_in),
    .gtwiz_reset_rx_pll_and_datapath_in      (gtwiz_reset_rx_pll_and_datapath_in),
    .gtwiz_reset_rx_datapath_in              (gtwiz_reset_rx_datapath_in),
    .gtwiz_reset_rx_cdr_stable_out           (gtwiz_reset_rx_cdr_stable_out),
    .gtwiz_reset_tx_done_out                 (gtwiz_reset_tx_done_out),
    .gtwiz_reset_rx_done_out                 (gtwiz_reset_rx_done_out),
    .gtwiz_userdata_tx_in                    (gtwiz_userdata_tx_in),
    .gtwiz_userdata_rx_out                   (gtwiz_userdata_rx_out),
    .gtrefclk00_in                           (gtrefclk00_in),
    .qpll0outclk_out                         (qpll0outclk_out),
    .qpll0outrefclk_out                      (qpll0outrefclk_out),
    .rxusrclk_in                             (rxusrclk_int),
    .rxusrclk2_in                            (rxusrclk2_int),
    .txusrclk_in                             (txusrclk_int),
    .txusrclk2_in                            (txusrclk2_int),
    .gtpowergood_out                         (gtpowergood_int),
    .rxoutclk_out                            (rxoutclk_int),
    .rxpmaresetdone_out                      (rxpmaresetdone_out),
    .txoutclk_out                            (txoutclk_int),
    .txpmaresetdone_out                      (txpmaresetdone_out),
    .txprgdivresetdone_out                   (txprgdivresetdone_out)
);

clk_wiz_0 clk_wiz_0(
    .reset(reset),
    .clk_in1(~txoutclk_out),
    .clk_out1(txoutclk_pll_out),
    .locked(locked)
);

endmodule