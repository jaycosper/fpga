// Clock pulse and edge detection generator
// Clock pulse if rounded to nearest log2 value
module lfsr (
    input wire clk,                 //! input clock
    input wire rst_n,               //! active-low asynchronous reset
    input wire enable,              //! active-high enable
    input wire [WIDTH-1:0] taps,    //! feedback tap array
    output wire [WIDTH-1:0] seq     //! output sequence
);
    //! Number of clock cycles per pulse
    parameter integer WIDTH = 8;
    reg [WIDTH-1:0] lfsr_reg, lfsr_next;

    //! clock the next stage of the LFSR
    always @(negedge rst_n or posedge clk) begin : lfsr_clocking
        if (~rst_n) begin
            lfsr_reg <= 0;
        end else begin
            if (enable) begin
                lfsr_reg <= lfsr_next;
            end
        end
    end

    //! build up the LFSR feedback loop
    reg lfsr_fdbk;
    integer n;
    always @(*) begin : lfsr_feedback_gen
        lfsr_fdbk = lfsr_reg[WIDTH-1] ^ (~|lfsr_reg[WIDTH-2:0]); // feedback loop is MSb xor-ed with nor of all remaining bits
        for (n = 1; n < WIDTH; n = n + 1) begin
            if (taps[n-1] == 1) begin
                lfsr_next[n] = lfsr_reg[n-1] ^ lfsr_fdbk;
            end else begin
                lfsr_next[n] = lfsr_reg[n-1];
            end
        end
        lfsr_next[0] = lfsr_fdbk;
    end

    assign seq = lfsr_reg;

endmodule
