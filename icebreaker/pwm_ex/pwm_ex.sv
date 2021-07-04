// SystemVerilog version
// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

// Project entry point
module top (
    input  CLK, // 12MHz osc
    input  BTN_N, BTN1, BTN2, BTN3,
    output LED1, LED2, LED3, LED4, LED5,
    output P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10
);
    localparam  WB_DATA_WIDTH   = 8;
    localparam  PWM_WIDTH       = 8;
    localparam  PWM_RATE_WIDTH  = 4;

    // Clock divider and pulse registers
    reg [20:0] clkdiv = 0;
    reg clkdiv_pulse = 0;

    // debounce
    logic BTN_N_q, BTN1_q, BTN2_q, BTN3_q;

    //! deboucing array
    debounce #(.STAGES(2)) u_deb_btn_n  (.clk(CLK), .rst_n(1'b1),     .din(BTN_N), .dout(BTN_N_q) );
    debounce #(.STAGES(2)) u_deb_btn1_n (.clk(CLK), .rst_n(sysrst_n), .din(BTN1),  .dout(BTN1_q)  );
    debounce #(.STAGES(2)) u_deb_btn2_n (.clk(CLK), .rst_n(sysrst_n), .din(BTN2),  .dout(BTN2_q)  );
    debounce #(.STAGES(2)) u_deb_btn3_n (.clk(CLK), .rst_n(sysrst_n), .din(BTN3),  .dout(BTN3_q)  );

    // Combinatorial logic
    assign LED1 = BTN1_q && BTN2_q;
    assign LED2 = BTN1_q && BTN3_q;
    assign LED3 = BTN2_q && BTN3_q;
    assign LED4 = !sysrst_n; //!BTN_N_q;
    assign LED5 = BTN1_q || BTN2_q || BTN3_q;

    // power-on reset
    localparam RESET_PIPE_DEPTH = 8;
    integer i;
    logic [RESET_PIPE_DEPTH-1:0] rst_n_pipe = 0;
    logic sysrst_n;
    always_ff @(posedge CLK) begin: rst_n_pipe
        rst_n_pipe[0] <= 1'b1;
        for (i=1; i<RESET_PIPE_DEPTH; i++) begin
            rst_n_pipe[i] <= rst_n_pipe[i-1];
        end
    end

    assign sysrst_n = &rst_n_pipe && BTN_N_q;

    // Multirate generator
    // 12MHz osc / RATE = 12e6 / 272 = ~44kHz
    localparam CLK_PULSE_RATE = 272;
    always_ff @(posedge CLK) begin: control
        if (!sysrst_n) begin
            clkdiv <= 0;
            clkdiv_pulse <= 0;
        end else begin
            // Clock divider pulse generator
            if (clkdiv >= CLK_PULSE_RATE) begin
                clkdiv <= 0;
                clkdiv_pulse <= 1;
            end else begin
                clkdiv <= clkdiv + 1;
                clkdiv_pulse <= 0;
            end
        end
    end

    // blinky
    logic led = 0;
    always_ff @(posedge CLK) begin: control
        if (!sysrst_n) begin
            led <= 1;
        end else begin
            // led strobe
            if (clkdiv_pulse) begin
                led <= !led;
            end
        end
    end

    // Waveform generation
    localparam  SINE_WIDTH = 14;
    localparam  SINE_TABLE_SIZE = 5;

    logic [SINE_TABLE_SIZE-1:0] freq_step = 1;
    logic [SINE_TABLE_SIZE-1:0] sweep_step = 0;
    logic [SINE_WIDTH-1:0] sine_out;

    usine_gen #(
        .SINE_WIDTH         ( SINE_WIDTH        ),
        .SINE_TABLE_SIZE    ( SINE_TABLE_SIZE   )
    ) u_usine_gen (
        .i_clk          ( CLK           ),
        .i_rst          ( 1'b0          ),
        .i_rst_n        ( sysrst_n      ),
        .i_sine_en      ( clkdiv_pulse  ),
        .i_freq_step    ( freq_step     ),
        .i_sweep_en     ( 1'b0          ),
        .i_sweep_step   ( sweep_step    ),
        .o_sine_out     ( sine_out      )
    );

    logic [PWM_WIDTH-1:0] pwm_setpoint;
    assign pwm_setpoint = sine_out[SINE_WIDTH-1:SINE_WIDTH-PWM_WIDTH];

    logic wb_stb = 0;
    logic wb_we = 0;
    logic wb_addr = 0;
    logic [WB_DATA_WIDTH-1:0] wb_wrdata = 0;

    logic wb_ack;
    logic [WB_DATA_WIDTH-1:0] wb_rddata;

    logic pwm_out;

    pwm_gen #(
        .WB_DATA_WIDTH  ( WB_DATA_WIDTH  ),
        .PWM_WIDTH      ( PWM_WIDTH      ),
        .PWM_RATE_WIDTH ( PWM_RATE_WIDTH )
    ) u_pwm_gen (
        .i_clk          ( CLK           ),
        .i_rst          ( 1'b0          ),
        .i_rst_n        ( sysrst_n      ),
        .i_wb_stb       ( wb_stb        ),
        .i_wb_we        ( wb_we         ),
        .i_wb_addr      ( wb_addr       ),
        .i_wb_wrdata    ( wb_wrdata     ),
        .o_wb_ack       ( wb_ack        ),
        .o_wb_rddata    ( wb_rddata     ),
        .i_pwm_setpoint ( pwm_setpoint  ),
        .o_pwm_out      ( pwm_out       )
    );

    assign P1A1 = pwm_out;  // Audio In
    assign P1A2 = 1'b0;     // GAIN
    assign P1A3 = led;      // N/C
    assign P1A4 = 1'b1;     // SHUTn

endmodule
