module uart 
#(
    parameter CLK_FREQ          = 125000000,
    parameter BAUD_RATE         = 19200
)    
(
    input  wire       clk,           // System clock
    input  wire       rst_n,         // Active low reset
    input  wire       tx_start,      // Start transmission signal
    input  wire [7:0] tx_data,       // Data to be transmitted
    output reg        tx_busy,       // Transmission in progress
    output reg        tx_serial,     // UART transmit serial output
    input  wire       rx_serial,     // UART receive serial input
    output reg        rx_ready,      // Data received and ready
    output reg  [7:0] rx_data        // Data received
);

// Calculate number of clock cycles per bit
localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;
localparam integer HALF_BAUD_DIV = BAUD_DIV >> 1;

// Transmit logic
reg [3:0] tx_bit_cnt;
reg [12:0] tx_clk_div;
reg [9:0] tx_shift_reg;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        tx_busy <= 0;
        tx_serial <= 1'b1;
        tx_bit_cnt <= 0;
        tx_clk_div <= 0;
        tx_shift_reg <= 10'b1111111111;
    end 
    else begin
        if (tx_start && !tx_busy) begin
            tx_busy <= 1'b1;
            tx_shift_reg <= {1'b1, tx_data, 1'b0}; // Load shift register with start bit, data, stop bit
            tx_bit_cnt <= 0;
            tx_clk_div <= 0;
        end 
        else if (tx_busy) begin
            if (tx_clk_div < BAUD_DIV - 1) begin
                tx_clk_div <= tx_clk_div + 1;
            end else begin
                tx_clk_div <= 0;
                tx_serial <= tx_shift_reg[0];
                tx_shift_reg <= {1'b1, tx_shift_reg[9:1]}; // Shift the register right
                tx_bit_cnt <= tx_bit_cnt + 1;
                
                if (tx_bit_cnt == 9) begin
                    tx_busy <= 1'b0;
                end
            end
        end
    end
end

// Receive logic
reg [3:0]  rx_bit_cnt;
reg [12:0] rx_clk_div;
reg [9:0]  rx_shift_reg;
reg        rx_sample_flag;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        rx_ready <= 0;
        rx_data <= 0;
        rx_bit_cnt <= 0;
        rx_clk_div <= 0;
        rx_shift_reg <= 10'b0;
        rx_sample_flag <= 0;
    end 
    
    else begin
        if (!rx_sample_flag && !rx_serial) begin
            // Start bit detected
            rx_clk_div <= HALF_BAUD_DIV;
            rx_sample_flag <= 1'b1;
        end 
        else if (rx_sample_flag) begin
            if (rx_clk_div < BAUD_DIV - 1) begin
                rx_clk_div <= rx_clk_div + 1;
            end else begin
                rx_clk_div <= 0;
                rx_shift_reg <= {rx_serial, rx_shift_reg[9:1]}; // Shift in data bit
                rx_bit_cnt <= rx_bit_cnt + 1;
                
                if (rx_bit_cnt == 9) begin
                    rx_sample_flag <= 1'b0;
                    rx_bit_cnt <= 0;
                    rx_ready <= 1'b1;
                    rx_data <= rx_shift_reg[8:1]; // Capture received data
                end
            end
        end 
        else begin
            rx_ready <= 0;
        end
    end
end

endmodule
