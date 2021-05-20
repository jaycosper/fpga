`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module debounce_tb;

    // number of debouncing stages (DFFs)
    localparam DEBOUNCE_STAGES = 4;
    // number of debounce instances for test
    localparam DEBOUNCE_INST = 3;

    // clock period (1ns * 10 = 10ns; 100MHz)
    localparam clock_period = 10;

    // clock generator
    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    // generic integer using in FOR loops
    integer i;

    // input signals
    reg din;
    reg rst_n;

    // joined output signal
    wire [DEBOUNCE_INST-1:0] dout;

    // generated instance variable
    genvar inst;
    // generate multiple debounce instances
    generate
        for(inst=0; inst<DEBOUNCE_INST; inst=inst+1)
            debounce #(
                // each debounce instance has different number of stages
                // inst 0 => 4-0 = 4; inst 1 => 4-1 = 3; etc...
                .STAGES(DEBOUNCE_STAGES-inst)
            ) u_debounce (
                .clk(clk),
                .rst_n(rst_n),
                .din(din),
                .dout(dout[inst])
            );
    endgenerate

    // start of test process
    initial begin
        // save file, and specify what to save
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, debounce_tb);  // dump variable changes in the testbench
                                    // and all modules under it

        // initial state of inputs
        din <= 0;
        rst_n <= 1;

        // monitor signals of concern
        $display("time\tdin\tdout");
        $monitor("%4g\t%b\t%b", $time, din, dout);

        // reset device
        @(negedge clk);
            rst_n <= 0;
        @(negedge clk);
            rst_n <= 1;

        // flush debounce pipeline
        for(i=0; i<DEBOUNCE_STAGES*2;i=i+1) begin
            @(negedge clk);
        end
        // assert outputs
        for(i=0; i<DEBOUNCE_INST;i=i+1) begin
            `assert(dout[i], 0);
        end

        // generate toggling input
        for(i=0; i<DEBOUNCE_STAGES*2;i=i+1) begin
            @(negedge clk);
                din <= !din;
        end

        // stablize input at '1'
        din <= 1;
        while (dout[DEBOUNCE_INST-1] != 1) begin
            @(negedge clk);
        end

        // allow for signals to propagate through pipeline
        for(i=0; i<DEBOUNCE_STAGES*2;i=i+1) begin
            @(negedge clk);
        end
        // assert outputs
        for(i=0; i<DEBOUNCE_INST;i=i+1) begin
            `assert(dout[i], 1);
        end

        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        // generate toggling input
        for(i=0; i<DEBOUNCE_STAGES*2;i=i+1) begin
            @(negedge clk);
                din <= !din;
        end

        // stablize input at '0'
        din <= 0;
        while (dout[DEBOUNCE_INST-1] != 0) begin
            @(negedge clk);
        end

        // allow for signals to propagate through pipeline
        for(i=0; i<DEBOUNCE_STAGES*2;i=i+1) begin
            @(negedge clk);
        end
        // assert outputs
        for(i=0; i<DEBOUNCE_INST;i=i+1) begin
            `assert(dout[i], 0);
        end

        // end test (if we did not assert)
        $finish();
    end
endmodule