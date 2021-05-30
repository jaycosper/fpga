`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module assert(input clk, input test);
    always @(posedge clk)
    begin
        if (test !== 1)
        begin
            $display("ASSERTION FAILED in %m");
            $finish;
        end
    end
endmodule
`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module test_dpram;
    parameter TB_ADDR_WIDTH = 4;
    parameter TB_DATA_WIDTH = 4;

    parameter wr_clock_period = 10;
    parameter rd_clock_period = 24;

    reg wrclk = 0;
    always #(wr_clock_period/2) wrclk = !wrclk;

    reg rdclk = 0;
    always #(rd_clock_period/2) rdclk = !rdclk;

    integer i;

    reg wren;
    reg [TB_ADDR_WIDTH-1:0] wraddr;
    reg [TB_DATA_WIDTH-1:0] wrdata;

    reg [TB_ADDR_WIDTH-1:0] rdaddr;
    wire [TB_DATA_WIDTH-1:0] rddata;

    dpram #(
        .ADDR_WIDTH(TB_ADDR_WIDTH),
        .DATA_WIDTH(TB_DATA_WIDTH)
    ) u_dpram (
        .wrclk	(wrclk),
        .wren	(wren),
        .wraddr	(wraddr),
        .wrdata	(wrdata),
        .rdclk	(rdclk),
        .rdaddr	(rdaddr),
        .rddata (rddata)
    );

    initial begin
        $dumpfile("wave.vcd");      // create a VCD waveform dump called "wave.vcd"
        $dumpvars(0, test_dpram);  // dump variable changes in the testbench
                                    // and all modules under it

        wren <= 0;
        wraddr <= 0;
        wrdata <= 0;
        rdaddr <= 0;

        $display("time\twren\twraddr\twrdata\trdaddr\trddata");
        $monitor("%4g\t%b\t%h\t%h\t%h\t%h",
                $time, wren, wraddr, wrdata, rdaddr, rddata);

        // Write to RAM
        @(negedge wrclk);
        for (i = 0; i < 8; i++) begin
            wren <= 1;
            wraddr <= i;
            wrdata <= i;
            @(negedge wrclk);
        end

        @(negedge wrclk);
            wren <= 0;
            wraddr <= 'x;
            wrdata <= 'x;

        @(negedge rdclk);
        for (i = 7; i >= 0; i--) begin
            rdaddr = i;
            @(negedge rdclk);
            `assert(rddata, i);
        end

        $finish();
    end
endmodule