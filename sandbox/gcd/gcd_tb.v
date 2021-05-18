`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module gcd_tb;
    parameter TB_DATA_WIDTH = 9;

    reg clk = 0;
    reg reset;

    reg enable;
    reg [TB_DATA_WIDTH-1:0] a;
    reg [TB_DATA_WIDTH-1:0] b;

    wire valid;
    wire [TB_DATA_WIDTH-1:0] y;

    always #5 clk = !clk;

    gcd #(
        .DATA_WIDTH(TB_DATA_WIDTH)
    ) u_gcd (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .a(a),
        .b(b),
        .valid(valid),
        .y(y)
    );

    integer i;
    reg [TB_DATA_WIDTH-1:0] ans;
    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, gcd_tb);       // dump variable changes in the testbench
                                    // and all modules under it

        $monitor("t=%-4d: a = %d, b = %d, y = %d", $time, a, b, y);

        reset = 1; enable = 0;
        @(negedge clk);
        reset = 0;

        // testcase #1
        i = 1;
        a <= 9;
        b <= 27;
        ans <= 9;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        // testcase #2
        i = 2;
        a <= 49;
        b <= 21;
        ans <= 7;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        // testcase #3
        i = 3;
        a <= 40;
        b <= 40;
        ans <= 40;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        // testcase #4
        i = 4;
        a <= 250;
        b <= 190;
        ans <= 10;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        // testcase #5
        i = 5;
        a <= 250;
        b <= 5;
        ans <= 5;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        // testcase #6
        i = 6;
        a <= 19;
        b <= 27;
        ans <= 1;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        // testcase #7
        i = 7;
        a <= 25;
        b <= 30;
        ans <= 5;
        enable = 1;
        @(negedge clk);
        enable = 0;

        while (!valid) begin
            @(negedge clk);
        end
        `assert(y, ans);

        $finish();

    end
endmodule