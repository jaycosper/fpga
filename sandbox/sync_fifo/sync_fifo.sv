/**
 * synchronous FIFO
 */

`timescale 1ns/1ps
`default_nettype none

module sync_fifo
#(
    parameter FIFO_DEPTH = 16,
    parameter DATA_WIDTH = 4
)(
    input wire i_clk,                   // synchronous clock
    input wire i_rst_n,                 // reset FIFO
    input wire i_wren,                  // write enable
    input wire i_rden,                  // read enable
    input wire [DATA_WIDTH-1:0] datain, // datain

    output logic o_empty,               // empty flag
    output logic o_full,                // full flag
    output logic [DATA_WIDTH-1:0] o_dataout,    // dataout
    output logic [1:0] o_errors         // error flags
);
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
    logic [ADDR_WIDTH-1:0] wrptr, rdptr;

    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

    always_ff @(posedge i_clk) begin : write_process
        if (!i_rst_n) begin
            wrptr <= 0;
        end else begin
            if (i_wren && !o_full) begin
                fifo_mem[wrptr] <= datain;
                wrptr <= wrptr + 1;
            end
        end
    end

    always_ff @(posedge i_clk) begin : read_process
        if (!i_rst_n) begin
            rdptr <= 0;
        end else begin
            if (i_rden && !o_empty) begin
                o_dataout <= fifo_mem[rdptr];
                rdptr <= rdptr + 1;
            end
        end
    end

    logic last_op_read; // '1' if last operation was read, '0' if write

    always_ff @(posedge i_clk) begin : last_operation_tracker
        if (!i_rst_n) begin
            last_op_read <= 1'b1; // Assume FIFO starts empty, so last operation is read
        end else begin
            if (i_rden && !o_empty) begin
                last_op_read <= 1'b1;
            end else if (i_wren && !o_full) begin
                last_op_read <= 1'b0;
            end
        end
    end

    always_comb begin : status_flags
        if (wrptr == rdptr) begin
            if (last_op_read) begin
                o_empty = 1;
                o_full = 0;
            end else begin
                o_empty = 0;
                o_full = 1;
            end
        end else begin
            o_empty = 0;
            o_full = 0;
        end
    end

    always_ff @(posedge i_clk) begin : error_flags
        o_errors[0] <= i_wren && o_full;   // write error: trying to write when full
        o_errors[1] <= i_rden && o_empty;  // read error: trying to read when empty
    end

endmodule

`default_nettype wire
