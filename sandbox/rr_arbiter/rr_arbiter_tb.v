`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module rr_arbiter_tb;
    localparam ADDR_WIDTH_TB = 12;
    localparam DATA_WIDTH_TB = 8;
    localparam WD_TIMER_WIDTH_TB = 6;

    // clock period (1ns * 10 = 10ns; 100MHz)
    localparam clock_period = 10;

    // clock generator
    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    // generic integer using in FOR loops
    integer i;
    reg allow_checks = 0;

    // input signals
    reg reset;
    reg control;

    // output signals
    reg reqA;
    wire ackA;
    reg [ADDR_WIDTH_TB-1:0] addressA;
    reg [DATA_WIDTH_TB-1:0] wrdataA;
    wire [DATA_WIDTH_TB-1:0] rddataA;
    reg rdWrnA;

    reg reqB;
    wire ackB;
    reg [ADDR_WIDTH_TB-1:0] addressB;
    reg [DATA_WIDTH_TB-1:0] wrdataB;
    wire [DATA_WIDTH_TB-1:0] rddataB;
    reg rdWrnB;

    reg reqC;
    wire ackC;
    reg [ADDR_WIDTH_TB-1:0] addressC;
    reg [DATA_WIDTH_TB-1:0] wrdataC;
    wire [DATA_WIDTH_TB-1:0] rddataC;
    reg rdWrnC;

    reg [ADDR_WIDTH_TB-1:0] address;
    reg [DATA_WIDTH_TB-1:0] wrdata;
    wire [DATA_WIDTH_TB-1:0] rddata;

    // instances under test
    rr_arbiter
    #(
        .ADDR_WIDTH     ( ADDR_WIDTH_TB     ),
        .DATA_WIDTH     ( DATA_WIDTH_TB     ),
        .WD_TIMER_WIDTH ( WD_TIMER_WIDTH_TB )
    ) u_rr_arbiter
    (
        .clk        ( clk      ),
        .reset      ( reset    ),
        .reqA       ( reqA     ),
        .ackA       ( ackA     ),
        .addressA   ( addressA ),
        .wrdataA    ( wrdataA  ),
        .rddataA    ( rddataA  ),
        .rdWrnA     ( rdWrnA   ),
        .reqB       ( reqB     ),
        .ackB       ( ackB     ),
        .addressB   ( addressB ),
        .wrdataB    ( wrdataB  ),
        .rddataB    ( rddataB  ),
        .rdWrnB     ( rdWrnB   ),
        .reqC       ( reqC     ),
        .ackC       ( ackC     ),
        .addressC   ( addressC ),
        .wrdataC    ( wrdataC  ),
        .rddataC    ( rddataC  ),
        .rdWrnC     ( rdWrnC   ),
        .address    ( address  ),
        .wrdata     ( wrdata   ),
        .rddata     ( rddata   )
    );

    // start of test process
    initial begin
        // save file, and specify what to save
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, rr_arbiter_tb);  // dump variable changes in the testbench
                                    // and all modules under it

        // initial state of inputs
        reset <= 0;
        reqA <= 0;
        reqB <= 0;
        reqC <= 0;

        // monitor signals of concern
        $display("time\treqA\tackA\treqB\tackB\treqC\tackC");
        $monitor("%4g\t%b\t%b\t%b\t%b\t%b\t%b", $time, reqA, ackA, reqB, ackB, reqC, ackC);

        // reset device
        @(negedge clk);
            reset <= 1;
        @(negedge clk);
            reset <= 0;

        // intro clocks
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        reqA <= 1;
        while(!ackA) begin
            @(negedge clk);
        end

        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        reqA <= 0;

        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        // end test (if we did not assert)
        $finish();
    end

endmodule