module moore
(
    // Input and output ports
    input logic clk, reset, flag,
    output logic [2:0] out
);

    // State declarations
    localparam STATE0 = 0;
    localparam STATE1 = 1;
    localparam STATE2 = 2;
    localparam STATE3 = 3;
    //enum logic[1:0] {STATE0, STATE1, STATE2, STATE3};
    // typedef enum logic[1:0] {STATE0, STATE1, STATE2, STATE3} state_t;

    // State register and state-dependent output
    logic [1:0] nstate, cstate;
    logic [2:0] out_next;

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cstate <= STATE0;
            out <= 1;
        end else begin
            cstate <= nstate;
            out <= out_next;
        end
    end

    // Output logic

    // State transition logic
    always_comb begin
        nstate = cstate;
        out_next = 1;
        case (cstate)
            STATE0: begin
                nstate = STATE1;
                out_next = 2;
            end
            STATE1: if (flag) begin nstate = STATE3; out_next = 4; end
                    else begin nstate = STATE2; out_next = 3; end
            STATE2: begin
                nstate = STATE3;
                out_next = 4;
            end
            STATE3: begin
                nstate = STATE0;
                out_next = 1;
            end
        endcase
    end

endmodule