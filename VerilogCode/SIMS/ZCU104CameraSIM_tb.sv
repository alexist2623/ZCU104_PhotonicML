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

localparam DRAM_ADDR_BASE               = 48'h4_0000_0000;
localparam CLINK_INTF_AXI_ADDR          = 48'hA000_0000;
localparam CLINK_INTF_READ_IMG_NUM_ADRR = 48'hA000_0010;
localparam MASTER_CONTROLLER_AXI_ADDR   = 48'hA000_1000;
localparam AXI_ADDR_WIDTH               = 48;
localparam real CLINK_PERIOD_ON         = 6.968641114982579;
localparam real CLINK_PERIOD_OFF        = 5.2264808362369335;
localparam real CLINK_PERIODx7          = 0.8710801393728224;

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

reg clink_LVAL;
reg clink_DVAL;
reg clink_FVAL;
reg clink_RES;
reg clink_C7;
reg clink_C6;
reg clink_C5;
reg clink_C4;
reg clink_C3;
reg clink_C2;
reg clink_C1;
reg clink_C0;
reg clink_B7;
reg clink_B6;
reg clink_B5;
reg clink_B4;
reg clink_B3;
reg clink_B2;
reg clink_B1;
reg clink_B0;
reg clink_A7;
reg clink_A6;
reg clink_A5;
reg clink_A4;
reg clink_A3;
reg clink_A2;
reg clink_A1;
reg clink_A0;


