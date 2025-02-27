`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module mealy_tb;

    // clock period (1ns * 10 = 10ns; 100MHz)
    localparam clock_period = 10;

    // clock generator
    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    // generic integer using in FOR loops
    integer i;

    // input signals
    reg reset;
    reg flag;

    // output signals
    wire sm_out;

    // instances under test
    mealy u_mealy (

        .clk    (clk),
        .reset  (reset),
        .flag   (flag),
        .sm_out (sm_out)
    );

    // start of test process
    initial begin
        // save file, and specify what to save
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, mealy_tb);  // dump variable changes in the testbench
                                    // and all modules under it

        // initial state of inputs
        reset <= 0;
        flag <= 0;

        // monitor signals of concern
        $display("time\treset\tflag\tsm_out");
        $monitor("%4g\t%b\t%b\t%b", $time, reset, flag, sm_out);

        // reset device
        @(negedge clk);
            reset <= 1;
        @(negedge clk);
            reset <= 0;

        // intro clocks
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        flag <= 1;
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        flag <= 0;

        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        // end test (if we did not assert)
        $finish();
    end
endmodule