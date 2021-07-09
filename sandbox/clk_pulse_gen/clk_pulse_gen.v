// Clock pulse and edge detection generator
// Clock pulse can be tuned with terminal count (i_pulse_tc)
module clk_pulse_gen (
    input wire i_clk,           //! input clock
    input wire i_rst_n,         //! active-low asynchronous reset
    input wire [PULSE_CNTR_WIDTH-1:0] i_pulse_tc,   //! clk pulse terminal count
    input wire i_data,          //! data for edge detection
    output reg o_clk_pulse,     //! clock pulse output, one clock-cycle wide
    output reg o_data_redge,    //! rising-edge detection pulse of data
    output reg o_data_fedge     //! falling-edge detection pulse of data
);
    //! Calculate the size of the counter
    parameter PULSE_CNTR_WIDTH = 10;

    //! clock pulse counter
    reg [PULSE_CNTR_WIDTH-1:0] pulse_cntr;
    //! clocked in data
    reg data_q, data_qq;

    //! generate the clock pulse every 2^PULSE_CYCLE_COUNT clocks
    always@(posedge i_clk or negedge i_rst_n) begin : clk_pulse_gen
        if (!i_rst_n) begin
            pulse_cntr <= 0;
            o_clk_pulse <= 1'b0;
        end else begin
            o_clk_pulse <= 1'b0;
            if (pulse_cntr == i_pulse_tc) begin
                pulse_cntr <= 0;
                o_clk_pulse <= 1'b1;
            end else begin
                // increment clock pulses
                pulse_cntr <= pulse_cntr + 1'b1;
            end
        end
    end

    //! Clocked edge detection
    always@(posedge i_clk or negedge i_rst_n) begin : clk_data
        if (!i_rst_n) begin
            data_q <= 1'b0;
            data_qq <= 1'b0;
        end else begin
            data_q <= i_data;
            data_qq <= data_q;
        end
    end

    //! Combinatorial edge-detection outputs
    always@(*) begin : edge_detect_gate
        // Rising edge detect
        o_data_redge = (data_q == 1'b1 && data_qq == 1'b0) ? 1'b1 : 1'b0;
        // Falling edge detect
        o_data_fedge = (data_q == 1'b0 && data_qq == 1'b1) ? 1'b1 : 1'b0;
    end

endmodule
