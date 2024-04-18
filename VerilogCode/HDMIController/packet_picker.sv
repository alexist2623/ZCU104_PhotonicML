// Implementation of HDMI packet choice logic.
// By Sameer Puri https://github.com/sameer

module packet_picker
#(
    parameter int VIDEO_ID_CODE = 4,
    parameter real VIDEO_RATE = 0,
    parameter bit IT_CONTENT = 1'b0,
    parameter bit [8*8-1:0] VENDOR_NAME = 0,
    parameter bit [8*16-1:0] PRODUCT_DESCRIPTION = 0,
    parameter bit [7:0] SOURCE_DEVICE_INFORMATION = 0
)
(
    input wire clk_pixel,
    input wire reset,
    input wire video_field_end,
    input wire packet_enable,
    input wire [4:0] packet_pixel_counter,
    output wire [23:0] header,
    output wire [55:0] sub [3:0]
);

// Connect the current packet type's data to the output.
reg [7:0] packet_type = 8'd0;
reg [23:0] headers [255:0];
reg [55:0] subs [255:0] [3:0];
assign header = headers[packet_type];
assign sub[0] = subs[packet_type][0];
assign sub[1] = subs[packet_type][1];
assign sub[2] = subs[packet_type][2];
assign sub[3] = subs[packet_type][3];

// NULL packet
assign headers[0] = {8'd0, 8'd0, 8'd0}; assign subs[0] = '{56'd0, 56'd0, 56'd0, 56'd0};

auxiliary_video_information_info_frame #(
    .VIDEO_ID_CODE                  (7'(VIDEO_ID_CODE)),
    .IT_CONTENT                     (IT_CONTENT)
) auxiliary_video_information_info_frame(
    .header                         (headers[130]), 
    .sub                            (subs[130])
);


source_product_description_info_frame #(
    .VENDOR_NAME                    (VENDOR_NAME), 
    .PRODUCT_DESCRIPTION            (PRODUCT_DESCRIPTION), 
    .SOURCE_DEVICE_INFORMATION      (SOURCE_DEVICE_INFORMATION)
) source_product_description_info_frame(
    .header                         (headers[131]), 
    .sub                            (subs[131])
);

// "A Source shall always transmit... [an InfoFrame] at least once per two Video Fields"
reg auxiliary_video_information_info_frame_sent = 1'b0;
reg source_product_description_info_frame_sent = 1'b0;

always @(posedge clk_pixel) begin
    if (reset || video_field_end) begin
        auxiliary_video_information_info_frame_sent <= 1'b0;
        source_product_description_info_frame_sent <= 1'b0;
        packet_type <= 8'd0;
    end
    else if (packet_enable) begin
        if (!auxiliary_video_information_info_frame_sent) begin
            packet_type <= 8'h82;
            auxiliary_video_information_info_frame_sent <= 1'b1;
        end
        else if (!source_product_description_info_frame_sent) begin
            packet_type <= 8'h83;
            source_product_description_info_frame_sent <= 1'b1;
        end
        else begin
            packet_type <= 8'd0;
        end
    end
end

endmodule
