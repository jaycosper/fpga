`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module tb;

    localparam lpCLK_FREQ_MHZ = 50;
    localparam lpCLK_PERIOD_NS = 2 * 1000 / lpCLK_FREQ_MHZ;
    logic clk = 0;
    always #(lpCLK_PERIOD_NS/2) clk = ~clk;

    integer i;

    logic rst_n;
    wire out_sig;
    mini_lfsr dut (
        .i_clk      ( clk ),
        .i_rst_n    ( rst_n ),
        .o_output   ( out_sig )
    );

    initial begin
        $dumpfile("obj_dir/tb_mini_lfsr.vcd");  // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, dut);          // dump variable changes in the testbench and all modules under it

        rst_n = 0;

        $display("time\trst_n\toutput");
        $monitor("%4g\t%b\t%b",
                $time, rst_n, out_sig);

        // rst_n fifo
        @(negedge clk);
            rst_n = 0;
        @(negedge clk);
            rst_n = 1;

        repeat(100) @(negedge clk);

        $finish();
    end
endmodule