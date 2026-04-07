`timescale 1ns / 1ps
`default_nettype none

module tb_toggle_sync;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst   = 0;
    logic clk2  = 0;

    localparam lpDATA_WIDTH = 2;
    localparam lpSYNC_STAGES = 2;
    logic [lpDATA_WIDTH-1:0] din;
    logic [lpDATA_WIDTH-1:0] dout;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    toggle_sync #(
        .pDATA_WIDTH    (lpDATA_WIDTH),
        .pSYNC_STAGES   (lpSYNC_STAGES)
    ) dut (
        .i_clk          (clk),
        .i_rst          (rst),
        .i_din          (din),
        .i_clk2         (clk2),
        .o_dout         (dout)
    );

    // ────────────────────────────────────────────────
    // Clock generation
    // ────────────────────────────────────────────────
    localparam lpCLK_FREQ_MHZ = 250;
    localparam lpCLK_PERIOD_NS = 2 * 1000 / lpCLK_FREQ_MHZ;
    always #(lpCLK_PERIOD_NS/2) clk = ~clk;

    localparam lpCLK2_FREQ_MHZ = 50;
    localparam lpCLK2_PERIOD_NS = 2 * 1000 / lpCLK2_FREQ_MHZ;
    always #(lpCLK2_PERIOD_NS/2) clk2 = ~clk2;

    // Test timeout logic to prevent infinite simulation runs
    localparam int lpTB_TEST_TIMEOUT_NS = 100_000; // 100 microseconds
    int to_counter = 0;
    always_ff @(posedge clk) begin
        if (to_counter >= lpTB_TEST_TIMEOUT_NS) begin
            $display("%0t: ERROR! Testbench timeout reached. Ending simulation.", $time);
            $finish;
        end else begin
            to_counter += lpCLK_PERIOD_NS;
        end
    end

    // ────────────────────────────────────────────────
    // Reset & stimulus
    // ────────────────────────────────────────────────
    int test_errors = 0;
    int test_num = 0;
    int pulse_cycles = 1;

    initial begin
        $dumpfile("tb_toggle_sync.vcd");
        $dumpvars(0, tb_toggle_sync);

        // Reset phase
        rst = 1;
        repeat (10) @(negedge clk);
        rst = 0;
        repeat (10) @(negedge clk);

        $display("┌──────────────────────────────┐");
        $display("│   Starting self-check test   │");
        $display("└──────────────────────────────┘");

        test_num = 1;
        $display("Test %0d: Single pulse", test_num);

        pulse_cycles = 1;
        pulse_input(0, pulse_cycles);

        while (dout[0] !== 1'b1) @(negedge clk2); // wait for output to go high
        @(negedge clk2); // wait for output to go high
        if (dout[0] !== 1'b0) begin
            $display("%0t: ERROR! Expected output to be 0 after pulse but found %b", $time, dout[0]);
            test_errors++;
        end

        repeat (10) @(negedge clk);
        test_num = 2;
        $display("");
        $display("Test %0d: Single pulse train", test_num);

        pulse_cycles = 5;
        pulse_input(0, pulse_cycles);

        while (dout[0] !== 1'b1) @(negedge clk2); // wait for output to go high
        @(negedge clk2); // wait for output to go high
        if (dout[0] !== 1'b0) begin
            $display("%0t: ERROR! Expected output to be 0 after pulse but found %b", $time, dout[0]);
            test_errors++;
        end

        repeat (10) @(negedge clk);
        test_num = 3;
        $display("");
        $display("Test %0d: Multiple pulses", test_num);

        pulse_cycles = 1;
        for (int i=0; i<lpDATA_WIDTH; i++) begin
            pulse_input(i, pulse_cycles);

            while (dout[i] !== 1'b1) @(negedge clk2); // wait for output to go high
            @(negedge clk2); // wait for output to go high
            if (dout[i] !== 1'b0) begin
                $display("%0t: ERROR! Expected output %0d to be 0 after pulse but found %b", $time, i, dout[i]);
                test_errors++;
            end
        end

        repeat (10) @(negedge clk);
        test_num = 4;
        $display("");
        $display("Test %0d: Multiple staggered pulses", test_num);

        pulse_cycles = 1;
        for (int i=0; i<lpDATA_WIDTH; i++) begin
            pulse_input(i, pulse_cycles);
        end

        while (dout[lpDATA_WIDTH-1] !== 1'b1) @(negedge clk2); // wait for output to go high
        @(negedge clk2); // wait for output to go high
        if (dout[lpDATA_WIDTH-1] !== 1'b0) begin
            $display("%0t: ERROR! Expected output %0d to be 0 after pulse but found %b", $time, lpDATA_WIDTH-1, dout[lpDATA_WIDTH-1]);
            test_errors++;
        end

        // Final report
        $display("");
        $display("%d Test(s) completed at %0t", test_num, $time);
        $display("┌──────────────────────────────┐");
        if (test_errors == 0)
            $display("│       PASS ─ All checks OK   │");
        else
            $display("│       FAIL ─ %0d errors      │", test_errors);
        $display("└──────────────────────────────┘");

        #100;
        $finish;
    end

    // ────────────────────────────────────────────────
    // Self-checking logic
    // ────────────────────────────────────────────────
    function void pulse_input_single(int num);
        din[(lpDATA_WIDTH-1)'(num)] = 1'b1;
        @(negedge clk);
        din[(lpDATA_WIDTH-1)'(num)] = 1'b0;
    endfunction

    function void pulse_input(int num, int cycles);
        repeat (cycles) pulse_input_single(num);
    endfunction

endmodule

`default_nettype wire
