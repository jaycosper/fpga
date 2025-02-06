module fsm
(
    input logic clk,
    input logic reset,
    output logic sm_out
);

    enum {idle, state0, state1, state2} currState, nextState;
    enum {WAITE, LOAD, DONE} state, next_state;

    enum logic [1:0] {READY=3'b101, SET=3'b010, GO=3'b110} mode_control;

    // State Sequencer
    always_ff @(posedge clk or posedge reset)
        if (!resetN) state <= 0; // SYNTAX ERROR
        else state <= next_state;

    // Next State Decoder (sequentially cycle through the three states)
    always_comb
        case (state)
            WAITE: next_state = state + 1; // SYNTAX ERROR
            LOAD : next_state = state + 1; // SYNTAX ERROR
            DONE : next_state = state + 1; // SYNTAX ERROR
        endcase

    // Output Decoder
    always_comb
        case (state)
            WAITE: mode_control = READY; sm_out = 1'b1;
            LOAD : mode_control = SET; sm_out = 1'b0;
            DONE : mode_control = DONE; sm_out = 1'b0;// SYNTAX ERROR
        endcase

endmodule