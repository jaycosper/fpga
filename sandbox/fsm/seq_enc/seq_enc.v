// State Machine with single sequential block
// fsm_1.v
// From Xilinx Vivado Design Suite User Guide: Synthesis
// sequential encoding
module seq_enc(
    input wire clk,
    input wire reset,
    input wire flag,
    output reg sm_out
);
    localparam  s0 = 3'b000;
    localparam  s1 = 3'b001;
    localparam  s2 = 3'b010;
    localparam  s3 = 3'b011;
    localparam  s7 = 3'b111;

    reg [2:0] state;

    always@(posedge clk) begin
        if(reset) begin
            state <= s1;
            sm_out <= 1'b1;
        end else begin
            // set output and state at the same time for the next clock
            case(state)
                s0:
                    if(flag) begin
                        state <= s1;
                        sm_out <= 1'b1;
                    end else begin
                        state <= s2;
                        sm_out <= 1'b0;
                    end
                s1: begin state <= s2; sm_out <= 1'b0; end
                s2: begin state <= s3; sm_out <= 1'b0; end
                s3: begin state <= s7; sm_out <= 1'b1; end
                s7: begin state <= s0; sm_out <= 1'b1; end
                // missing default -> error handler case
            endcase
        end
    end
endmodule
