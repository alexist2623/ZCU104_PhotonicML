module serializer
#(
    parameter int NUM_CHANNELS = 3,
    parameter real VIDEO_RATE
)
(
    input wire clk_pixel,
    input wire clk_pixel_x5,
    input wire reset,
    input wire [9:0] tmds_internal [NUM_CHANNELS-1:0],
    output wire [2:0] tmds,
    output wire tmds_clock
);

logic tmds_plus_clock [NUM_CHANNELS:0];
assign tmds_plus_clock = '{tmds_clock, tmds[2], tmds[1], tmds[0]};
logic [9:0] tmds_internal_plus_clock [NUM_CHANNELS:0];
assign tmds_internal_plus_clock = '{10'b0000011111, tmds_internal[2], tmds_internal[1], tmds_internal[0]};
logic [1:0] cascade [NUM_CHANNELS:0];

genvar i;
generate
    for (i = 0; i <= NUM_CHANNELS; i++)
    begin: xilinx_serialize
        OSERDESE3 #(
            .DATA_RATE_OQ("DDR"),
            .DATA_RATE_TQ("SDR"),
            .DATA_WIDTH(10),
            .SERDES_MODE("MASTER"),
            .TRISTATE_WIDTH(1),
            .TBYTE_CTL("FALSE"),
            .TBYTE_SRC("FALSE")
        ) primary (
            .OQ(tmds_plus_clock[i]),
            .OFB(),
            .TQ(),
            .TFB(),
            .SHIFTOUT1(),
            .SHIFTOUT2(),
            .TBYTEOUT(),
            .CLK(clk_pixel_x5),
            .CLKDIV(clk_pixel),
            .D1(tmds_internal_plus_clock[i][0]),
            .D2(tmds_internal_plus_clock[i][1]),
            .D3(tmds_internal_plus_clock[i][2]),
            .D4(tmds_internal_plus_clock[i][3]),
            .D5(tmds_internal_plus_clock[i][4]),
            .D6(tmds_internal_plus_clock[i][5]),
            .D7(tmds_internal_plus_clock[i][6]),
            .D8(tmds_internal_plus_clock[i][7]),
            .TCE(1'b0),
            .OCE(1'b1),
            .TBYTEIN(1'b0),
            .RST(reset),
            .SHIFTIN1(cascade[i][0]),
            .SHIFTIN2(cascade[i][1]),
            .T1(1'b0),
            .T2(1'b0),
            .T3(1'b0),
            .T4(1'b0)
        );
        OSERDESE2 #(
            .DATA_RATE_OQ("DDR"),
            .DATA_RATE_TQ("SDR"),
            .DATA_WIDTH(10),
            .SERDES_MODE("SLAVE"),
            .TRISTATE_WIDTH(1),
            .TBYTE_CTL("FALSE"),
            .TBYTE_SRC("FALSE")
        ) secondary (
            .OQ(),
            .OFB(),
            .TQ(),
            .TFB(),
            .SHIFTOUT1(cascade[i][0]),
            .SHIFTOUT2(cascade[i][1]),
            .TBYTEOUT(),
            .CLK(clk_pixel_x5),
            .CLKDIV(clk_pixel),
            .D1(1'b0),
            .D2(1'b0),
            .D3(tmds_internal_plus_clock[i][8]),
            .D4(tmds_internal_plus_clock[i][9]),
            .D5(1'b0),
            .D6(1'b0),
            .D7(1'b0),
            .D8(1'b0),
            .TCE(1'b0),
            .OCE(1'b1),
            .TBYTEIN(1'b0),
            .RST(reset),
            .SHIFTIN1(1'b0),
            .SHIFTIN2(1'b0),
            .T1(1'b0),
            .T2(1'b0),
            .T3(1'b0),
            .T4(1'b0)
        );
    end
endgenerate
endmodule
