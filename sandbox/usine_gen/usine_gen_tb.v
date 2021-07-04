`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module usine_gen_tb;

    parameter TB_SINE_WIDTH = 14;
    parameter TB_SINE_TABLE_SIZE = 5;

    reg clk = 0;
    always #5 clk = !clk;

    reg rst;
    reg rst_n;

    reg sine_en;
    reg [TB_SINE_TABLE_SIZE-1:0] freq_step;

    reg sweep_en;
    reg [TB_SINE_TABLE_SIZE-1:0] sweep_step;

    wire [TB_SINE_WIDTH-1:0] sine_out;

    usine_gen #(
        .SINE_WIDTH     (TB_SINE_WIDTH),
        .SINE_TABLE_SIZE(TB_SINE_TABLE_SIZE)
    ) u_usine_gen (

        .i_clk          ( clk ),
        .i_rst          ( rst ),
        .i_rst_n        ( 1'b1 ),

        .i_sine_en      ( sine_en ),
        .i_freq_step    ( freq_step ),

        .i_sweep_en     ( sweep_en ),
        .i_sweep_step   ( sweep_step ),

        .o_sine_out     ( sine_out )
    );

    integer testcase;
    integer i = 0;
    integer n = 0;

    localparam CYCLE_COUNT = 3*TB_SINE_TABLE_SIZE*TB_SINE_WIDTH;
    localparam TEST_COUNT = (2**TB_SINE_TABLE_SIZE)/4;

    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, usine_gen_tb); // dump variable changes in the testbench
                                    // and all modules under it

        $display("time\trst\tsine_en\tfreq_step\tsweep_en\tsweep_step\tsine_out");
        $monitor("%4g\t%b\t%x\t%x\t%x\t%x\t%x",
                $time, rst, sine_en, freq_step, sweep_en, sweep_step, sine_out);

        // testcase #0 : reset
        testcase = 0;
        sine_en <= 1'b1;
        freq_step <= 1;
        sweep_en <= 1'b0;
        sweep_step <= 1;
        @(negedge clk);
        @(negedge clk);
        rst = 1;
        @(negedge clk);
        rst = 0;

        // testcases
        for (i = 0; i < TEST_COUNT; i++) begin
            // testcase number
            testcase = i+1;
            // set sine freq step
            freq_step <= testcase;
            for (n = 0; n < CYCLE_COUNT; n++) begin
                @(negedge clk);
            end
        end

        $finish();

    end
endmodule