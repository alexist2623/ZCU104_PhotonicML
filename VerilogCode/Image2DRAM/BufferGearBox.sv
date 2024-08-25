module BufferGearBox
#(
    parameter DRAM_ADDR_WIDTH       = 32,
    parameter DRAM_ADDR_BASE        = 32'h80000000, // should be fixed
    parameter DRAM_DATA_WIDTH       = 512
)
(
    input  wire reset,
    input  wire clink_X_clk,
    input  wire [7:0]  d0,
    input  wire [7:0]  d1,
    input  wire [7:0]  d2,
    input  wire fval,
    input  wire dval,
    input  wire lval,

    output wire [DRAM_DATA_WIDTH - 1:0] async_fifo_out,
    output wire async_fifo_empty,

    output reg  dram_write_en,
    output reg  [DRAM_ADDR_WIDTH - 1:0] dram_write_addr,
    input  wire dram_write_busy,
    input  wire dram_ctrl_clk
);

localparam BUFFER_SIZE           = DRAM_DATA_WIDTH * 3;
localparam BUFFER_SIZE_WIDTH     = $clog2(BUFFER_SIZE);
localparam INPUT_DATA_SIZE       = 24; // 8-bit * 3
localparam INPUT_NUM             = BUFFER_SIZE / INPUT_DATA_SIZE;
localparam INPUT_NUM_WIDTH       = $clog2(INPUT_NUM);

reg  [DRAM_ADDR_WIDTH - 1:0] dram_next_addr;
reg  [BUFFER_SIZE - 1:0] async_fifo_buffer;
reg  [DRAM_DATA_WIDTH - 1:0] async_fifo_chunk_input[3];
reg  [DRAM_DATA_WIDTH - 1:0] async_fifo_input;
reg  [INPUT_NUM_WIDTH - 1:0] async_fifo_buffer_index;
reg  async_fifo_write_fsm;
reg  async_fifo_write;
reg  fval_buffer;
reg  dval_buffer;
reg  lval_buffer; // to save last data

wire async_fifo_buffer_write;

// Async FIFO inteface
assign async_fifo_buffer_write = fval & dval & lval;

async_fifo_generator async_fifo_inst (
    .srst       (reset),
    .wr_clk     (clink_X_clk),
    .rd_clk     (dram_ctrl_clk), 
    .din        (async_fifo_input),
    .wr_en      (async_fifo_write),
    .re_en      (dram_write_en),
    .empty      (async_fifo_empty),
    .full       (),
    .dout       (async_fifo_out)
);

// DRAM interface
always_ff @(posedge clink_X_clk) begin
    if( reset ) begin
        dram_write_addr     <= DRAM_ADDR_BASE;
        dram_next_addr      <= DRAM_ADDR_BASE;
        dram_write_en       <= 1'b0;
    end
    else begin
        dram_write_en <= 1'b0;
        if( async_fifo_empty == 1'b0 && dram_write_busy == 1'b0 ) begin
            dram_write_en <= 1'b1;
            dram_next_addr <= dram_write_addr + BUFFER_SIZE;
        end
        else begin
            dram_write_addr <= dram_next_addr;
        end
    end
end

// async fifo interface
always_ff @(posedge clink_X_clk) begin
    if( reset ) begin
        async_fifo_buffer       <= 0;
        async_fifo_buffer_index <= 0;
        async_fifo_write_fsm    <= 1'b0;
        {fval_buffer, dval_buffer, lval_buffer} <= 3'h0;
    end
    else begin
        async_fifo_write_fsm <= 1'b0;
        {fval_buffer, dval_buffer, lval_buffer} <= {fval, dval, lval};
        if( async_fifo_buffer_write == 1'b1 ) begin
            /*
             * Write to buffer and fill zero when first data is received
             */
            if (async_fifo_buffer_index == 0) begin
                async_fifo_buffer <= {(BUFFER_SIZE - INPUT_DATA_SIZE)'(0), d2,d1,d0};
            end
            else begin
                async_fifo_buffer[async_fifo_buffer_index * INPUT_DATA_SIZE +: INPUT_DATA_SIZE] <= {d2,d1,d0};
            end

            /*
             * Write to DRAM when buffer is full or when the last data is received or buffer is full
             */
            if( 
                async_fifo_buffer_index == INPUT_NUM - 1 || 
                (
                    {fval_buffer, dval_buffer, lval_buffer} == 3'b111 && 
                    {fval, dval, lval}                      == 3'b000
                )
            ) begin
                async_fifo_write_fsm <= 1'b1;
                async_fifo_buffer_index <= BUFFER_SIZE_WIDTH'(0);
            end
            else begin
                async_fifo_buffer_index <= async_fifo_buffer_index + 1;
            end
        end
    end
end
typedef enum logic [6:0] {
    IDLE, 
    STAGE1,
    STAGE2, 
    STAGE3} statetype_w;
statetype_w async_fifo_write_state;

// buffer control logic
always_ff @(posedge clink_X_clk) begin
    if( reset ) begin
        async_fifo_write <= 1'b0;
        async_fifo_chunk_input[0] <= DRAM_DATA_WIDTH'(0);
        async_fifo_chunk_input[1] <= DRAM_DATA_WIDTH'(0);
        async_fifo_chunk_input[2] <= DRAM_DATA_WIDTH'(0);
        async_fifo_input <= DRAM_DATA_WIDTH'(0);
        async_fifo_write_state <= IDLE;
    end
    else begin
        async_fifo_write <= 1'b0;
        case(async_fifo_write_state)
            IDLE: begin
                if( async_fifo_write_fsm == 1'b1 ) begin
                    async_fifo_chunk_input[0] <= async_fifo_buffer[0 +:DRAM_DATA_WIDTH];
                    async_fifo_chunk_input[1] <= async_fifo_buffer[DRAM_DATA_WIDTH +:DRAM_DATA_WIDTH];
                    async_fifo_chunk_input[2] <= async_fifo_buffer[DRAM_DATA_WIDTH*2 +:DRAM_DATA_WIDTH];
                    async_fifo_write_state <= STAGE1;
                end
            end
            STAGE1 : begin
                async_fifo_input <= async_fifo_chunk_input[0];
                async_fifo_write_state <= STAGE2;
                async_fifo_write <= 1'b1;
            end
            STAGE2 : begin
                async_fifo_input <= async_fifo_chunk_input[1];
                async_fifo_write_state <= STAGE3;
                async_fifo_write <= 1'b1;
            end
            STAGE3 : begin
                async_fifo_input <= async_fifo_chunk_input[2];
                async_fifo_write_state <= IDLE;
                async_fifo_write <= 1'b1;
            end
        endcase
    end
end

endmodule