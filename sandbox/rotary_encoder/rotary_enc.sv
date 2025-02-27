module rotary_enc #(
    parameter CORDW = 10,
    parameter V_RES = 480
)(
    input logic i_clk,      // clock
    input logic i_rst,      // active-high reset
    input logic i_rst_n,    // active-low reset
    input logic i_enc_a,    // signal A input
    input logic i_enc_b,    // signal B input
    output logic [CORDW-1:0] o_enc_cnt  // encoder count output
);

    // global reset
    logic reset;
    assign reset = i_rst || ~i_rst_n;

    logic sysrst = reset;
    logic clk_pix = i_clk;
    logic enc_a = i_enc_a;
    logic enc_b = i_enc_b;

    localparam  ENC_STATE_WIDTH = 2;
    localparam  ENC_ST0 = 2'b00;
    localparam  ENC_ST1 = 2'b01;
    localparam  ENC_ST2 = 2'b11;
    localparam  ENC_ST3 = 2'b10;

    // cstate - current state; pstate - previous state
    logic [ENC_STATE_WIDTH-1:0] enc_cstate, enc_pstate;
    logic [CORDW-1:0] enc_position; // vertical position of paddle 1 from encoder
    localparam ENC_P_SP = 4;    // speed
    localparam ENC_P_H = 40;    // height in pixels

    logic move_up_enc, move_dn_enc;
    logic enc_a_q, enc_b_q;

    assign enc_cstate = {enc_a_q, enc_b_q};
    // handle rotary encoder
    always_ff @(posedge clk_pix) begin
        if (sysrst) begin
            enc_pstate <= ENC_ST0;
            enc_a_q <= 0;
            enc_b_q <= 0;
            enc_position <= ENC_P_SP;
        end else begin
            enc_a_q <= enc_a;
            enc_b_q <= enc_b;
            enc_pstate <= enc_cstate;
            if (move_dn_enc) begin
                if (enc_position > ENC_P_SP) enc_position <= enc_position - ENC_P_SP;
            end
            if (move_up_enc) begin
/* verilator lint_off WIDTH */
                if (enc_position < V_RES - (ENC_P_H + ENC_P_SP)) enc_position <= enc_position + ENC_P_SP;
/* verilator lint_on WIDTH */
            end
        end
    end

    always_comb begin : state_handler
        move_up_enc = 1'b0;
        move_dn_enc = 1'b0;
        case(enc_cstate)
            ENC_ST0: begin
                if (enc_pstate == ENC_ST3) begin move_up_enc = 1'b1; end
                if (enc_pstate == ENC_ST1) begin move_dn_enc = 1'b1; end
            end
            ENC_ST1: begin
                if (enc_pstate == ENC_ST0) begin move_up_enc = 1'b1; end
                if (enc_pstate == ENC_ST2) begin move_dn_enc = 1'b1; end
            end
            ENC_ST2: begin
                if (enc_pstate == ENC_ST1) begin move_up_enc = 1'b1; end
                if (enc_pstate == ENC_ST3) begin move_dn_enc = 1'b1; end
            end
            ENC_ST3: begin
                if (enc_pstate == ENC_ST2) begin move_up_enc = 1'b1; end
                if (enc_pstate == ENC_ST0) begin move_dn_enc = 1'b1; end
            end
            // missing default -> error handler case
        endcase
    end

    assign o_enc_cnt = enc_position;

endmodule
