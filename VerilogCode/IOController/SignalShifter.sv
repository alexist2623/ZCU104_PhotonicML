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
    input  wire input_event_polarity_value,
    input  wire input_event_polarity_set,
    input  wire output_event_polarity_value,
    input  wire output_event_polarity_set,
    input  wire [63:0] timer_value,
    input  wire timer_set,
    input  wire input_signal,
    output wire output_signal
);

localparam STATE_NUM                        = 4;
localparam STATE_WIDTH                      = $clog2(STATE_NUM);
typedef enum logic [STATE_WIDTH:0] {IDLE, DELAY_COUNT, OUTPUT} statetype;
statetype signal_shifter_state;

reg  input_signal_buffer1;
reg  input_signal_buffer2;
reg  input_signal_buffer3;
reg  [DELAY_WIDTH-1:0] delay_counter;
reg  [DELAY_WIDTH-1:0] delay_counter_reg;
reg  [EVENT_WIDTH-1:0] event_counter;
reg  [EVENT_WIDTH-1:0] event_counter_reg;
reg  input_event_polarity;
reg  output_event_polarity;
reg  [63:0] timer_threshold;
reg  [63:0] timer;
reg  output_signal_reg;

assign output_signal = output_signal_reg ^ output_event_polarity;

always_ff @(posedge clk) begin
    if( reset == 1'b1 )begin
        input_signal_buffer1 <= 1'b0;
        input_signal_buffer2 <= 1'b0;
        delay_counter <= DELAY_WIDTH'(0);
        delay_counter_reg <= DELAY_WIDTH'(0);
        event_counter <= EVENT_WIDTH'(0);
        event_counter_reg <= EVENT_WIDTH'(0);
        output_signal_reg <= 1'b0;
        input_event_polarity <= 1'b0;
        output_event_polarity <= 1'b0;
        signal_shifter_state <= IDLE;
        timer <= 64'h0;
        timer_threshold <= 64'h0;
    end
    else begin
        output_signal_reg <= 1'b0;
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
        
        if( input_event_polarity_set == 1'b1 ) begin
            input_event_polarity <= input_event_polarity_value;
        end
        
        if( output_event_polarity_set == 1'b1 ) begin
            output_event_polarity <= output_event_polarity_value;
        end
        
        if( timer_set == 1'b1 ) begin
            timer_threshold <= timer_value;
        end
        
        if( auto_start ) begin
            case(signal_shifter_state)
                IDLE: begin
                    /*
                     * input_event_polarity = 1 : Sense HIGH -> LOW
                     * input_event_polarity = 0 : Sense LOW  -> HIGH
                     */
                    if( (input_event_polarity ^ input_signal_buffer2 == 0) && (input_event_polarity ^ input_signal_buffer3 == 1) ) begin
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
                        output_signal_reg <= 1'b1;
                        signal_shifter_state <= OUTPUT;
                        $display("SIGNAL SHIFTER OUTPUT SIGNAL");
                    end
                end
                OUTPUT: begin
                    output_signal_reg <= 1'b1;
                    timer <= timer + 1;
                    if( timer > timer_threshold ) begin
                        timer <= 64'h0;
                        signal_shifter_state <= IDLE;
                    end
                end
            endcase
        end
    end
end

endmodule