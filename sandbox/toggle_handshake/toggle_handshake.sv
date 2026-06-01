`timescale 1ns / 1ps

`default_nettype none

module toggle_handshake #(
    parameter p_SYNC_STAGES = 2,
    parameter p_DATA_WIDTH = 10
)(
    input   wire                        i_clk_wr,   // write clock 1 (fast)
    input   wire                        i_rst_wr,   // write active-high reset
    output  logic                       o_rdy_wr,   // ready for write
    input   wire [p_DATA_WIDTH-1:0]     i_din_wr,   // write data in
    input   wire                        i_tgl_wr,   // write toggle signal

    input   wire                        i_clk_rd,   // read clock 1 (fast)
    input   wire                        i_rst_rd,   // read active-high reset
    output  logic                       o_rdy_rd,   // ready for read
    output  logic [p_DATA_WIDTH-1:0]    o_dout_rd,  // read data out
    input   wire                        i_tgl_rd    // read toggle signal
);

    (* ASYNC_REG = "true" *) logic wr_tgl_sync [0:p_SYNC_STAGES-1];
    (* ASYNC_REG = "true" *) logic rd_tgl_sync [0:p_SYNC_STAGES-1];

    always_ff @(posedge i_clk_wr) begin : capture_register
        wr_tgl_sync <= {i_tgl_rd, wr_tgl_sync[0:p_SYNC_STAGES-2]};
        if (i_rst_wr) begin
            wr_tgl_sync <= '{default: '0};
        end
    end

    assign o_rdy_wr = i_tgl_wr ^ wr_tgl_sync[$high(wr_tgl_sync)];

    always_ff @(posedge i_clk_rd) begin : synchronizer_registers
        o_dout_rd <= i_din_wr;
        rd_tgl_sync <= {i_tgl_wr, rd_tgl_sync[0:p_SYNC_STAGES-2]};

        if (i_rst_rd) begin
            rd_tgl_sync <= '{default: '0};
        end
    end

    assign o_rdy_rd = i_tgl_rd ^ rd_tgl_sync[$high(rd_tgl_sync)];

endmodule

`default_nettype wire
