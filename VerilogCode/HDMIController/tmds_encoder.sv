`timescale 1ns / 1ps

module tmds_encoder_dvi(
    input  wire clk_pixel,
    input  wire reset,
    input  wire [7:0] data_8bit,
    input  wire [1:0] ctl,
    input  wire de,
    output reg  [9:0] tmds
);

reg signed [4:0] bias;

wire [3:0] d_ones;
wire use_xnor;
wire [8:0] enc_qm;
wire signed [4:0] zeros;
wire signed [4:0] balance;
wire signed [4:0] ones;

assign enc_qm[0] = data_8bit[0];
assign enc_qm[1] = (use_xnor) ? (enc_qm[0] ~^ data_8bit[1]) : (enc_qm[0] ^ data_8bit[1]);
assign enc_qm[2] = (use_xnor) ? (enc_qm[1] ~^ data_8bit[2]) : (enc_qm[1] ^ data_8bit[2]);
assign enc_qm[3] = (use_xnor) ? (enc_qm[2] ~^ data_8bit[3]) : (enc_qm[2] ^ data_8bit[3]);
assign enc_qm[4] = (use_xnor) ? (enc_qm[3] ~^ data_8bit[4]) : (enc_qm[3] ^ data_8bit[4]);
assign enc_qm[5] = (use_xnor) ? (enc_qm[4] ~^ data_8bit[5]) : (enc_qm[4] ^ data_8bit[5]);
assign enc_qm[6] = (use_xnor) ? (enc_qm[5] ~^ data_8bit[6]) : (enc_qm[5] ^ data_8bit[6]);
assign enc_qm[7] = (use_xnor) ? (enc_qm[6] ~^ data_8bit[7]) : (enc_qm[6] ^ data_8bit[7]);
assign enc_qm[8] = (use_xnor) ? 0 : 1;
assign ones = ({4'b0,enc_qm[0]} + {4'b0,enc_qm[1]}
                    + {4'b0,enc_qm[2]} + {4'b0,enc_qm[3]} + {4'b0,enc_qm[4]}
                    + {4'b0,enc_qm[5]} + {4'b0,enc_qm[6]} + {4'b0,enc_qm[7]});
assign balance = ones - zeros;
assign zeros = 5'b01000 - ones;
assign use_xnor = (d_ones > 4'd4) || ((d_ones == 4'd4) && (data_8bit[0] == 0));
assign d_ones = ({3'b0,data_8bit[0]} + {3'b0,data_8bit[1]} + {3'b0,data_8bit[2]}
                    + {3'b0,data_8bit[3]} + {3'b0,data_8bit[4]} + {3'b0,data_8bit[5]}
                    + {3'b0,data_8bit[6]} + {3'b0,data_8bit[7]});



always_ff @(posedge clk_pixel) begin
    if (reset) begin
        tmds <= 10'b1101010100;  // equivalent to ctrl 2'b00
        bias <= 5'sb00000;
    end
    else if (de == 0) begin
        case (ctl)
            2'b00:   tmds <= 10'b1101010100;
            2'b01:   tmds <= 10'b0010101011;
            2'b10:   tmds <= 10'b0101010100;
            default: tmds <= 10'b1010101011;
        endcase
        bias <= 5'sb00000;
    end
    else begin
        if (bias == 0 || balance == 0) begin
            if (enc_qm[8] == 0) begin
                tmds[9:0] <= {2'b10, ~enc_qm[7:0]};
                bias <= bias - balance;
            end
            else begin
                tmds[9:0] <= {2'b01, enc_qm[7:0]};
                bias <= bias + balance;
            end
        end
        else if ((bias > 0 && balance > 0) || (bias < 0 && balance < 0)) begin
            tmds[9:0] <= {1'b1, enc_qm[8], ~enc_qm[7:0]};
            bias <= bias + {3'b0, enc_qm[8], 1'b0} - balance;
        end
        else begin
            tmds[9:0] <= {1'b0, enc_qm[8], enc_qm[7:0]};
            bias <= bias - {3'b0, ~enc_qm[8], 1'b0} + balance;
        end
    end
end
endmodule