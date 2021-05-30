/**
 * Remainder 5 Detector (rem5)
 * For an arbitrary bit sequence clocked in MSb first,
 * detect whether or not a sequence is divisible by 5
 */
module rem5
(
    input wire clk,         // posedge clock
    input wire reset,       // synchronous reset
    input wire valid,       // valid, high when sequence is active
    input wire sequence,    // serial bit sequence, MSb
    output reg div_flag     // divisble flag, active when sequence completes
);
    localparam STATE_REM0 = 0;
    localparam STATE_REM1 = 1;
    localparam STATE_REM2 = 2;
    localparam STATE_REM3 = 3;
    localparam STATE_REM4 = 4;
    localparam STATE_TOTAL = 5;
    localparam SM_SIZE = $clog2(STATE_TOTAL);

    reg [SM_SIZE-1:0] currState;
    reg valid_fedge;

    // Basic approach -- track remainding as processing the incoming stream
    // Each bit needs to be looked at for how it changes the current remainder
    // No need to track actual remainder, but use state to do it.
    // Equation: (current remainder << 1) + (new bit 0/1) = new remainder
    // ex. if current remainder is 2, a new bit is 1:
    //      b01 << 1 + 1 = b10 + 1 = b11 = 3
    // Rem      "0"     "1"     Description
    // 0        0       1       0*2 + 0 = 0 % 5 = rem 0, 0*2+1 = 1 % 5 = rem 1
    // 1        2       3       1*2 + 0 = 2 % 5 = rem 2, 1*2+1 = 3 % 5 = rem 3
    // 2        4       0       2*2 + 0 = 4 % 5 = rem 4, 2*2+1 = 5 % 5 = rem 0
    // 3        1       2       3*2 + 0 = 6 % 5 = rem 1, 3*2+1 = 7 % 5 = rem 2
    // 4        3       4       4*2 + 0 = 8 % 5 = rem 3, 4*2+1 = 9 % 5 = rem 4
    always@(posedge clk) begin : state_machine
        if (reset) begin
            currState = STATE_REM0;
            valid_fedge <= 1'b0;
            div_flag <= 1'b0;
        end else begin
            if (valid) begin
                valid_fedge <= 1'b0;
                div_flag <= 1'b0;
                case (currState)
                    STATE_REM0 :
                        // Remainder 0
                        currState <= (sequence == 1'b0) ? STATE_REM0: STATE_REM1;
                    STATE_REM1 :
                        // Remainder 1
                        currState <= (sequence == 1'b0) ? STATE_REM2: STATE_REM3;
                    STATE_REM2 :
                        // Remainder 2
                        currState <= (sequence == 1'b0) ? STATE_REM4: STATE_REM0;
                    STATE_REM3 :
                        // Remainder 3
                        currState <= (sequence == 1'b0) ? STATE_REM1: STATE_REM2;
                    STATE_REM4 :
                        // Remainder 4
                        currState <= (sequence == 1'b0) ? STATE_REM3: STATE_REM4;
                    default:
                        // Remainder 0
                        currState <= STATE_REM0;
                endcase
            end else begin
                valid_fedge <= 1'b1;
                if (valid_fedge == 1'b0) begin
                    // just detected falling edge, clock output
                    div_flag <= (currState == STATE_REM0) ? 1'b1 : 1'b0;
                end
                // reset SM
                currState <= STATE_REM0;
            end
        end
    end

endmodule
