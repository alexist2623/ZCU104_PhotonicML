module SignalShifter
#(
    parameter MAX_DELAY                     = 10000000,
    parameter MAX_EVENT                     = 10,
    parameter DELAY_WIDTH                   = $clog2(MAX_DELAY),
    parameter EVENT_WIDTH                   = $clog2(MAX_EVENT)
)
(
    input  wire auto_start,
    input  wire clk,
    input  wire reset,
    input  wire [DELAY_WIDTH-1:0] delay_value,
    input  wire delay_set,
    input  wire [EVENT_WIDTH-1:0] event_value,
    input  wire event_set,
    input  wire event_polarity_set,
    input  wire input_signal,
    output reg  output_signal
);

localparam STATE_NUM                        = 4;
localparam STATE_WIDTH                      = $clog2(STATE_NUM);
typedef enum logic [STATE_WIDTH:0] {IDLE, DELAY_COUNT} statetype;
statetype signal_shifter_state;

reg  input_signal_buffer1;
reg  input_signal_buffer2;
reg  input_signal_buffer3;
reg  [DELAY_WIDTH-1:0] delay_counter;
reg  [DELAY_WIDTH-1:0] delay_counter_reg;
reg  [EVENT_WIDTH-1:0] event_counter;
reg  [EVENT_WIDTH-1:0] event_counter_reg;
reg  event_polarity;

always_ff @(posedge clk) begin
    if( reset == 1'b1 )begin
        input_signal_buffer1 <= 1'b0;
        input_signal_buffer2 <= 1'b0;
        delay_counter <= DELAY_WIDTH'(0);
        delay_counter_reg <= DELAY_WIDTH'(0);
        event_counter <= EVENT_WIDTH'(0);
        event_counter_reg <= EVENT_WIDTH'(0);
        output_signal <= 1'b0;
        event_polarity <= 1'b0;
        signal_shifter_state <= IDLE;
    end
    else begin
        output_signal <= 1'b0;
        /*
         * buffer3 is for edge sense
         * buffer1, 2 is to synchronization to clk region
         */
        {input_signal_buffer3, input_signal_buffer2, input_signal_buffer1} <= {input_signal_buffer2, input_signal_buffer1, input_signal};
        if( delay_set == 1'b1 ) begin
            delay_counter_reg <= delay_value;
        end
        
        if( event_set == 1'b1 ) begin
            event_counter_reg <= event_value;
        end
        
        if( auto_start ) begin
            case(signal_shifter_state)
                IDLE: begin
                    /*
                     * event_polarity = 1 : Sense HIGH -> LOW
                     * event_polarity = 0 : Sense LOW  -> HIGH
                     */
                    if( (event_polarity ^ input_signal_buffer2 == 0) && (event_polarity ^ input_signal_buffer3 == 1) ) begin
                        event_counter <= event_counter + 1;
                        $display("EDGE DETECTED");
                    end
                    
                    if( event_counter >= event_counter_reg ) begin
                        delay_counter <= 1;
                        event_counter <= 0;
                        signal_shifter_state <= DELAY_COUNT;
                        $display("SIGNAL SHIFTER ENTERS TO DELAY COUNT");
                    end
                end
                DELAY_COUNT: begin
                    delay_counter <= delay_counter + 1;
                    if( delay_counter >= delay_counter_reg ) begin
                        delay_counter <= 0;
                        event_counter <= 0;
                        output_signal <= 1'b1;
                        signal_shifter_state <= IDLE;
                        $display("SIGNAL SHIFTER OUTPUT SIGNAL");
                    end
                end
            endcase
        end
    end
end

endmodule