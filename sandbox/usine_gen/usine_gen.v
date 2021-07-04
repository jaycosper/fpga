/**
 * Sine wave generator
**/

module usine_gen
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

    output [SINE_WIDTH-1:0] o_sine_out
);

    reg [SINE_WIDTH-1:0] o_sine_out;

    // Sin gen
    reg [SINE_WIDTH-1:0] sine_table [0:(2**SINE_TABLE_SIZE)-1];
    // table needs to be updated for different SINE_WIDTH values
    // +16384 -> 14 bits unsigned data
    initial begin
        sine_table[ 0] = 8192;
        sine_table[ 1] = 9790;
        sine_table[ 2] = 11326;
        sine_table[ 3] = 12743;
        sine_table[ 4] = 13984;
        sine_table[ 5] = 15003;
        sine_table[ 6] = 15760;
        sine_table[ 7] = 16226;
        sine_table[ 8] = 16383;
        sine_table[ 9] = 16226;
        sine_table[10] = 15760;
        sine_table[11] = 15003;
        sine_table[12] = 13984;
        sine_table[13] = 12743;
        sine_table[14] = 11326;
        sine_table[15] = 9790;
        sine_table[16] = 8192;
        sine_table[17] = 6593;
        sine_table[18] = 5057;
        sine_table[19] = 3640;
        sine_table[20] = 2399;
        sine_table[21] = 1380;
        sine_table[22] = 623;
        sine_table[23] = 157;
        sine_table[24] = 0;
        sine_table[25] = 157;
        sine_table[26] = 623;
        sine_table[27] = 1380;
        sine_table[28] = 2399;
        sine_table[29] = 3640;
        sine_table[30] = 5057;
        sine_table[31] = 6593;
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
