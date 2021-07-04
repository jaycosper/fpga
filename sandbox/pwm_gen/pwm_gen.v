/**
 * Sine wave generator
**/

module pwm_gen
#(
    parameter WB_DATA_WIDTH = 8,
    parameter PWM_WIDTH = 8,
    parameter PWM_RATE_WIDTH = 8
)(
    input i_clk,
    input i_rst,
    input i_rst_n,

    input i_wb_stb,
    input i_wb_we,
    input i_wb_addr,
    input [WB_DATA_WIDTH-1:0] i_wb_wrdata,

    output o_wb_ack,
    output [WB_DATA_WIDTH-1:0] o_wb_rddata,

    input [PWM_WIDTH-1:0] i_pwm_setpoint,
    output o_pwm_out
);
    reg o_wb_ack;

    reg [PWM_WIDTH-1:0] r_reload_value;
    reg [WB_DATA_WIDTH-1:0] o_wb_rddata;
    wire o_pwm_out;

    wire sysrst;
    assign sysrst = i_rst | !i_rst_n;

    always @(posedge i_clk) begin : WB_HANDLER // Data write
        if (sysrst) begin
            r_reload_value <= {PWM_WIDTH{1'b1}};
            o_wb_ack <= 1'b0;
            o_wb_rddata <= 0;
        end else begin
            o_wb_rddata <= 0;
            if ((i_wb_stb)&&(i_wb_addr)) begin
                if (i_wb_we) r_reload_value <= i_wb_wrdata[(PWM_WIDTH-1):0];
                else o_wb_rddata[(PWM_WIDTH-1):0] <= r_reload_value;
            end
            o_wb_ack <= i_wb_stb;
        end
    end

    reg [PWM_RATE_WIDTH-1:0] r_pulse_rate;
    always @(posedge i_clk) begin : MULTI_RATE
        if (sysrst) begin
            r_pulse_rate <= 0;
        end else begin
            r_pulse_rate <= r_pulse_rate + 1'b1;
        end
    end

    reg [PWM_WIDTH-1:0] r_pwm_cntr;
    reg [PWM_WIDTH-1:0] r_pwm_setpoint;
    always @(posedge i_clk) begin : PWM_GEN
        if (sysrst) begin
            r_pwm_cntr <= 0;
            r_pwm_setpoint <= {PWM_WIDTH{1'b1}}>>1; // 50%
        end else begin
            if (r_pulse_rate == 0) begin
                r_pwm_setpoint <= i_pwm_setpoint;
                if (r_pwm_cntr >= r_reload_value) begin
                    r_pwm_cntr <= 0;
                end else begin
                    r_pwm_cntr <= r_pwm_cntr + 1'b1;
                end
            end
        end
    end

    assign o_pwm_out = (r_pwm_cntr>r_pwm_setpoint);

endmodule
