`timescale 1ps / 1ps

module GTH_serializer (
    input  wire clk, 
    input  wire resetn,
    input  wire [9:0] r,
    input  wire [9:0] g,
    input  wire [9:0] b, 
    input  wire gtrefclk00_in_p,
    input  wire gtrefclk00_in_n,
    
    output wire gthtxn_out_0,
    output wire gthtxp_out_0,
    output wire gthtxn_out_1,
    output wire gthtxp_out_1,
    output wire gthtxn_out_2,
    output wire gthtxp_out_2,
    output wire out_en,
    output wire [0:0] gtwiz_reset_rx_cdr_stable_out,
    output wire [0:0] gtwiz_reset_tx_done_out,
    output wire [0:0] gtwiz_reset_rx_done_out,
    output wire [2:0] gtpowergood_out,
    output wire [2:0] rxpmaresetdone_out,
    output wire [2:0] txpmaresetdone_out,
    output wire [2:0] txprgdivresetdone_out,
    output wire tmds_clk_p,
    output wire tmds_clk_n,
    output wire txoutclk,
    output wire locked,
    output wire underflow,
    output wire resetn_out
);

reg [59:0] gtwiz_userdata_tx_in; //74.25MHz
reg [59:0] gtwiz_userdata_tx_in_buffer; //148.5MHz
reg reset_buffer1;//74.25MHz
reg reset_buffer2;//74.25MHz
reg phase = 1'b0;

wire txoutclk_internal; //148.5MHz
wire txoutclk_div2; // 74.25MHz
wire txoutclk_delayed; // delayed 148.5MHz
wire [0:0] gtwiz_reset_rx_datapath_in;
wire [0:0] gtwiz_reset_rx_pll_and_datapath_in;
wire [0:0] gtwiz_reset_all_in;
wire [0:0] gtwiz_reset_tx_pll_and_datapath_in;
wire [0:0] gtwiz_reset_tx_datapath_in;
wire [0:0] gtwiz_reset_clk_freerun_in;
wire [2:0] txusrclk_int;
wire [2:0] txusrclk2_int;
wire [2:0] txoutclk_int;
wire [2:0] rxusrclk_int;
wire [2:0] rxusrclk2_int;
wire [2:0] rxoutclk_int;
wire [2:0] gtpowergood_int;
wire [2:0] gthtxn_out;
wire [2:0] gthtxp_out;
wire [0:0] qpll0outclk_out;
wire [0:0] qpll0outrefclk_out;
wire [59:0] gtwiz_userdata_rx_out;
wire reset;
wire gtrefclk00_in; //156.5MHz
wire wr_en;
wire [59:0] gtwiz_userdata_tx_in_wire;

assign reset = ~resetn;
assign txoutclk = txoutclk_internal;
assign resetn_out = reset_buffer2;
assign gthtxp_out_0 = gthtxp_out[0];
assign gthtxp_out_1 = gthtxp_out[1];
assign gthtxp_out_2 = gthtxp_out[2];
assign gthtxn_out_0 = gthtxn_out[0];
assign gthtxn_out_1 = gthtxn_out[1];
assign gthtxn_out_2 = gthtxn_out[2];
assign txusrclk_int  = {3{txoutclk_div2}};
assign txusrclk2_int = {3{txoutclk_div2}};
assign rxusrclk_int  = {3{txoutclk_div2}};
assign rxusrclk2_int = {3{txoutclk_div2}};
assign gtpowergood_out = gtpowergood_int;
assign gtwiz_reset_all_in = reset;
assign gtwiz_reset_rx_datapath_in = reset;
assign gtwiz_reset_rx_pll_and_datapath_in = reset;
assign gtwiz_reset_tx_pll_and_datapath_in = reset;
assign gtwiz_reset_tx_datapath_in = reset;
assign gtwiz_reset_clk_freerun_in = txoutclk_div2;
assign out_en = 1'b1;
assign wr_en = ~phase;

always@(posedge clk) begin // 148.5MHz
    phase <= ~phase;
    if( reset == 1'b1 ) begin
        gtwiz_userdata_tx_in_buffer <= 60'h0;
        phase <= 1'b0;
    end
    else begin
        if( phase == 1'b0 ) begin
            gtwiz_userdata_tx_in_buffer[9:0] <= r[9:0];
            gtwiz_userdata_tx_in_buffer[29:20] <= g[9:0];
            gtwiz_userdata_tx_in_buffer[49:40] <= b[9:0];
        end
        else begin
            gtwiz_userdata_tx_in_buffer[19:10] <= r[9:0];
            gtwiz_userdata_tx_in_buffer[39:30] <= g[9:0];
            gtwiz_userdata_tx_in_buffer[59:50] <= b[9:0];
        end
    end
end

always@(posedge txoutclk_div2) begin // 74,25MHz
    {reset_buffer2, reset_buffer1} <= {reset_buffer2, reset};
    if( reset_buffer2 == 1'b1 ) begin
        gtwiz_userdata_tx_in <= 60'h0;
    end
    else begin
        gtwiz_userdata_tx_in <= gtwiz_userdata_tx_in_wire;
    end
end

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

OBUFDS #(
    .IOSTANDARD                              ("DEFAULT")
) OBUFDS_inst (
    .O                                       (tmds_clk_p),
    .OB                                      (tmds_clk_n),
    .I                                       (txoutclk_delayed)
);

fifo_generator_0 async_fifo
(
    .wr_clk                                  (txoutclk_internal), //148.5MHz
    .rd_clk                                  (txoutclk_div2), //74.25MHz
    .srst                                    (reset),
    .underflow                               (underflow),
    .wr_rst_busy                             (),
    .rd_rst_busy                             (),
    .wr_en                                   (wr_en),
    .rd_en                                   (1'b1),
    .din                                     (gtwiz_userdata_tx_in_buffer),
    .dout                                    (gtwiz_userdata_tx_in_wire),
    .full                                    (),
    .empty                                   ()
);

BUFG_GT #(
   .SIM_DEVICE                               ("ULTRASCALE_PLUS")
)
BUFG_GT_inst_0 (
   .O                                        (txoutclk_internal),
   .CE                                       (1'b1),
   .CEMASK                                   (1'b0),
   .CLR                                      (reset),
   .CLRMASK                                  (1'b0),
   .DIV                                      (3'b000),
   .I                                        (txoutclk_int[0])
);

clk_wiz_0 clk_wiz_0(
    .reset                                   (reset),
    .clk_in1                                 (txoutclk_internal),
    .clk_out1                                (txoutclk_delayed),
    .clk_out2                                (txoutclk_div2),
    .locked                                  (locked)
);

IBUFDS_GTE4 #(
   .REFCLK_EN_TX_PATH                        (1'b0),
   .REFCLK_HROW_CK_SEL                       (2'b00),
   .REFCLK_ICNTL_RX                          (2'b00)
)
IBUFDS_GTE4_inst (
   .O                                        (gtrefclk00_in),
   .ODIV2                                    (),
   .CEB                                      (1'b0),
   .I                                        (gtrefclk00_in_p),
   .IB                                       (gtrefclk00_in_n)
);

endmodule