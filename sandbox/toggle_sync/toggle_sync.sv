`default_nettype none

module toggle_sync #(
    parameter pSYNC_STAGES = 2,
    parameter pDATA_WIDTH = 10
)(
    input   wire                    i_clk,    // clock 1 (fast)
    input   wire                    i_rst,    // active-high reset
    input   wire [pDATA_WIDTH-1:0]  i_din,    // signal input

    input   wire                    i_clk2,   // clock 2 (slow)
    output  logic [pDATA_WIDTH-1:0] o_dout    // sync'd signal output
);

genvar g;
generate
    for (g = 0; g < pDATA_WIDTH; g = g + 1) begin : gen_sync_stages
        // capture register
        logic capture_select, capture;
        assign capture_select = (i_din[g]) ? !capture : capture;
        always_ff @(posedge i_clk) begin : capture_register
            if (i_rst) begin
                capture <= 0;
            end else begin
                capture <= capture_select;
            end
        end

        // synchronizer
        logic [pSYNC_STAGES-1:0] synchronizer;
        always_ff @(posedge i_clk2) begin : synchronizer_registers
            synchronizer <= {synchronizer[$high(synchronizer)-1:0],capture};
        end

        // output
        assign o_dout[g] = synchronizer[$high(synchronizer)] ^ synchronizer[$high(synchronizer)-1];
    end
endgenerate

endmodule

`default_nettype wire
