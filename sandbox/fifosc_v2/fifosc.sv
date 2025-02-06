/**
 * single clock FIFO
 */
 //! Single clock FIFO
module fifosc
#(
    parameter DATA_WIDTH = 4
)(
    input logic clk,                    // posedge clock
    input logic flush,                  // flush FIFO
    input logic insert,                 // insert data
    input logic remove,                 // remove data
    input logic [DATA_WIDTH-1:0]  din,  // datain

    output logic empty,                 // FIFO empty flag
    output logic full,                  // FIFO full flag
    output logic [DATA_WIDTH-1:0] dout  // dataout
);
    localparam  FIFO_DEPTH = 8;
    localparam  k = 1;
    localparam  as = $clog2(FIFO_DEPTH-1);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [as-1:0] wrptr, wrptr_q;
    reg [as-1:0] rdptr, rdptr_q;

    always_ff @(posedge clk) begin : fifo_process
        if (flush) begin
            full <= 0;
            empty <= 1;
            // initialize ptrs
            wrptr <= -1;
            wrptr_q <= -2;
            rdptr <= -1;
            rdptr_q <= -2;
            dout <= 0;
        end else begin
            case({remove, insert})
                2'b00: ; // nothing to do
                2'b01: begin
                    // insert element
                    if (~full) begin
                        // place datain into fifo_mem
                        fifo_mem[wrptr] <= din;
                        // clear empty flag
                        empty <= 0;
                        wrptr <= {(wrptr[k]^wrptr[0]), wrptr[as-1:1]};
                        wrptr_q <= wrptr;
                        // check for full
                        if (wrptr == rdptr_q) begin
                            full <= 1;
                        end
                    end
                end
                2'b10: begin
                    // remove element
                    if (~empty) begin
                        // place datain into fifo_mem
                        dout <= fifo_mem[rdptr];
                        // clear full flag
                        full <= 0;
                        rdptr_q <= rdptr;
                        rdptr <= {(rdptr[k]^rdptr[0]), rdptr[as-1:1]};
                        // check for empty
                        // FOR SOME REASON, THIS IF NEEDS TO BE COMMENTED OUT FOR DOCUMENTER TO WORK
                        if (rdptr == wrptr_q) begin
                            empty <= 1;
                        end
                    end
                end
                2'b11: begin
                    // insert and remove element
                    // full/empty flags unaffected (remain the same)
                    // current state of full flags don't matter either
                    // but empty flag does -- need to pass data straight through
                    if (empty) begin
                        dout <= din;
                    end else begin
                        // place datain into fifo_mem
                        fifo_mem[wrptr] <= din;
                        // place datain into fifo_mem
                        dout <= fifo_mem[rdptr];
                        // update ptrs
                        wrptr_q <= wrptr;
                        rdptr_q <= rdptr;
                        rdptr <= {(rdptr[k]^rdptr[0]), rdptr[as-1:1]};
                        wrptr <= {(wrptr[k]^wrptr[0]), wrptr[as-1:1]};
                    end
                end
            endcase
        end
    end
endmodule
