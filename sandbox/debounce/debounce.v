// Debouncer
module debounce #(
    parameter STAGES = 3
)(
    input wire clk,
    input wire rst_n,
    input wire din,
    output reg dout
);
    reg [STAGES-1:0] pipe;

    always@(posedge clk or negedge rst_n) begin : pipe_gen
        if (!rst_n) begin
            pipe <= 0;
            dout <= 1'b0;
        end else begin
            // prime pipe
            pipe <= {pipe[STAGES-2:0], din};

            // output of pipe
            if(&pipe == 1'b1) dout <= 1'b1;
            else if(|pipe == 1'b0) dout <= 1'b0;
        end
    end
endmodule