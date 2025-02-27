/**
 * Non-return to Zero Serial Stream
 */
 //! Non-return to zero serial data stream
module nrz
#(
    parameter DATA_WIDTH = 8,
    parameter TICK_CNTR_WIDTH = 4,      // log2 of max(CLKS_ZERO_x_ONE_x) for counters
    parameter CLKS_ZERO_H_ONE_L = 8,    // number of clock enables for high bit for ZERO or low but for ONE
    parameter CLKS_ZERO_L_ONE_H = 4     // number of clock enables for high bit for ZERO or low but for ONE
)(
    input logic clk,                    // system clock
    input logic reset,                  // system reset
    input logic clken,                  // clock enable
    input logic valid,                  // valid
    input logic [DATA_WIDTH-1:0] din,   // datain

    output logic done,                  // done
    output logic dout                   // serial output data
);

// #########
// OPTION #1
// #########
`ifdef OPTION1
    //localparam  as = $clog2(FIFO_DEPTH-1);
    localparam STATE_IDLE = 0;
    localparam STATE_H = 1;
    localparam STATE_L = 2;

    typedef logic[$clog2(DATA_WIDTH)-1:0] din_cntr_t;
    const din_cntr_t DIN_CNTR_TC = din_cntr_t'(DATA_WIDTH-1);

    logic [1:0] state;
    logic [DATA_WIDTH-1:0] din_q;
    logic [$clog2(DATA_WIDTH)-1:0] din_cntr;
    logic [TICK_CNTR_WIDTH-1:0] tickcntr, tickcntr_tc;

    always_ff @(posedge clk) begin : some_process
        if (clken == 1'b1) begin
            done <= 1'b0;
            case (state)
            STATE_IDLE: begin
                if (valid) begin
                    state <= STATE_H;
                    din_q <= din;
                    din_cntr <= 0;
                    dout <= 1'b0;
                    tickcntr <= 0;
                    tickcntr_tc <= (din[DATA_WIDTH-1]) ? CLKS_ZERO_L_ONE_H : CLKS_ZERO_H_ONE_L;
                end
            end
            STATE_H: begin
                dout <= 1'b1;
                tickcntr <= tickcntr + 1'b1;
                if (tickcntr == tickcntr_tc) begin
                    din_cntr <= din_cntr + 1;
                    tickcntr <= 0;
                    tickcntr_tc <= (din_q[DATA_WIDTH-1]) ? CLKS_ZERO_H_ONE_L : CLKS_ZERO_L_ONE_H ;
                    state <= STATE_L;
                    // rotate din_q
                    din_q <= (din_q << 1);
                end
            end
            STATE_L: begin
                dout <= 1'b0;
                tickcntr <= tickcntr + 1'b1;
                if (tickcntr == tickcntr_tc) begin
                    tickcntr <= 0;

                    if (din_cntr == DIN_CNTR_TC) begin
                        done <= 1'b1;
                        state <= STATE_IDLE;
                    end else begin
                        state <= STATE_H;
                    end
                end
            end
            default: begin
                state <= STATE_IDLE;
                dout <= 1'b0;
            end
            endcase
        end
    end

// #########
// OPTION #2
// #########
`else
    // Design assumptions:
    // 1. CLKEN strobed at minimum bit timing rate (i.e. 220-380ns)
    // 2. Three times CLKEN rate is within longer bit timing rate (i.e. 580-1600ns)
    // 3. DATA_WDITH is 24-bits and is latched at single time for 8-bit RGB data
    // 4. VALID and DONE are strobed for one CLKEN period
    logic [1:0] pwmCntr, cmpValue;
    typedef logic[$clog2(DATA_WIDTH)-1:0] dcntr_t;
    dcntr_t datacntr;
    logic [DATA_WIDTH-1:0] din_q;
    logic valid_q;
    logic enablePWM;
    logic enableDataCnt;

    always_ff @(posedge clk or posedge reset) begin: datainput_block
        if (reset) begin
            din_q <= 0;
            valid_q <= 0;
        end else if (clken) begin
            if (valid) begin
                // store new data
                din_q <= din;
            end else if (enableDataCnt) begin
                // shift on CLKEN
                din_q <= {din_q[DATA_WIDTH-2:0], 1'b0};
            end

            if (valid) begin
                valid_q <= 1'b1;
            end else if (done) begin
                valid_q <= 1'b0;
            end
        end
    end

    assign done = ((datacntr == dcntr_t'(DATA_WIDTH-1)) && pwmCntr == 0) ? 1'b1 : 1'b0;

    always_ff @(posedge clk or posedge reset) begin: datacounter_block
        if (reset) begin
            datacntr <= 0;
        end else if (clken) begin
            if (done) begin
                datacntr <= 0;
            end else if (enableDataCnt) begin
                datacntr <= datacntr + 1'b1;
            end
        end
    end

    assign enablePWM = valid_q;

     always_ff @(posedge clk or posedge reset) begin: pwmcntr_block
        if (reset) begin
            pwmCntr <= 0;
        end else if (clken) begin
            if (valid) begin
                pwmCntr <= 0;
                enableDataCnt <= 0;
            end else if (enablePWM) begin
                {enableDataCnt, pwmCntr} <= pwmCntr + 1'b1;
            end
        end
    end

    assign cmpValue = (din_q[DATA_WIDTH-1]) ? 2 : 0;
    assign dout = (pwmCntr > cmpValue) ? 1'b0 : valid_q && !done;

`endif
endmodule
