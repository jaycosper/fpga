`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module pwm_gen_tb;

    localparam  TB_WB_DATA_WIDTH = 8;
    localparam  TB_PWM_WIDTH = 4;
    localparam  TB_PWM_RATE_WIDTH = 1;

    reg clk = 0;
    always #5 clk = !clk;

    reg rst;
    reg rst_n;

    reg wb_stb;
    reg wb_we;
    reg wb_addr;
    reg [TB_WB_DATA_WIDTH-1:0] wb_wrdata;

    wire wb_ack;
    wire [TB_WB_DATA_WIDTH-1:0] wb_rddata;
    reg [TB_PWM_WIDTH-1:0] pwm_setpoint;
    wire pwm_out;

    pwm_gen #(
        .WB_DATA_WIDTH  ( TB_WB_DATA_WIDTH  ),
        .PWM_WIDTH      ( TB_PWM_WIDTH      ),
        .PWM_RATE_WIDTH ( TB_PWM_RATE_WIDTH )
    ) u_pwm_gen (
        .i_clk          ( clk           ),
        .i_rst          ( rst           ),
        .i_rst_n        ( rst_n         ),
        .i_wb_stb       ( wb_stb        ),
        .i_wb_we        ( wb_we         ),
        .i_wb_addr      ( wb_addr       ),
        .i_wb_wrdata    ( wb_wrdata     ),
        .o_wb_ack       ( wb_ack        ),
        .o_wb_rddata    ( wb_rddata     ),
        .i_pwm_setpoint ( pwm_setpoint  ),
        .o_pwm_out      ( pwm_out       )
    );

    localparam TEST_LOOPS = 100;
    integer testcase;
    integer i = 0;
    integer n = 0;

    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, pwm_gen_tb);       // dump variable changes in the testbench
                                    // and all modules under it

        $display("time\trst\twb_stb\twb_we\twb_addr\twb_wrdata\twb_ack\twb_rddata\tpwm_out");
        $monitor("%4g\t%b\t%b\t%b\t%x\t%x\t\t%b\t%x\t\t%b",
                $time, rst, wb_stb, wb_we, wb_addr, wb_wrdata, wb_ack, wb_rddata, pwm_out);

        // testcase #0 : reset
        testcase = 0;
        wb_stb <= 1'b0;
        wb_we <= 1'b0;
        wb_addr <= 0;
        wb_wrdata <= 0;
        pwm_setpoint <= {TB_PWM_WIDTH{1'b1}}>>1; // 50%
        rst_n = 0;

        @(negedge clk);
        @(negedge clk);
        rst = 1;
        rst_n = 1;
        @(negedge clk);
        rst = 0;

        // testcases
        for (i = 0; i < TEST_LOOPS; i++) begin
            // testcase number
            testcase = i+1;
            @(negedge clk);
        end

        $finish();

    end
endmodule