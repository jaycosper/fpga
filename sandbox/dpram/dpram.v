/**
 * dual port RAM, independent read/write clocks
 */
module dpram
#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 4
)(
    input wrclk,                    // Write port posedge clock
    input wren,                     // Write port enable
    input [ADDR_WIDTH-1:0] wraddr,  // Write port address
    input [DATA_WIDTH-1:0] wrdata,  // Write port data

    input rdclk,                    // Read port posedge clock
    input [ADDR_WIDTH-1:0] rdaddr,  // Read port address
    output [DATA_WIDTH-1:0] rddata  // Read port dataout
);
    localparam RAM_SIZE = 2**ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] rddata;

    // Declare the RAM variable
    reg [DATA_WIDTH:0] dpram_array [0:RAM_SIZE-1];

    // Write port
    always @ (posedge wrclk)
    begin
        if (wren) begin
            dpram_array[wraddr] <= wrdata;
        end
    end

    // Read port
    always @ (posedge rdclk)
    begin
        rddata <= dpram_array[rdaddr];
    end

endmodule
