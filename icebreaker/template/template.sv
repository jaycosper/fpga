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
    // 7 segment control line bus
    wire [7:0] seven_segment;

    // Assign 7 segment control line bus to Pmod pins
    assign { P1A10, P1A9, P1A8, P1A7, P1A4, P1A3, P1A2, P1A1 } = seven_segment;

    // Display value register and increment bus
    reg [7:0] display_value = 0;
    reg [7:0] display_value_inc;

    // Clock divider and pulse registers
    reg [20:0] clkdiv = 0;
    reg clkdiv_pulse = 0;

    // lap counter
    reg [7:0] lap_value;
    reg [4:0] lap_timeout;
    logic running = 0;
    wire [7:0] display_out;

    // debounce
    logic BTN_N_q, BTN1_q, BTN2_q, BTN3_q;

    // edge detection
    logic BTN3_qq, BTN3_redge;

    //! deboucing array
    debounce #(.STAGES(2)) u_deb_btn_n  (.clk(CLK), .din(BTN_N), .dout(BTN_N_q) );
    debounce #(.STAGES(2)) u_deb_btn1_n (.clk(CLK), .din(BTN1),  .dout(BTN1_q)  );
    debounce #(.STAGES(2)) u_deb_btn2_n (.clk(CLK), .din(BTN2),  .dout(BTN2_q)  );
    debounce #(.STAGES(2)) u_deb_btn3_n (.clk(CLK), .din(BTN3),  .dout(BTN3_q)  );

    // Combinatorial logic
    assign LED1 = BTN1_q && BTN2_q;
    assign LED2 = BTN1_q && BTN3_q;
    assign LED3 = BTN2_q && BTN3_q;
    assign LED4 = !BTN_N_q;
    assign LED5 = BTN1_q || BTN2_q || BTN3_q;

    // rising edge detect on BTN3
    assign BTN3_redge = (BTN3_q == 1'b1 && BTN3_qq == 1'b0) ? 1'b1 : 1'b0;

    // Synchronous logic
    always_ff @(posedge CLK) begin: control
        if (!BTN_N_q) begin
            clkdiv <= 0;
            clkdiv_pulse <= 1;
            display_value <= 0;
            lap_value <= 0;
            lap_timeout <= 0;
        end else begin
            // Clock divider pulse generator
            if (clkdiv == 1200000) begin
                clkdiv <= 0;
                clkdiv_pulse <= 1;
            end else begin
                clkdiv <= clkdiv + 1;
                clkdiv_pulse <= 0;
            end

            // lap timer only works when running
            if (BTN2_q && running) begin
                lap_timeout <= 20;
                lap_value <= display_value;
            end

            // Start/stop timer on Button 3; Button 1 only stops timer
            BTN3_qq <= BTN3_q;
            if (BTN3_redge) begin
                running <= ~running;
            end else if (BTN1_q) begin
                running <= 0;
            end

            // Timer counter
            if (clkdiv_pulse) begin
                if (running) begin
                    if (lap_timeout != 0) begin
                        lap_timeout <= lap_timeout - 1;
                    end
                    display_value <= display_value_inc;
                end
            end
        end
    end

    assign display_out = (lap_timeout) ? lap_value : display_value;

    //! BCD incrementer
    bcd8_increment u_bcd8_increment (
        .din(display_value),
        .dout(display_value_inc)
    );

    //! 7 segment display control Pmod 1A
    seven_seg_ctrl u_seven_segment_ctrl (
        .CLK(CLK),
        .blank(lap_timeout[2]),
        .din(display_out),
        .dout(seven_segment)
    );

endmodule

//! Debouncer
//! This is some code
module debounce #(
    parameter STAGES = 3 //! number of debounce stages
)(
    input logic clk,    //! clock input
    input logic din,    //! data input
    output logic dout   //! debouced output
);
    logic [STAGES-1:0] pipe;

    always_ff@(posedge clk) begin
        // prime pipe
        pipe <= {pipe[STAGES-2:0], din};

        // output of pipe
        if(&pipe == 1'b1) dout <= 1'b1;
        else if(|pipe == 1'b0) dout <= 1'b0;
    end
endmodule

// BCD (Binary Coded Decimal) counter
module bcd8_increment (
    input logic [7:0] din,
    output logic [7:0] dout
);
    always_comb begin
        case (1'b1)
            din[7:0] == 8'h 99:
                dout = 0;
            din[3:0] == 4'h 9:
                dout = {din[7:4] + 4'd 1, 4'h 0};
            default:
                dout = {din[7:4], din[3:0] + 4'd 1};
        endcase
    end
endmodule

// Seven segment controller
// Switches quickly between the two parts of the display
// to create the illusion of both halves being illuminated
// at the same time.
module seven_seg_ctrl (
    input logic CLK,
    input logic [7:0] din,
    input logic blank,
    output logic [7:0] dout
);
    logic [6:0] lsb_digit;
    logic [6:0] msb_digit;

    seven_seg_hex msb_nibble (
        .din(din[7:4]),
        .blank(blank),
        .dout(msb_digit)
    );

    seven_seg_hex lsb_nibble (
        .din(din[3:0]),
        .blank(blank),
        .dout(lsb_digit)
    );

    logic [9:0] clkdiv = 0;
    logic clkdiv_pulse = 0;
    logic msb_not_lsb = 0;

    always_ff @(posedge CLK) begin
        clkdiv <= clkdiv + 1;
        clkdiv_pulse <= &clkdiv;
        msb_not_lsb <= msb_not_lsb ^ clkdiv_pulse;

        if (clkdiv_pulse) begin
            if (msb_not_lsb) begin
                dout[6:0] <= ~msb_digit;
                dout[7] <= 0;
            end else begin
                dout[6:0] <= ~lsb_digit;
                dout[7] <= 1;
            end
        end
    end
endmodule

// Convert 4bit numbers to 7 segments
module seven_seg_hex (
    input [3:0] din,
    input blank,
    output reg [6:0] dout
);
    always_comb
        if (blank) begin
            dout = 7'b 0000000;
        end else begin
            case (din)
                4'h0: dout = 7'b 0111111;
                4'h1: dout = 7'b 0000110;
                4'h2: dout = 7'b 1011011;
                4'h3: dout = 7'b 1001111;
                4'h4: dout = 7'b 1100110;
                4'h5: dout = 7'b 1101101;
                4'h6: dout = 7'b 1111101;
                4'h7: dout = 7'b 0000111;
                4'h8: dout = 7'b 1111111;
                4'h9: dout = 7'b 1101111;
                4'hA: dout = 7'b 1110111;
                4'hB: dout = 7'b 1111100;
                4'hC: dout = 7'b 0111001;
                4'hD: dout = 7'b 1011110;
                4'hE: dout = 7'b 1111001;
                4'hF: dout = 7'b 1110001;
                default: dout = 7'b 1000000;
            endcase
        end
endmodule
