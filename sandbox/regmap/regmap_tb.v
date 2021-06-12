`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module test_regmap;
    parameter TB_ADDR_WIDTH = 4;
    parameter TB_DATA_WIDTH = 8;

    parameter clock_period = 10;

    reg clk = 0;
    always #(clock_period/2) clk = !clk;

    integer i;

    reg rst_n = 1'b1;

    reg wren;
    reg [TB_ADDR_WIDTH-1:0] addr;
    reg [TB_DATA_WIDTH-1:0] wrdata;
    wire rdvalid;
    wire [TB_DATA_WIDTH-1:0] rddata;

    wire [TB_DATA_WIDTH-1:0] rw_reg0x00;
    reg  [TB_DATA_WIDTH-1:0] ro_reg0x01;
    wire [TB_DATA_WIDTH-1:0] rw_reg0x02;
    reg  [TB_DATA_WIDTH-1:0] ro_reg0x03;
    wire [TB_DATA_WIDTH-1:0] rw_reg0x04;
    reg  [TB_DATA_WIDTH-1:0] ro_reg0x05;
    wire [TB_DATA_WIDTH-1:0] rw_reg0x06;
    reg  [TB_DATA_WIDTH-1:0] ro_reg0x07;

    regmap #(
        .ADDR_WIDTH(TB_ADDR_WIDTH),
        .DATA_WIDTH(TB_DATA_WIDTH)
    ) u_regmap (
        .i_clk	(clk),
        .i_rst_n	(rst_n),
        .i_wren	(wren),
        .i_addr	(addr),
        .i_wrdata	(wrdata),
        .o_rdvalid (rdvalid),
        .o_rddata (rddata),
        .o_rw_reg0x00 (rw_reg0x00),
        .i_ro_reg0x01 (ro_reg0x01),
        .o_rw_reg0x02 (rw_reg0x02),
        .i_ro_reg0x03 (ro_reg0x03),
        .o_rw_reg0x04 (rw_reg0x04),
        .i_ro_reg0x05 (ro_reg0x05),
        .o_rw_reg0x06 (rw_reg0x06),
        .i_ro_reg0x07 (ro_reg0x07)
    );

    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, test_regmap);  // dump variable changes in the testbench
                                    // and all modules under it

        wren <= 0;
        addr <= 0;
        wrdata <= 0;
        ro_reg0x01 <= 'h11;
        ro_reg0x03 <= 'h33;
        ro_reg0x05 <= 'h55;
        ro_reg0x07 <= 'h77;

        $display("time\twren\taddr\twrdata\trdvalid\trddata");
        $monitor("%4g\t%b\t%h\t%h\t%h\t%h",
                $time, wren, addr, wrdata, rdvalid, rddata);

        // reset
        @(negedge clk);
        rst_n <= 1'b0;
        @(negedge clk);
        @(negedge clk);
        rst_n <= 1'b1;
        @(negedge clk);
        @(negedge clk);

        // Write to register map
        @(negedge clk);
        for (i = 0; i < 8; i++) begin
            wren <= 1;
            addr <= i;
            wrdata <= i;
            @(negedge clk);
        end

        @(negedge clk);
            wren <= 0;
            addr <= 'x;
            wrdata <= 'x;

        @(negedge clk);
            ro_reg0x03 <= 'h53;
            ro_reg0x05 <= 'h35;

        // Read from register map
        @(negedge clk);
        for (i = 7; i >= 0; i--) begin
            addr = i;
            @(negedge clk);
            //`assert(rddata, i);
        end

        $finish();
    end
endmodule