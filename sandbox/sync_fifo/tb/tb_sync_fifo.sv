`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module tb;
    parameter TB_FIFO_DEPTH = 16;
    parameter TB_DATA_WIDTH = 4;

    localparam lpCLK_FREQ_MHZ = 50;
    localparam lpCLK_PERIOD_NS = 2 * 1000 / lpCLK_FREQ_MHZ;
    logic clk = 0;
    always #(lpCLK_PERIOD_NS/2) clk = ~clk;

    integer i;

    logic rst_n;
    logic wren;
    logic rden;
    logic [TB_DATA_WIDTH-1:0]  din;

    wire empty;
    wire full;
    wire [TB_DATA_WIDTH-1:0] dout;
    wire [1:0] errors;

    function void check(input logic test, input logic value);
        if (test !== value) begin
            $display("CHECK FAILED in %m: signal %b != value %b", test, value);
            $finish;
        end
    endfunction

    function void check_data(input logic [TB_DATA_WIDTH-1:0] test, input logic [TB_DATA_WIDTH-1:0] value);
        if (test !== value) begin
            $display("CHECK FAILED in %m: signal %b != value %b", test, value);
            $finish;
        end
    endfunction

    sync_fifo #(
        .FIFO_DEPTH(TB_FIFO_DEPTH),
        .DATA_WIDTH(TB_DATA_WIDTH)
    ) dut (
        .i_clk      ( clk ),
        .i_rst_n    ( rst_n ),
        .i_wren     ( wren ),
        .i_rden     ( rden ),
        .datain     ( din ),
        .o_empty    ( empty ),
        .o_full     ( full ),
        .o_dataout  ( dout ),
        .o_errors   ( errors )
    );

    logic [TB_DATA_WIDTH-1:0]  expected_dout;

    initial begin
        $dumpfile("obj_dir/tb_sync_fifo.vcd");  // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, dut);          // dump variable changes in the testbench and all modules under it

        rst_n = 0;
        wren = 0;
        rden = 0;
        din = 0;

        $display("time\trst_n\twren\trden\tdin\tdout\texpected_dout\tempty\tfull");
        $monitor("%4g\t%b\t%b\t%b\t%h\t%h\t%h\t\t%b\t%b",
                $time, rst_n, wren, rden, din, dout, expected_dout, empty, full);

        // rst_n fifo
        @(negedge clk);
            rst_n = 0;
        @(negedge clk);
            rst_n = 1;
        check(full, 0);
        check(empty, 1);

        // wren when empty
        @(negedge clk);
            wren = 1;
            rden = 0;
            expected_dout = din;

        @(negedge clk);
        wren = 0;
        rden = 0;
        check(full, 0);
        check(empty, 0);

        // rden 1
        @(negedge clk);
            wren = 0;
            rden = 1;
        @(negedge clk);

        wren = 0;
        rden = 0;
        check(full, 0);
        check(empty, 1);
        check_data(dout, expected_dout);

        // rden when empty
        @(negedge clk);
            wren = 0;
            rden = 1;
        @(negedge clk);
        check(full, 0);
        check(empty, 1);
        check(errors[0], 0);
        check(errors[1], 1);

        // I would argue that this is an invalid test case since reading from an empty FIFO is undefined behavior.
        // // concurrent wren/rden when empty
        // @(negedge clk);
        //     wren = 1;
        //     rden = 1;
        //     din = 1;
        //     expected_dout = din;
        // @(negedge clk);
        // check(full, 0);
        // check(empty, 1);
        // check_data(dout, expected_dout);

        rden = 0;
        wren = 1;
        din = 2;
        expected_dout = din;
        // attempt to fill FIFO
        while(!full) begin
            @(negedge clk);
                din = din + 1;
        end
        check(full, 1);
        check(empty, 0);

        // wren when full
        @(negedge clk);
            wren = 1;
            rden = 0;
        @(negedge clk);
        check(full, 1);
        check(empty, 0);
        check(errors[0], 1);
        check(errors[1], 0);

        // I would argue that this is an invalid test case since writing to a full FIFO is undefined behavior.
        // // concurrent wren/rden when full
        // @(negedge clk);
        //     wren = 1;
        //     rden = 1;
        // @(negedge clk);
        //     check_data(dout, expected_dout);
        //     expected_dout = expected_dout + 1;

        rden = 1;
        wren = 0;
        // attempt to drain FIFO
        while (!empty) begin
            @(negedge clk);
            check_data(dout, expected_dout);
            expected_dout = expected_dout + 1;
        end

        rden = 0;
        wren = 1;
        din = 'hd;
        expected_dout = din;
        // attempt to wren 2 data values
        for (i = 0; i < 2; i++) begin
            @(negedge clk);
                din = din + 1;
        end

        rden = 1;
        wren = 1;
        // attempt concurrent wren/rden 4 data values
        for (i = 0; i < 4; i++) begin
            @(negedge clk);
                din = din + 1;
                check_data(dout, expected_dout);
                expected_dout = expected_dout + 1;
        end

        rden = 1;
        wren = 0;
        // attempt rden 4 data values; empty at 3
        for (i = 0; i < 4; i++) begin
            @(negedge clk);
                if (~empty) begin
                    check_data(dout, expected_dout);
                    expected_dout = expected_dout + 1;
                end
        end

        $finish();
    end
endmodule