/**
 * mini LFSR from HPE interview
 */

`timescale 1ns/1ps
`default_nettype none

module mini_lfsr
(
    input wire i_clk,       // synchronous clock
    input wire i_rst_n,     // reset

    output logic o_output   // output flag
);
    logic [2:0] lfsr_reg;
    logic lfsr_in;

    assign lfsr_in = !(lfsr_reg[2] ^ lfsr_reg[1]);

    always_ff @(posedge i_clk) begin : sync_process
        if (!i_rst_n) begin
            lfsr_reg <= '0;
        end else begin
            lfsr_reg <= {lfsr_reg[1], lfsr_reg[0], lfsr_in};
        end
    end

    assign o_output = !(|lfsr_reg);

endmodule

`default_nettype wire
