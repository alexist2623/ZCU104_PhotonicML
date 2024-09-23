`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//                                                            
//                  ###############                           
//                ###################                         
//              ######     #############                      
//             #####     #################                    
//             ####    ######        #######                  
//             ####  ######          #########                
//             #### #####   #####    #### #####               
//             #### #####    ###### ##### #####               
//             ##########      #########  #####               
//                #######       #######   #####               
//                  ###########################               
//                    ############    #######                 
//                      ######################                
//                        ############### #####               
//                                                            
//                                                            
//          ###           ###    ####      #####  #           
//        #     #          #   #      #  #        #           
//       #       #  #   #  #  #        # #        #           
//        #    ##   #   #  #   #      #  #        #           
//          ###  ##  ###  ###    ####  ##  #####  ####        
//
// Company: SNU QuIQCL
// Engineer: Jeonghyun Park, alexist@snu.ac.kr
// 
// Create Date: 2024/06/21 12:31:49
// Design Name: 
// Module Name: TTLx8_tb
// Project Name: RFSoC 
// Target Devices: RFSoC
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

module ZCU104Camera_tb;

localparam  AXI_CLINK_INTF_ADDR             = 39'hA000_0000;
localparam  UART_WRITE                      = 6'h00;
/* axi response */
reg [1:0] response;

reg         CLK_300_N;
reg         CLK_300_P;
reg         FMC_LPC_LA01_CC_N;
reg         FMC_LPC_LA01_CC_P;
reg         FMC_LPC_LA03_N;
reg         FMC_LPC_LA03_P;
reg         FMC_LPC_LA04_N;
reg         FMC_LPC_LA04_P;
reg         FMC_LPC_LA05_N;
reg         FMC_LPC_LA05_P;
reg         FMC_LPC_LA06_N;
reg         FMC_LPC_LA06_P;
wire [0:0]  FMC_LPC_LA07_N;
wire [0:0]  FMC_LPC_LA07_P;
wire [0:0]  FMC_LPC_LA08_N;
wire [0:0]  FMC_LPC_LA08_P;
wire [0:0]  FMC_LPC_LA09_N;
wire [0:0]  FMC_LPC_LA09_P;
reg         FMC_LPC_LA14_N;
reg         FMC_LPC_LA14_P;
wire [0:0]  FMC_LPC_LA15_N;
wire [0:0]  FMC_LPC_LA15_P;
wire [0:0]  FMC_LPC_LA17_CC_N;
wire [0:0]  FMC_LPC_LA17_CC_P;

//============================================================
// Clock Generation
//============================================================
initial begin
    CLK_300_P <= 1'b0;
    CLK_300_N <= 1'b1;
    forever begin
        #1.667;
        CLK_300_P <= ~CLK_300_P;
        CLK_300_N <= ~CLK_300_N;
    end
end

ZCU104Camera_UUT uut(
    .CLK_300_N           (CLK_300_N),
    .CLK_300_P           (CLK_300_P),
    .FMC_LPC_LA01_CC_N   (FMC_LPC_LA01_CC_N),
    .FMC_LPC_LA01_CC_P   (FMC_LPC_LA01_CC_P),
    .FMC_LPC_LA03_N      (FMC_LPC_LA03_N),
    .FMC_LPC_LA03_P      (FMC_LPC_LA03_P),
    .FMC_LPC_LA04_N      (FMC_LPC_LA04_N),
    .FMC_LPC_LA04_P      (FMC_LPC_LA04_P),
    .FMC_LPC_LA05_N      (FMC_LPC_LA05_N),
    .FMC_LPC_LA05_P      (FMC_LPC_LA05_P),
    .FMC_LPC_LA06_N      (FMC_LPC_LA06_N),
    .FMC_LPC_LA06_P      (FMC_LPC_LA06_P),
    .FMC_LPC_LA07_N      (FMC_LPC_LA07_N),
    .FMC_LPC_LA07_P      (FMC_LPC_LA07_P),
    .FMC_LPC_LA08_N      (FMC_LPC_LA08_N),
    .FMC_LPC_LA08_P      (FMC_LPC_LA08_P),
    .FMC_LPC_LA09_N      (FMC_LPC_LA09_N),
    .FMC_LPC_LA09_P      (FMC_LPC_LA09_P),
    .FMC_LPC_LA14_N      (FMC_LPC_LA14_N),
    .FMC_LPC_LA14_P      (FMC_LPC_LA14_P),
    .FMC_LPC_LA15_N      (FMC_LPC_LA15_N),
    .FMC_LPC_LA15_P      (FMC_LPC_LA15_P),
    .FMC_LPC_LA17_CC_N   (FMC_LPC_LA17_CC_N),
    .FMC_LPC_LA17_CC_P   (FMC_LPC_LA17_CC_P)
);

task automatic cpu_init;
    uut.zcu104_inst.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    #200;
    uut.zcu104_inst.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
    uut.zcu104_inst.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.fpga_soft_reset(4'hf);
    #400;
    //minimum 16 clock pulse width delay
    uut.zcu104_inst.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    uut.zcu104_inst.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.fpga_soft_reset(4'h0);
endtask : cpu_init

task automatic cpu_write(
    input logic [38:0] addr,
    input logic [127:0] data
);
    uut.zcu104_inst.ZCU104_Main_blk_i.zynq_ultra_ps_e_0.inst.write_data(addr, 8'h10, data, response);
endtask : cpu_write

initial begin
    cpu_init();
    #1000;
    $display("UART WRITE TEST");
    cpu_write(AXI_CLINK_INTF_ADDR|UART_WRITE, 128'h48);
    #(1000000000 / 9600 * 10 + 1000);
    $display("UART WRITE TEST DONE");
    $finish;
end

endmodule
