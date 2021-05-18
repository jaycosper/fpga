/**
 * 4-bit counter
 */
module counter
#(
    parameter CNTR_WIDTH = 4
)(
    input  clk,      // posedge clock
    input  clr,      // synchronous clear
    input  en,       // enable: if high, increment counter
    output [CNTR_WIDTH-1:0] cnt // counter value
);
    reg [CNTR_WIDTH-1:0] cnt_reg, cnt_next;
    assign cnt = cnt_reg;
    always @(*) begin
        cnt_next = cnt_reg;
        if (clr) begin
            cnt_next = 0;
        end else if (en) begin
            cnt_next = cnt_reg + 1;
        end
    end
    always @(posedge clk) begin
        cnt_reg <= cnt_next;
    end
endmodule
