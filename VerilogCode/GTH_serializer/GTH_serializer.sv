`timescale 1ps / 1ps

module GTH_serializer (
    input  wire s_axi_clk, //125MHz PL clk
    input  wire s_axi_resetn,
    input  wire [9:0] r,
    input  wire [9:0] g,
    input  wire [9:0] b, 
    input  wire gtrefclk00_in_p,
    input  wire gtrefclk00_in_n,
    input  wire clk_pixel_resetn,
    
    output wire gthtxn_out_0,
    output wire gthtxp_out_0,
    output wire gthtxn_out_1,
    output wire gthtxp_out_1,
    output wire gthtxn_out_2,
    output wire gthtxp_out_2,
    output wire out_en,
    output wire tmds_clk_p,
    output wire tmds_clk_n,
    output wire clk_pixel
);

reg [59:0] gtwiz_userdata_tx_in; //74.25MHz
reg [59:0] gtwiz_userdata_tx_in_buffer; //148.5MHz
reg phase = 1'b0;
reg s_axi_resetn_buffer1;
reg s_axi_resetn_buffer2;
reg clk_pixel_resetn_buffer1;
reg clk_pixel_resetn_buffer2;
reg [9:0] gtwiz_reset_all_in;
reg [0:0] gtwiz_reset_all_in_buffer1;
reg [0:0] gtwiz_reset_all_in_buffer2;
reg wait_reset;

//dummy wires
wire [0:0] gtwiz_reset_rx_cdr_stable_out;
wire [0:0] gtwiz_reset_tx_done_out;
wire [0:0] gtwiz_reset_rx_done_out;
wire [2:0] gtpowergood_out;
wire [2:0] rxpmaresetdone_out;
wire [2:0] txpmaresetdone_out;
wire [2:0] txprgdivresetdone_out;
wire locked;
wire underflow;
wire gtwiz_reset_clk_freerun_in_locked;

wire txoutclk_internal; //148.5MHz
wire txoutclk_div2; // 74.25MHz
wire txoutclk_delayed; // delayed 148.5MHz
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
wire empty;

assign reset = ~s_axi_resetn_buffer2;
assign clk_pixel = txoutclk_internal;
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
assign out_en = 1'b1;
assign wr_en = ~phase;

always@(posedge txoutclk_internal) begin // 148.5MHz
    phase <= ~phase;
    if( ~clk_pixel_resetn ) begin
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
    {clk_pixel_resetn_buffer2, clk_pixel_resetn_buffer1} <= {clk_pixel_resetn_buffer1, clk_pixel_resetn}; // from clk_pixel to txoutclk_div2
    if( ~clk_pixel_resetn_buffer2 ) begin
        gtwiz_userdata_tx_in <= 60'h0;
    end
    else begin
        gtwiz_userdata_tx_in <= gtwiz_userdata_tx_in_wire;
    end
end

always@(posedge s_axi_clk) begin
    {s_axi_resetn_buffer2, s_axi_resetn_buffer1} <= {s_axi_resetn_buffer1, s_axi_resetn}; // to relieve clock skew, not for CDC
    gtwiz_reset_all_in[9:0] <= {gtwiz_reset_all_in[8:0],1'b0}; // make 10 cycles of reset signal
    if( s_axi_resetn_buffer2 == 1'b0 ) begin
        wait_reset <= 1'b1;
    end
    if( s_axi_resetn_buffer2 == 1'b1 && wait_reset == 1'b1 && gtwiz_reset_clk_freerun_in_locked ) begin
        wait_reset <= 1'b0;
        gtwiz_reset_all_in[9:0] <= 10'h3ff;
    end
end

always@(posedge gtwiz_reset_clk_freerun_in) begin
    {gtwiz_reset_all_in_buffer2, gtwiz_reset_all_in_buffer1} <= {gtwiz_reset_all_in_buffer1, gtwiz_reset_all_in[9]}; // from s_axi_clk to gtwiz_reset_clk_freerun_in
end

gtwizard_ultrascale_0 gtwizard_ultrascale_0 (
    .gthrxn_in                               (3'b000),
    .gthrxp_in                               (3'b111),
    .gthtxn_out                              (gthtxn_out),
    .gthtxp_out                              (gthtxp_out),
    .gtwiz_userclk_tx_active_in              (s_axi_resetn_buffer2),
    .gtwiz_userclk_rx_active_in              (1'b0),
    .gtwiz_reset_clk_freerun_in              (gtwiz_reset_clk_freerun_in),
    .gtwiz_reset_all_in                      (gtwiz_reset_all_in_buffer2),
    .gtwiz_reset_tx_pll_and_datapath_in      (gtwiz_reset_all_in_buffer2),
    .gtwiz_reset_tx_datapath_in              (gtwiz_reset_all_in_buffer2),
    .gtwiz_reset_rx_pll_and_datapath_in      (gtwiz_reset_all_in_buffer2),
    .gtwiz_reset_rx_datapath_in              (gtwiz_reset_all_in_buffer2),
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

GTH_serializer_async_fifo GTH_serializer_async_fifo_0
(
    .wr_clk                                  (txoutclk_internal), //148.5MHz
    .rd_clk                                  (txoutclk_div2), //74.25MHz
    .srst                                    (~clk_pixel_resetn_buffer2), //148.5MHz
    .underflow                               (underflow),
    .wr_rst_busy                             (),
    .rd_rst_busy                             (),
    .wr_en                                   (wr_en),
    .rd_en                                   (~empty),
    .din                                     (gtwiz_userdata_tx_in_buffer),
    .dout                                    (gtwiz_userdata_tx_in_wire),
    .full                                    (),
    .empty                                   (empty)
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

clk_wiz_1 clk_wiz_1(
    .reset                                   (reset),
    .clk_in1                                 (s_axi_clk),
    .clk_out1                                (gtwiz_reset_clk_freerun_in),
    .locked                                  (gtwiz_reset_clk_freerun_in_locked)
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