// Simple State Machine constructed 4 ways:
// 1. Separate CS, NS, and OL
// 2. Combined CS/NS, and Separate OL
// 3. Combined NS/OL, and Separate CS
// 4. Combined CS, NS, and OL
// From HDL Chip Design, Example 8.2

// #1
module sm_sep_cs_ns_ol(
    input wire clk,
    input wire reset,
    input wire control,
    output reg [1:0] y
);
    localparam  STATE_WIDTH = 2;
    localparam  ST0 = 2'b00;
    localparam  ST1 = 2'b01;
    localparam  ST2 = 2'b10;
    localparam  ST3 = 2'b11;

    reg [STATE_WIDTH-1:0] currState, nextState;

    //! Current state process
    always @(posedge clk) begin
        if(reset) begin
            currState <= ST0;
        end else begin
            currState <= nextState;
        end
    end

    //! Next state process
    always@(*) begin
        // default case
        nextState = ST0;
        case(currState)
            ST0: begin nextState = ST1; end
            ST1: begin
                if(control) begin
                    nextState = ST3;
                end else begin
                    nextState = ST2;
                end
            end
            ST2: begin nextState = ST3; end
            ST3: begin nextState = ST0; end
        endcase
    end

    //! Output logic process
    always@(*) begin
        y = 0;
        // set output and state at the same time for the next clock
        case(currState)
            ST0: begin y = 0; end
            ST1: begin y = 1; end
            ST2: begin y = 2; end
            ST3: begin y = 3; end
        endcase
    end
endmodule

// #2
module sm_comb_cs_ns_sep_ol(
    input wire clk,
    input wire reset,
    input wire control,
    output reg [1:0] y
);
    localparam  STATE_WIDTH = 2;
    localparam  ST0 = 2'b00;
    localparam  ST1 = 2'b01;
    localparam  ST2 = 2'b10;
    localparam  ST3 = 2'b11;

    reg [STATE_WIDTH-1:0] currState;

    //! Current state process
    //! Next state process
    always @(posedge clk) begin
        if(reset) begin
            currState <= ST0;
        end else begin
            case(currState)
                ST0: begin currState <= ST1; end
                ST1: begin
                    if(control) begin
                        currState <= ST3;
                    end else begin
                        currState <= ST2;
                    end
                end
                ST2: begin currState <= ST3; end
                ST3: begin currState <= ST0; end
                // missing default -> error handler case
            endcase
        end
    end

    //! Output logic process
    always@(*) begin
        y = 0;
        case(currState)
            ST0: begin y = 0; end
            ST1: begin y = 1; end
            ST2: begin y = 2; end
            ST3: begin y = 3; end
            // missing default -> error handler case
        endcase
    end

endmodule

// #3
module sm_comb_ns_ol_sep_cs(
    input wire clk,
    input wire reset,
    input wire control,
    output reg [1:0] y
);
    localparam  STATE_WIDTH = 2;
    localparam  ST0 = 2'b00;
    localparam  ST1 = 2'b01;
    localparam  ST2 = 2'b10;
    localparam  ST3 = 2'b11;

    reg [STATE_WIDTH-1:0] currState, nextState;

    //! Current state process
    always @(posedge clk) begin
        if(reset) begin
            currState <= ST0;
        end else begin
            currState <= nextState;
        end
    end

    //! Next state process
    //! Output logic process
    always@(*) begin
        // defaults
        nextState = ST0;
        y = 0;
        case(currState)
            // since comb, OL is based on current state
            ST0: begin nextState = ST1; y = 0; end
            ST1: begin
                if(control) begin
                    nextState = ST3;
                end else begin
                    nextState = ST2;
                end
                y = 1;
            end
            ST2: begin nextState = ST3; y = 2; end
            ST3: begin nextState = ST0; y = 3; end
            // missing default -> error handler case
        endcase
    end

endmodule

// #4
module sm_comb_cs_ns_ol(
    input wire clk,
    input wire reset,
    input wire control,
    output reg [1:0] y
);
    localparam  STATE_WIDTH = 2;
    localparam  ST0 = 2'b00;
    localparam  ST1 = 2'b01;
    localparam  ST2 = 2'b10;
    localparam  ST3 = 2'b11;

    reg [STATE_WIDTH-1:0] currState;

    //! Current state process
    //! Next state process
    //! Output logic process
    always @(posedge clk) begin
        if(reset) begin
            currState <= ST0;
            y <= 0;
        end else begin
            // since clocked, OL is based on next state
            case(currState)
                ST0: begin currState <= ST1; y <= 1; end
                ST1: begin
                    if(control) begin
                        currState <= ST3;
                        y <= 3;
                    end else begin
                        currState <= ST2;
                        y <= 2;
                    end
                end
                ST2: begin currState <= ST3; y <= 3; end
                ST3: begin currState <= ST0; y <= 0; end
                // missing default -> error handler case
            endcase
        end
    end

endmodule
