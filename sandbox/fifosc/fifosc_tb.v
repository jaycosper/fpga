`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module assert(input clk, input test);
    always @(posedge clk)
    begin
        if (test !== 1)
        begin
            $display("ASSERTION FAILED in %m");
            $finish;
        end
    end
endmodule
`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module test_fifosc;
    parameter TB_DATA_WIDTH = 4;

    parameter clock_period = 10;

    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    integer i;

    reg flush;
    reg insert;
    reg remove;
    reg [TB_DATA_WIDTH-1:0]  di;

    wire empty;
    wire full;
    wire [TB_DATA_WIDTH-1:0] do;

    fifosc #(
        .DATA_WIDTH(TB_DATA_WIDTH)
    ) u_fifosc (
        .clk    ( clk ),
        .flush  ( flush ),
        .insert ( insert ),
        .remove ( remove ),
        .di     ( di ),

        .empty  ( empty ),
        .full   ( full ),
        .do     ( do )
    );

    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, test_fifosc);  // dump variable changes in the testbench
                                    // and all modules under it

        flush <= 0;
        insert <= 0;
        remove <= 0;
        di <= 0;

        $display("time\tflush\tinsert\tremove\tdi\tdo\tempty\tfull");
        $monitor("%4g\t%b\t%b\t%b\t%h\t%h\t%b\t%b",
                $time, flush, insert, remove, di, do, empty, full);

        // flush fifo
        @(negedge clk);
            flush <= 1;
        @(negedge clk);
            flush <= 0;
        `assert(full, 0);
        `assert(empty, 1);

        // insert when empty
        @(negedge clk);
            insert <= 1;
            remove <= 0;
        @(negedge clk);
            di <= di + 1;

        insert <= 0;
        remove <= 0;
        `assert(full, 0);
        `assert(empty, 0);

        // remove 1
        @(negedge clk);
            insert <= 0;
            remove <= 1;
        @(negedge clk);

        insert <= 0;
        remove <= 0;
        `assert(full, 0);
        `assert(empty, 1);
        `assert(do, 0);

        // concurrent insert/remove when empty
        @(negedge clk);
            insert <= 1;
            remove <= 1;
        @(negedge clk);
            di <= di + 1;

        `assert(full, 0);
        `assert(empty, 1);
        `assert(do, 0);

        remove <= 0;
        insert <= 1;
        // attempt to insert 7 data values; full at 6, 7/8 error
        for (i = 0; i < 8; i++)
            @(negedge clk);
                di <= di + 1;
        `assert(full, 1);
        `assert(empty, 0);

        // concurrent insert/remove when full
        @(negedge clk);
            insert <= 1;
            remove <= 1;
        @(negedge clk);
            di <= di + 1;

        remove <= 1;
        insert <= 0;
        // attempt to remove 7 data values; empty at 6, 7/8 error
        for (i = 0; i < 8; i++)
            @(negedge clk);

        remove <= 0;
        insert <= 1;
        // attempt to insert 3 data values
        for (i = 0; i < 2; i++)
            @(negedge clk);
                di <= di + 1;

        remove <= 1;
        insert <= 1;
        // attempt concurrent insert/remove 4 data values
        for (i = 0; i < 2; i++)
            @(negedge clk);
                di <= di + 1;

        remove <= 1;
        insert <= 0;
        // attempt remove 4 data values; empty at 3
        for (i = 0; i < 2; i++)
            @(negedge clk);
                di <= di + 1;

        $finish();
    end
endmodule