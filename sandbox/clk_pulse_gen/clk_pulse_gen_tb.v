`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module clk_pulse_gen_tb;

    // width of clk pulse counter
    localparam PULSE_CNTR_WIDTH_TB = 4;
    // number of debounce instances for test
    localparam CLK_PULSE_INST = 1;

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
    reg [PULSE_CNTR_WIDTH_TB-1:0] pulse_tc;

    // joined output signal
    wire [CLK_PULSE_INST-1:0] clk_pulse;
    wire [CLK_PULSE_INST-1:0] data_redge;
    wire [CLK_PULSE_INST-1:0] data_fedge;

    // generated instance variable
    genvar inst;
    // generate multiple debounce instances
    generate
        for(inst=0; inst<CLK_PULSE_INST; inst=inst+1)
            clk_pulse_gen #(
                .PULSE_CNTR_WIDTH(PULSE_CNTR_WIDTH_TB)
            ) u_clk_pulse_gen (
                .i_clk(clk),
                .i_rst_n(rst_n),
                .i_data(data),
                .i_pulse_tc(pulse_tc),
                .o_clk_pulse(clk_pulse),
                .o_data_redge(data_redge),
                .o_data_fedge(data_fedge)
            );
    endgenerate

    // start of test process
    initial begin
        // save file, and specify what to save
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, clk_pulse_gen_tb);  // dump variable changes in the testbench
                                    // and all modules under it

        // initial state of inputs
        pulse_tc <= 'h3;
        data <= 0;
        rst_n <= 1;

        // monitor signals of concern
        $display("time\tclk_pulse\tdata\tdata_redge\tdata_fedge");
        $monitor("%4g\t\t%b\t%b\t\t%b\t\t%b", $time, clk_pulse, data, data_redge, data_fedge);

        // reset device
        @(negedge clk);
            rst_n <= 0;
        @(negedge clk);
            rst_n <= 1;

        // flush debounce pipeline
        for(i=0; i<4;i=i+1) begin
            @(negedge clk);
        end

        data <= 1;
        while (data_redge != 1'b1) begin
            @(negedge clk);
        end
        `assert(data_redge, 1'b1);
        `assert(data_fedge, 1'b0);

        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        data <= 0;
        while (data_fedge != 1'b1) begin
            @(negedge clk);
        end
        `assert(data_redge, 1'b0);
        `assert(data_fedge, 1'b1);

        // end test (if we did not assert)
        $finish();
    end
endmodule