// yosys -p "prep -top blocking_vs_nonblocking_forloop -flatten; write_json output.json" blocking_vs_nonblocking_forloop .v
module blocking_vs_nonblocking_forloop (
    input wire clk,         //! input clock
    input wire rst_n,       //! active-low asynchronous reset
    input wire data,
    output reg [3:0]yA_up, yA_down,
    output reg [3:0]yB,
);
    reg [3:0] pipeA1, pipeA2, pipeB;
    integer N, M, P;

    always@(posedge clk)
    begin: BLOCKING_FOR
        for(P=1; P<=3; P=P+1)
            pipeA1[P] = pipeA1[P-1];
        pipeA1[0] = data;
        yA_up = pipeA1;
    end

    always@(posedge clk)
    begin: BLOCKING_FOR
        for(N=3; N>=1; N=N-1)
            pipeA2[N] = pipeA2[N-1];
        pipeA2[0] = data;
        yA_down = pipeA2;
    end

    always@(posedge clk)
    begin: NON_BLOCKING_FOR
        for (M=3; M>=1; M=M-1)
            pipeB[M] <= pipeB[M-1];

        pipeB[0] <= data;
        yB <= pipeB;
    end

endmodule
