`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module rem5_tb;

    reg clk = 0;

    always #5 clk = !clk;

    reg reset;
    reg valid;
    reg sequence;
    wire div_flag;

    rem5 u_rem5 (
        .clk        ( clk ),
        .reset      ( reset ),
        .valid      ( valid ),
        .sequence   ( sequence ),
        .div_flag   ( div_flag )
    );

    integer testcase;
    integer i, n;

    localparam DATA_WIDTH = 8;
    reg [DATA_WIDTH-1:0] data;

    localparam TEST_COUNT = 32;
    reg expected_result;

    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, rem5_tb);       // dump variable changes in the testbench
                                    // and all modules under it

        $display("time\treset\tvalid\tsequence\tdiv_flag\tdata\texp_result");
        $monitor("%4g\t%b\t%b\t%b\t\t%b\t\t%d\t%b",
                $time, reset, valid, sequence, div_flag, data, expected_result);

        // testcase #0 : reset
        testcase = 0;
        @(negedge clk);
        @(negedge clk);
        reset = 1;
        @(negedge clk);
        reset = 0;

        // testcases
        for (n = 0; n < TEST_COUNT; n++) begin
            // testcase number
            testcase = n+1;
            // generate random unsigned number
            data = $urandom % (2**DATA_WIDTH - 1);
            expected_result = (data % 5 == 0) ? 1'b1 : 1'b0;
            // clock out data MSb first
            for (i = DATA_WIDTH-1; i >= 0; i--) begin
                sequence = data[i];
                valid = 1;
                @(negedge clk);
            end
            // finished clocking it out
            valid = 0;
            sequence = 1'bz;
            @(negedge clk);
            // check that results match
            `assert(div_flag, expected_result);
            @(negedge clk);
        end

        $finish();

    end
endmodule