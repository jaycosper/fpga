`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module test_counter;
    parameter TB_CNTR_WIDTH = 3;
    reg clk;
    always #5 clk = !clk;

    reg clr, en;
    wire [TB_CNTR_WIDTH-1:0] cnt;
    counter #(
        .CNTR_WIDTH(TB_CNTR_WIDTH)
    ) counter_0 (
        .clk(clk),
        .clr(clr),
        .en(en),
        .cnt(cnt)
    );

    integer i;
    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, test_counter); // dump variable changes in the testbench
                                    // and all modules under it

        $monitor("t=%-4d: cnt = %d", $time, cnt);

        clk = 0; clr = 1; en = 0;
        @(negedge clk);
        clr = 0; en = 1;

        for (i = 0; i < 2*2**(TB_CNTR_WIDTH); i = i + 1) begin
            @(negedge clk);
        end

        $finish();
    end
endmodule