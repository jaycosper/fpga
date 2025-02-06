module capture_sync #(
    parameter SYNC_STAGES = 2,
    parameter CLK_CYCLES_L2 = 10
)(
    input logic i_clk,      // clock
    input logic i_clk2,     // clock
    input logic i_rst,      // active-high reset
    input logic i_din,      // signal input
    output logic o_dout     // capture_syncd signal output
);

    // sync input with clock
    logic regin;
    always_ff @(posedge i_clk) begin : input_register
        if (i_rst) begin
            regin <= 0;
        end else begin
            regin <= i_din;
        end
    end

    // capture register
    logic capture;
    always_ff @(posedge regin) begin : capture_register
        if (i_rst) begin
            capture <= 0;
        end else begin
            capture <= ~capture;
        end
    end

    // synchronizer
    logic [2:0] synchronizer;
    always_ff @(posedge i_clk2) begin : synchronizer_registers
        if (i_rst) begin
            synchronizer <= 0;
        end else begin
            synchronizer <= {synchronizer[1:0],capture};
        end
    end

    // register output
    always_ff @(posedge i_clk2) begin : output_register
        if (i_rst) begin
            o_dout <= 0;
        end else begin
            o_dout <= synchronizer[$high(synchronizer)] ^ synchronizer[$high(synchronizer)-1];
        end
    end

    // // stream operator example
    // logic [6:0] a = 'h5A;
    // /* verilator lint_off UNUSED */
    // logic [6:0] b;
    // always_ff @(posedge i_clk) begin: stream_test
    //     b <= {<<{a}};
    //     if (i_rst) begin
    //         b <= 'h19;
    //     end
    // end

endmodule
