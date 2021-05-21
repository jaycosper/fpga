// Clock pulse and edge detection generator
// Clock pulse if rounded to nearest log2 value
module clk_pulse #(
    parameter PULSE_CYCLE_COUNT = 1000
)(
    input wire clk,
    input wire rst_n,
    input wire data,
    output reg clk_pulse,
    output reg data_redge,
    output reg data_fedge
);

    localparam PULSE_CNTR_WIDTH = $clog2(PULSE_CYCLE_COUNT);

    reg [PULSE_CNTR_WIDTH-1:0] pulse_cntr;
    reg data_q, data_qq;

    //function integer log2;
    //    input [31:0] value;
    //    for (log2=-1; value>0; log2=log2+1)
    //        value = value>>1;
    //endfunction

    always@(posedge clk or negedge rst_n) begin : clk_pulse_gen
        if (!rst_n) begin
            pulse_cntr <= 0;
            clk_pulse <= 1'b0;
        end else begin
            // count clock pulses
            pulse_cntr <= pulse_cntr + 1'b1;
            // set clock pulse when counter reset
            clk_pulse <= (pulse_cntr == 0) ? 1'b1 : 1'b0;
        end
    end

    // Edge detection
    always@(posedge clk or negedge rst_n) begin : clk_data
        if (!rst_n) begin
            data_q <= 1'b0;
            data_qq <= 1'b0;
        end else begin
            data_q <= data;
            data_qq <= data_q;
        end
    end

    always@(*) begin : edge_detect_gate
        // Rising edge detect
        data_redge <= (data_q == 1'b1 && data_qq == 1'b0) ? 1'b1 : 1'b0;
        // Falling edge detect
        data_fedge <= (data_q == 1'b0 && data_qq == 1'b1) ? 1'b1 : 1'b0;
    end

endmodule
