// 3-Way Round Robin Arbiter
// From HDL Chip Design, Practical Modeling Example 3

module rr_arbiter(
    input wire clk,
    input wire reset,
    // Channel A
    input wire reqA,
    output reg ackA,
    input wire [ADDR_WIDTH-1:0] addressA,
    input wire [DATA_WIDTH-1:0] wrdataA,
    output reg [DATA_WIDTH-1:0] rddataA,
    input wire rdWrnA,
    // Channel B
    input wire reqB,
    output reg ackB,
    input wire [ADDR_WIDTH-1:0] addressB,
    input wire [DATA_WIDTH-1:0] wrdataB,
    output reg [DATA_WIDTH-1:0] rddataB,
    input wire rdWrnB,
    // Channel C
    input wire reqC,
    output reg ackC,
    input wire [ADDR_WIDTH-1:0] addressC,
    input wire [DATA_WIDTH-1:0] wrdataC,
    output reg [DATA_WIDTH-1:0] rddataC,
    input wire rdWrnC,
    // RAM port
    output wire [ADDR_WIDTH-1:0] address,
    output wire [DATA_WIDTH-1:0] wrdata,
    input wire [DATA_WIDTH-1:0] rddata,
    output wire rdWrn
);
    parameter ADDR_WIDTH = 12;
    parameter DATA_WIDTH = 8;
    parameter WD_TIMER_WIDTH = 6;

    localparam  STATE_WIDTH = 2;
    localparam  stIDLE      = 2'b00;
    localparam  stGRANTA    = 2'b01;
    localparam  stGRANTB    = 2'b10;
    localparam  stGRANTC    = 2'b11;

    reg [STATE_WIDTH-1:0] currState, nextState;

    // watchdog timer
    reg [WD_TIMER_WIDTH-1:0] wd_timer;
    reg wd_enable;
    reg wd_timeout;

    //! Current state process
    always @(posedge clk) begin
        if(reset) begin
            currState <= stIDLE;
        end else begin
            currState <= nextState;
        end
    end

    //! Next state process
    always@(*) begin
        ackA = 1'b0;
        ackB = 1'b0;
        ackC = 1'b0;
        wd_enable = 1'b0;
        case(currState)
            stIDLE: begin
                // can immediately ACK since was IDLE
                if (reqA == 1'b1) begin
                    nextState = stGRANTA;
                    ackA = 1'b1;
                end else if (reqB == 1'b1) begin
                    nextState = stGRANTB;
                    ackB = 1'b1;
                end else if (reqC == 1'b1) begin
                    nextState = stGRANTC;
                    ackC = 1'b1;
                end else begin
                    nextState = stIDLE;
                end
            end
            stGRANTA: begin
                if (reqA == 1'b1 && wd_timeout == 1'b0) begin
                    // normal operation
                    ackA = 1'b1;
                    wd_enable = 1'b1;
                    nextState = stGRANTA;
                end else if (reqB == 1'b1) begin
                    // timeout or reqA complete
                        nextState = stGRANTB;
                end else if (reqC == 1'b1) begin
                    nextState = stGRANTC;
                end else begin
                    // force return to IDLE (even if reqA only timed out)
                    // todo: change this state to reset the timer
                    nextState = stIDLE;
                end
            end
            stGRANTB: begin
                if (reqB == 1'b1 && wd_timeout == 1'b0) begin
                    // normal operation
                    ackB = 1'b1;
                    wd_enable = 1'b1;
                    nextState = stGRANTB;
                end else if (reqC == 1'b1) begin
                    // timeout or reqA complete
                        nextState = stGRANTC;
                end else if (reqA == 1'b1) begin
                    nextState = stGRANTA;
                end else begin
                    // force return to IDLE (even if reqA only timed out)
                    // todo: change this state to reset the timer
                    nextState = stIDLE;
                end
            end
            stGRANTC: begin
                if (reqC == 1'b1 && wd_timeout == 1'b0) begin
                    // normal operation
                    ackC = 1'b1;
                    wd_enable = 1'b1;
                    nextState = stGRANTC;
                end else if (reqA == 1'b1) begin
                    // timeout or reqA complete
                        nextState = stGRANTA;
                end else if (reqB == 1'b1) begin
                    nextState = stGRANTB;
                end else begin
                    // force return to IDLE (even if reqA only timed out)
                    // todo: change this state to reset the timer
                    nextState = stIDLE;
                end
            end
        endcase
    end

    assign address = (ackA) ? addressA : 12'bz;
    assign address = (ackB) ? addressB : 12'bz;
    assign address = (ackC) ? addressC : 12'bz;
    assign wrdata = (ackA) ? wrdataA : 8'bz;
    assign wrdata = (ackB) ? wrdataB : 8'bz;
    assign wrdata = (ackC) ? wrdataC : 8'bz;
    assign rdWrn = (ackA) ? rdWrnA : 1'bz;
    assign rdWrn = (ackB) ? rdWrnB : 1'bz;
    assign rdWrn = (ackC) ? rdWrnC : 1'bz;

    always @(*) begin
        rddataA = 8'bz;
        rddataB = 8'bz;
        rddataC = 8'bz;
        if (ackA) rddataA = rddata;
        if (ackB) rddataB = rddata;
        if (ackC) rddataC = rddata;
    end

    // watchdog timer
    always @(posedge clk) begin
        if(reset) begin
            wd_timer = 0;
        end else begin
            if (wd_enable == 1'b1) begin
                wd_timer = wd_timer  + 1'b1;
            end else begin
                wd_timer = 0;
            end
        end
    end

    // watchdog timeout flag
    always @(*) begin
        wd_timeout = 1'b0;
        if(&wd_timer) begin
            wd_timeout = 1'b1;
        end
    end

endmodule
