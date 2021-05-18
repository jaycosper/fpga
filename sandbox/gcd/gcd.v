/**
 * Greatest Common Divisor (GCD)
 * Reference: https://www.fpga4fun.com/files/vhdlvlogcompared.pdf
 */
module gcd
#(
    parameter DATA_WIDTH = 8
)(
    input  clk,                 // posedge clock
    input  reset,               // synchronous reset
    input  enable,              // enable: high when "A" and "B" valid, one clock cycle, wait to output valid to start next GCD
    input [DATA_WIDTH-1:0] a,   // value "A"
    input [DATA_WIDTH-1:0] b,   // value "B"
    output valid,               // output "Y" valid, high until new values clocked in
    output [DATA_WIDTH-1:0] y   // output value "Y", answer for GCD
);
    wire clk;
    wire reset;
    wire enable;
    wire [DATA_WIDTH-1:0] a;
    wire [DATA_WIDTH-1:0] b;
    reg valid;
    reg [DATA_WIDTH-1:0] y;

    reg [DATA_WIDTH-1:0] a_int, b_int;
    reg [DATA_WIDTH-1:0] a_next, b_next;
    reg reg_a, reg_b;

    reg calc_complete;

    always@(posedge clk) begin : main_clocking
        if (reset) begin
            a_int <= 0;
            b_int <= 0;
            valid <= 0;
        end else begin
            calc_complete = (a_int == 0 || b_int == 0) ? 1 : 0;
            if (enable) begin
                // register input, start calculation
                a_int <= a;
                b_int <= b;
                valid <= 0;
            end else begin
                // normal processing
                if (reg_a) begin
                    a_int <= a_next;
                end
                if (reg_b) begin
                    b_int <= b_next;
                end
                if (calc_complete) begin
                    valid <= 1;
                    y <= a_next;
                end
            end
        end
    end

    always@(*) begin : sub_or_swap
        reg_a <= 0;
        reg_b <= 0;

        if (a_int >= b_int) begin
            // subtract
            a_next <= a_int - b_int;
            reg_a <= 1;
        end else begin
            // swap
            a_next <= b_int;
            b_next <= a_int;
            reg_a <= 1;
            reg_b <= 1;
        end

    end

    //always_comb @(*) begin
    //    calc_complete <= 0;
    //    if (a_int == 0 || b_int == 0) begin
    //        calc_complete <= 1;
    //    end
    //end

endmodule