logic [127:0] axi_read_data;
logic [48:0] axi_read_addr;

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
axi_if #(
    //////////////////////////////////////////////////////////////////////////////////
    // AXI4 Configuraiton
    //////////////////////////////////////////////////////////////////////////////////
    .AXI_ADDR_WIDTH     (AXI_ADDR_WIDTH)
)axi_if_inst (
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

parameter IMAGE_DATA_NUM = 16;
parameter IMAGE_LINE_NUM = 16;
parameter IMAGE_DURATION = 256;
parameter IMAGE_FVAL_DURATION = 16;
parameter IMAGE_DATA_NUM_WIDTH = $clog2(IMAGE_DATA_NUM);
parameter IMAGE_LINE_NUM_WIDTH = $clog2(IMAGE_LINE_NUM);

reg [IMAGE_DATA_NUM_WIDTH:0] image_data_cnt;
reg [IMAGE_LINE_NUM_WIDTH:0] image_line_cnt;
reg [9:0] image_num_cnt;
reg [9:0] image_duration_cnt;
reg [9:0] image_fval_cnt;

reg [10:0] image_index;
reg clink_data_gen_en;

initial begin
    image_index <= 0;
    clink_data_gen_en <= 1'b0;

    image_data_cnt <= 0;
    image_line_cnt <= 0;
    image_num_cnt <= 0;
    image_duration_cnt <= 0;
    image_fval_cnt <= 0;

    clink_X_data_0 <= 1'b0;
    clink_X_data_1 <= 1'b0;
    clink_X_data_2 <= 1'b0;
    clink_X_data_3 <= 1'b0;

    clink_LVAL <= 1'b0;
    clink_DVAL <= 1'b0;
    clink_FVAL <= 1'b0;
    clink_RES <= 1'b0;
    clink_C7 <= 1'b0;
    clink_C6 <= 1'b0;
    clink_C5 <= 1'b0;
    clink_C4 <= 1'b0;
    clink_C3 <= 1'b0;
    clink_C2 <= 1'b0;
    clink_C1 <= 1'b0;
    clink_C0 <= 1'b0;
    clink_B7 <= 1'b0;
    clink_B6 <= 1'b0;
    clink_B5 <= 1'b0;
    clink_B4 <= 1'b0;
    clink_B3 <= 1'b0;
    clink_B2 <= 1'b0;
    clink_B1 <= 1'b0;
    clink_B0 <= 1'b0;
    clink_A7 <= 1'b0;
    clink_A6 <= 1'b0;
    clink_A5 <= 1'b0;
    clink_A4 <= 1'b0;
    clink_A3 <= 1'b0;
    clink_A2 <= 1'b0;
    clink_A1 <= 1'b0;
    clink_A0 <= 1'b0;

    clink_X_clk <= 1'b0;
    forever begin
        // To generate 7'b1100011 clock
        if (GPIO_LED_0_LS == 1'b1) begin
            //////////////////////////////
            // Data Setting
            // Set the image data with a random value
            //////////////////////////////
            if (image_line_cnt == (IMAGE_LINE_NUM+1)) begin
                clink_LVAL = 1'b0;
                image_data_cnt <= 0;
                image_line_cnt <= 0;
                image_duration_cnt <= 0;
                $display("IMAGE GENERATION DONE");
                $display("LAST WRITTEN DATA : %x", image_index);
            end
            else if ((image_duration_cnt == IMAGE_DURATION - 1 && clink_LVAL == 1'b0) || clink_LVAL == 1'b1) begin
                if (clink_data_gen_en == 1'b1) begin
                    clink_LVAL = 1'b1;
                end
                if (image_data_cnt == IMAGE_DATA_NUM) begin
                    image_data_cnt <= 0;
                    clink_DVAL = 1'b0;
                    clink_FVAL = 1'b0;
                    image_fval_cnt = image_fval_cnt + 1;
                end
                else if ((image_fval_cnt == IMAGE_FVAL_DURATION - 1 && clink_FVAL == 1'b0) || clink_FVAL == 1'b1) begin
                    if (clink_data_gen_en == 1'b1) begin
                        clink_DVAL = 1'b1;
                        clink_FVAL = 1'b1;
                        image_data_cnt = image_data_cnt + 1;
                        image_fval_cnt = 0;
    
                        clink_RES  = 1'b0;
                        clink_C7 = image_index[7];
                        clink_C6 = image_index[6];
                        clink_C5 = image_index[5];
                        clink_C4 = image_index[4];
                        clink_C3 = image_index[3];
                        clink_C2 = image_index[2];
                        clink_C1 = image_index[1];
                        clink_C0 = image_index[0];
                        clink_B7 = image_index[7];
                        clink_B6 = image_index[6];
                        clink_B5 = image_index[5];
                        clink_B4 = image_index[4];
                        clink_B3 = image_index[3];
                        clink_B2 = image_index[2];
                        clink_B1 = image_index[1];
                        clink_B0 = image_index[0];
                        clink_A7 = image_index[7];
                        clink_A6 = image_index[6];
                        clink_A5 = image_index[5];
                        clink_A4 = image_index[4];
                        clink_A3 = image_index[3];
                        clink_A2 = image_index[2];
                        clink_A1 = image_index[1];
                        clink_A0 = image_index[0];
    
                        image_index <= image_index + 1;
                    end
                end
                else if (clink_FVAL == 1'b0) begin
                    image_fval_cnt <= image_fval_cnt + 1;
                    if (image_fval_cnt == (IMAGE_FVAL_DURATION >> 1)) begin
                        image_line_cnt = image_line_cnt + 1;
                    end
                end
            end
            else if ( clink_LVAL == 1'b0) begin
                image_duration_cnt = image_duration_cnt + 1;
            end
            //////////////////////////////
            // 0
            //////////////////////////////
            clink_X_clk <= 1'b1;
            clink_X_data_0 <= clink_B0;
            clink_X_data_1 <= clink_C1;
            clink_X_data_2 <= clink_DVAL;
            clink_X_data_3 <= clink_RES;

            #(CLINK_PERIOD_ON/4);
            //////////////////////////////
            // 1
            //////////////////////////////
            clink_X_clk <= 1'b1;
            clink_X_data_0 <= clink_A5;
            clink_X_data_1 <= clink_C0;
            clink_X_data_2 <= clink_FVAL;
            clink_X_data_3 <= clink_C7;

            #(CLINK_PERIOD_ON/4);
            //////////////////////////////
            // 2
            //////////////////////////////
            clink_X_clk <= 1'b0;
            clink_X_data_0 <= clink_A4;
            clink_X_data_1 <= clink_B5;
            clink_X_data_2 <= clink_LVAL;
            clink_X_data_3 <= clink_C6;

            #(CLINK_PERIOD_OFF/3);
            //////////////////////////////
            // 3
            //////////////////////////////
            clink_X_clk <= 1'b0;
            clink_X_data_0 <= clink_A3;
            clink_X_data_1 <= clink_B4;
            clink_X_data_2 <= clink_C5;
            clink_X_data_3 <= clink_B7;

            #(CLINK_PERIOD_OFF/3);
            //////////////////////////////
            // 4
            //////////////////////////////
            clink_X_clk <= 1'b0;
            clink_X_data_0 <= clink_A2;
            clink_X_data_1 <= clink_B3;
            clink_X_data_2 <= clink_C4;
            clink_X_data_3 <= clink_B6;

            #(CLINK_PERIOD_OFF/3);
            //////////////////////////////
            // 5
            //////////////////////////////
            clink_X_clk <= 1'b1;
            clink_X_data_0 <= clink_A1;
            clink_X_data_1 <= clink_B2;
            clink_X_data_2 <= clink_C3;
            clink_X_data_3 <= clink_A7;

            #(CLINK_PERIOD_ON/4);
            //////////////////////////////
            // 6
            //////////////////////////////
            clink_X_clk <= 1'b1;
            clink_X_data_0 <= clink_A0;
            clink_X_data_1 <= clink_B1;
            clink_X_data_2 <= clink_C2;
            clink_X_data_3 <= clink_A6;

            #(CLINK_PERIOD_ON/4);
        end
        else begin
            clink_X_clk <= 1'b1;
            #(CLINK_PERIOD_ON/4);
            // 1
            clink_X_clk <= 1'b1;
            #(CLINK_PERIOD_ON/4);
            // 2
            clink_X_clk <= 1'b0;
            #(CLINK_PERIOD_OFF/3);
            // 3
            clink_X_clk <= 1'b0;
            #(CLINK_PERIOD_OFF/3);
            // 4
            clink_X_clk <= 1'b0;
            #(CLINK_PERIOD_OFF/3);
            // 5
            clink_X_clk <= 1'b1;
            #(CLINK_PERIOD_ON/4);
            // 6
            clink_X_clk <= 1'b1;
            #(CLINK_PERIOD_ON/4);
        end
    end
end

int k = 0;

initial begin
    axi_if_inst.init();
    axi_read_addr <= DRAM_ADDR_BASE;
    
    #1000;
    axi_if_inst.init();
    
    wait(GPIO_LED_0_LS);
    clink_data_gen_en <= 1'b1;
    $display("7:1 deserializer stabilized");

    #1000;
    axi_if_inst.write(MASTER_CONTROLLER_AXI_ADDR, 4'b1000 | 128'h0);
    $display("Master Controller Auto Start");
    
    #20000;
    clink_data_gen_en <= 1'b0;
    $display("Image generation disabled");
    #100;
    axi_if_inst.read(CLINK_INTF_READ_IMG_NUM_ADRR,axi_read_data);
    $display("IMAGE NUMBER : %d", axi_read_data);
    $display("====================< DATA WRITTEN >====================");
    for ( k = 0 ; k < 9'h60; k ++ ) begin
        axi_if_inst.read(axi_read_addr,axi_read_data);
        $display("ADDR : %x , DATA : %x", axi_read_addr, axi_read_data);
        axi_read_addr = axi_read_addr + 16;
        #8;
    end
    
    #100;
    $display("Simulation END");



    $finish;
end

endmodule
