`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module sm_4way_tb;

    // clock period (1ns * 10 = 10ns; 100MHz)
    localparam clock_period = 10;

    // clock generator
    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    // generic integer using in FOR loops
    integer i;

    // input signals
    reg reset;
    reg control;

    // output signals ( I wish 2D arrays were a thing )
    wire[1:0] y0;
    wire[1:0] y1;
    wire[1:0] y2;
    wire[1:0] y3;

    // instances under test
    sm_sep_cs_ns_ol u_sm_sep_cs_ns_ol
    (
        .clk        ( clk       ),
        .reset      ( reset     ),
        .control    ( control   ),
        .y          ( y0        )
    );
    sm_comb_cs_ns_sep_ol u_sm_comb_cs_ns_sep_ol
    (
        .clk        ( clk       ),
        .reset      ( reset     ),
        .control    ( control   ),
        .y          ( y1        )
    );
    sm_comb_ns_ol_sep_cs u_sm_comb_ns_ol_sep_cs
    (
        .clk        ( clk       ),
        .reset      ( reset     ),
        .control    ( control   ),
        .y          ( y2        )
    );
    sm_comb_cs_ns_ol u_sm_comb_cs_ns_ol
    (
        .clk        ( clk       ),
        .reset      ( reset     ),
        .control    ( control   ),
        .y          ( y3        )
    );

    // start of test process
    initial begin
        // save file, and specify what to save
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, sm_4way_tb);  // dump variable changes in the testbench
                                    // and all modules under it

        // initial state of inputs
        reset <= 0;
        control <= 0;

        // monitor signals of concern
        $display("time\treset\tcontrol\ty0\ty1\ty2\ty3");
        $monitor("%4g\t%b\t%b\t%d\t%d\t%d\t%d", $time, reset, control, y0, y1, y2, y3);

        // reset device
        @(negedge clk);
            reset <= 1;
        @(negedge clk);
            reset <= 0;

        // intro clocks
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        control <= 1;
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        control <= 0;

        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        // end test (if we did not assert)
        $finish();
    end

    always @(negedge clk) begin
        `assert(y0, y1);
        `assert(y1, y2);
        `assert(y2, y3);
    end
endmodule