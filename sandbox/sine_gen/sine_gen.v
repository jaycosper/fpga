/**
 * Sine wave generator
**/

module sine_gen
#(
    parameter SINE_WIDTH = 14,
    parameter SINE_TABLE_SIZE = 5
)(
    input i_clk,
    input i_rst,
    input i_rst_n,

    input i_sine_en,
    input [SINE_TABLE_SIZE-1:0] i_freq_step,

    input i_sweep_en,
    input [SINE_TABLE_SIZE-1:0] i_sweep_step,

    output signed [SINE_WIDTH-1:0] o_sine_out
);

    reg signed [SINE_WIDTH-1:0] o_sine_out;

    // Sin gen
    reg signed [SINE_WIDTH-1:0] sine_table [0:(2**SINE_TABLE_SIZE)-1];
    // table needs to be updated for different SINE_WIDTH values
    // +8191 -> 1 sign plus 13 data
    initial begin
        sine_table[ 0] = 0;
        sine_table[ 1] = 1598;
        sine_table[ 2] = 3134;
        sine_table[ 3] = 4551;
        sine_table[ 4] = 5792;
        sine_table[ 5] = 6811;
        sine_table[ 6] = 7568;
        sine_table[ 7] = 8034;
        sine_table[ 8] = 8191;
        sine_table[ 9] = 8034;
        sine_table[10] = 7568;
        sine_table[11] = 6811;
        sine_table[12] = 5792;
        sine_table[13] = 4551;
        sine_table[14] = 3134;
        sine_table[15] = 1598;
        sine_table[16] = 0;
        sine_table[17] = -1599;
        sine_table[18] = -3135;
        sine_table[19] = -4552;
        sine_table[20] = -5793;
        sine_table[21] = -6812;
        sine_table[22] = -7569;
        sine_table[23] = -8035;
        sine_table[24] = -8192;
        sine_table[25] = -8035;
        sine_table[26] = -7569;
        sine_table[27] = -6812;
        sine_table[28] = -5793;
        sine_table[29] = -4552;
        sine_table[30] = -3135;
        sine_table[31] = -1599;
    end

    localparam SINE_CNTR_WIDTH = SINE_TABLE_SIZE;
    reg [SINE_CNTR_WIDTH-1:0] sine_cntr;
    reg [SINE_CNTR_WIDTH-1:0] cntr_step;
    reg sweep_flag;
    always@(posedge i_clk) begin
        if (i_rst == 1'b1 || i_rst_n == 1'b0) begin
            sine_cntr <= 0;
            cntr_step <= 0;
            sweep_flag <= 1'b0;
            o_sine_out <= 0;
        end else begin
            if (i_sine_en) begin
                sweep_flag <= i_sweep_en;
                if (i_sweep_en) begin
                    if (!sweep_flag) begin
                        // just enabled, capture step size
                        cntr_step <= i_sweep_step;
                    end
                    cntr_step <= cntr_step + cntr_step;
                end else begin
                    cntr_step <= 0;
                end
                sine_cntr <= sine_cntr + i_freq_step + cntr_step;
                o_sine_out <= sine_table[sine_cntr];
            end
        end
    end

endmodule
