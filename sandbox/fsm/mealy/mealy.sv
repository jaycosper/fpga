// Mealy state machine
module mealy
(
    // Input and output ports
    input logic clk, reset, flag,
    output logic[2:0] out
);

    // State declarations
    localparam STATE0 = 0;
    localparam STATE1 = 1;
    localparam STATE2 = 2;
    localparam STATE3 = 3;
    //enum logic[1:0] {STATE0, STATE1, STATE2, STATE3};
    // typedef enum logic[1:0] {STATE0, STATE1, STATE2, STATE3} state_t;


    // State register and state-dependent output
    //state_t nstate, cstate;
    logic [1:0] nstate, cstate;

    // State transition and output logic
    always_comb begin
        case (cstate)
        STATE0: begin
            nstate = STATE1;
            out = 3'b001;
        end
        STATE1: begin
            if (flag) begin
                nstate = STATE3;
            end else begin
                nstate = STATE2;
            end
            out = 3'b010;
        end
        STATE2: begin
            nstate = STATE3;
            out = 3'b011;
        end
        STATE3: begin
            nstate = STATE0;
            out = 3'b100;
        end
        default: begin
            nstate = STATE0;
            out = 3'b000;
        end
      endcase
    end

    // State register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cstate <= STATE0;
        end
        else begin
            cstate <= nstate;
        end
    end

endmodule