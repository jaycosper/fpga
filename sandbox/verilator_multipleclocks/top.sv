module top
#(
    parameter BUS_WIDTH = 4
)
(
    input logic i_clk,     // clock
    input logic i_clk2,     // clock
    input logic i_arst_n,   // active-low reset
    input logic [BUS_WIDTH-1:0] i_din1,     // signal 1 input
    input logic [BUS_WIDTH-1:0] i_din2,     // signal 2 input
    output logic [BUS_WIDTH-1:0] o_dout1,   // signal 1 output
    output logic [BUS_WIDTH-1:0] o_dout2    // signal 2 output
);

    // clock 1
    always_ff @(posedge i_clk or negedge i_arst_n)
    begin
        if (i_arst_n) begin
            o_dout1 <= 0;
        end else begin
            // prime pipe
            o_dout1 <= o_dout1 + i_din1;
        end
    end

    // clock 2
    always_ff @(posedge i_clk2 or negedge i_arst_n)
    begin
        if (i_arst_n) begin
            o_dout2 <= 0;
        end else begin
            // prime pipe
            o_dout2 <= o_dout2 + i_din2;
        end
    end

endmodule
