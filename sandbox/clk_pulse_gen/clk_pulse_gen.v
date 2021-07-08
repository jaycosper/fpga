// Clock pulse and edge detection generator
// Clock pulse if rounded to nearest log2 value
module clk_pulse_gen (
    input wire clk,         //! input clock
    input wire rst_n,       //! active-low asynchronous reset
    input wire data,        //! data for edge detection
    output reg clk_pulse,   //! clock pulse output, one clock-cycle wide
    output reg data_redge,  //! rising-edge detection pulse of data
    output reg data_fedge   //! falling-edge detection pulse of data
);
    //! Number of clock cycles per pulse
    parameter integer PULSE_CYCLE_COUNT = 1000;
    //! Calculate the size of the counter
    localparam PULSE_CNTR_WIDTH = $clog2(PULSE_CYCLE_COUNT);

    //! clock pulse counter
    reg [PULSE_CNTR_WIDTH-1:0] pulse_cntr;
    //! clocked in data
    reg data_q, data_qq;

    //! generate the clock pulse every 2^PULSE_CYCLE_COUNT clocks
    always@(posedge clk or negedge rst_n) begin : clk_pulse_gen
        if (!rst_n) begin
            pulse_cntr <= 0;
            clk_pulse <= 1'b0;
        end else begin
            // increment clock pulses
            pulse_cntr <= pulse_cntr + 1'b1;
            // set clock pulse when counter reset
            clk_pulse <= (pulse_cntr == 0) ? 1'b1 : 1'b0;
        end
    end

    //! Clocked edge detection
    always@(posedge clk or negedge rst_n) begin : clk_data
        if (!rst_n) begin
            data_q <= 1'b0;
            data_qq <= 1'b0;
        end else begin
            data_q <= data;
            data_qq <= data_q;
        end
    end

    //! Combinatorial edge-detection outputs
    always@(*) begin : edge_detect_gate
        // Rising edge detect
        data_redge = (data_q == 1'b1 && data_qq == 1'b0) ? 1'b1 : 1'b0;
        // Falling edge detect
        data_fedge = (data_q == 1'b0 && data_qq == 1'b1) ? 1'b1 : 1'b0;
    end

endmodule
