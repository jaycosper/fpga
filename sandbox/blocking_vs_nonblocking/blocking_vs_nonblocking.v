// yosys -p "prep -top blocking_vs_nonblocking -flatten; write_json output.json" blocking_vs_nonblocking.v
// blocking comb
module blocking_vs_nonblocking (
    input wire clk,         //! input clock
    input wire rst_n,       //! active-low asynchronous reset
    input wire [2:0] a1,
    output reg y1,
    input wire [2:0] a2,
    output reg y2,
    input wire [2:0] a3,
    output reg y3,
    input wire [2:0] a4,
    output reg y4
);
    reg m1, m2, m3, m4;

    // blocking combinatorial
    always@(*) begin
        // increment clock pulses
        m1 = a1[0] & a1[1];
        y1 = m1 | a1[2];
    end
    // non-blocking combinatorial
    always@(*) begin
        // increment clock pulses
        m2 <= a2[0] & a2[1];
        y2 <= m2 | a2[2];
    end
    // blocking sequential
    always@(posedge clk) begin
        // increment clock pulses
        m3 = a3[0] & a3[1];
        y3 = m3 | a3[2];
    end
    // non-blocking sequential
    always@(posedge clk) begin
        // increment clock pulses
        m4 <= a4[0] & a4[1];
        y4 <= m4 | a4[2];
    end

endmodule
