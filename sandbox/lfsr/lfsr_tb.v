`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module lfsr_tb;

    // width of data
    localparam LFSR_WIDTH_TB = 8;

    // clock period (1ns * 10 = 10ns; 100MHz)
    localparam clock_period = 10;

    // clock generator
    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    // generic integer using in FOR loops
    integer i;

    // input signals
    reg rst_n;
    reg data;

    // output signals
    reg enable;
    reg [LFSR_WIDTH_TB-1:0] taps;
    wire [LFSR_WIDTH_TB-1:0] seq;
    reg [LFSR_WIDTH_TB-1:0] seq_compare;
    reg [(2**LFSR_WIDTH_TB)-1:0] seq_hash;

    // instances under test
    lfsr #(
        .WIDTH(LFSR_WIDTH_TB)
    ) u_lfsr (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (enable),
        .taps   (taps),
        .seq    (seq)
    );

    // start of test process
    initial begin
        // save file, and specify what to save
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, lfsr_tb);  // dump variable changes in the testbench
                                    // and all modules under it

        // initial state of inputs
        //taps <= (LFSR_WIDTH_TB)'b10001110;
        taps <= 8'b10001110;
        rst_n <= 1;
        enable <= 0;

        seq_hash <= 0;

        // monitor signals of concern
        $display("time\tenable\ttaps\tseq");
        $monitor("%4g\t\t%b\t%x\t\t%x", $time, enable, taps, seq);

        // reset device
        @(negedge clk);
            rst_n <= 0;
        @(negedge clk);
            rst_n <= 1;

        // intro clocks
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        enable <= 1;
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        enable <= 0;
        seq_compare <= seq;

        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end
        `assert(seq, seq_compare); // check that enable works

        enable <= 1;
        for(i=0; i<(2**LFSR_WIDTH_TB);i=i+1) begin
            // cycle through all combinations
            @(negedge clk);
            // check if we saw this value already
            if(seq_hash[seq] == 1'b1) begin
                // assert if we have
                `assert(seq, 0);
            end else begin
                // else record sighting
                seq_hash[seq] <= 1'b1;
            end
        end

        // assert that all values seen
        @(negedge clk);
        `assert(&seq_hash, 1);

        @(negedge clk);
        if(seq_hash[seq] != 1'b1) begin
            // check that we have already seen this value
            `assert(seq, seq-1);
        end

        // end test (if we did not assert)
        $finish();
    end
endmodule