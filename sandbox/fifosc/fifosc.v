/**
 * single clock FIFO
 */
module fifosc
#(
    parameter DATA_WIDTH = 4
)(
    input  clk,                 // posedge clock
    input  flush,               // flush FIFO
    input  insert,              // insert data
    input  remove,              // remove data
    input [DATA_WIDTH-1:0]  di, // datain

    output empty,               // FIFO empty flag
    output full,                // FIFO full flag
    output [DATA_WIDTH-1:0] do  // dataout
);
    parameter FIFO_DEPTH = 7;
    parameter k = 1;
    parameter as = 3;

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [as-1:0] wrptr, wrptr_q;
    reg [as-1:0] rdptr, rdptr_q;

    wire flush, remove, insert;
    wire [DATA_WIDTH-1:0] di;
    reg [DATA_WIDTH-1:0] do;
    reg full, empty;

    always @(posedge clk) begin
        if (flush) begin
            full <= 0;
            empty <= 1;
            // initialize ptrs
            wrptr <= -1;
            wrptr_q <= -2;
            rdptr <= -1;
            rdptr_q <= -2;
        end
        else begin
            case({remove, insert})
            2'b00: ;// nothing to do
            2'b01:
                // insert element
                if (~full) begin
                    // place datain into fifo_mem
                    fifo_mem[wrptr] <= di;
                    // clear empty flag
                    empty <= 0;
                    wrptr <= {(wrptr[k]^wrptr[0]), wrptr[as-1:1]};
                    wrptr_q <= wrptr;
                    // check for full
                    if (wrptr == rdptr_q) begin
                        full <= 1;
                    end
                end
            2'b10:
                // remove element
                if (~empty) begin
                    // place datain into fifo_mem
                    do <= fifo_mem[rdptr];
                    // clear full flag
                    full <= 0;
                    rdptr_q <= rdptr;
                    rdptr <= {(rdptr[k]^rdptr[0]), rdptr[as-1:1]};
                    // check for empty
                    if (rdptr == wrptr_q) begin
                        empty <= 1;
                    end
                end
            2'b11:
                // insert and remove element
                if (~full && ~empty) begin
                    // place datain into fifo_mem
                    fifo_mem[wrptr] <= di;
                    // place datain into fifo_mem
                    do <= fifo_mem[rdptr];
                    // update ptrs
                    wrptr_q <= wrptr;
                    rdptr_q <= rdptr;
                    rdptr <= {(rdptr[k]^rdptr[0]), rdptr[as-1:1]};
                    wrptr <= {(wrptr[k]^wrptr[0]), wrptr[as-1:1]};
                    // full/empty flags unaffected (remain the same)
                end
            endcase
        end
    end
endmodule
