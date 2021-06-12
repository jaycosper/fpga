
/**
 * Register Map
 */
module regmap
#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input i_clk,                        // clock
    input i_rst_n,                      // active-low reset

    input i_wren,                       // Write enable
    input [ADDR_WIDTH-1:0] i_addr,      // i_address
    input [DATA_WIDTH-1:0] i_wrdata,    // Write data
    output o_rdvalid,                   // Read data valid
    output [DATA_WIDTH-1:0] o_rddata,   // Read dataout

    output [DATA_WIDTH-1:0] o_rw_reg0x00,   // register 0x00, RW
    input  [DATA_WIDTH-1:0] i_ro_reg0x01,   // register 0x01, RO
    output [DATA_WIDTH-1:0] o_rw_reg0x02,   // register 0x02, RW
    input  [DATA_WIDTH-1:0] i_ro_reg0x03,   // register 0x03, RO
    output [DATA_WIDTH-1:0] o_rw_reg0x04,   // register 0x04, RW
    input  [DATA_WIDTH-1:0] i_ro_reg0x05,   // register 0x05, RO
    output [DATA_WIDTH-1:0] o_rw_reg0x06,   // register 0x06, RW
    input  [DATA_WIDTH-1:0] i_ro_reg0x07    // register 0x07, RO
);
    parameter DEFAULT_REG_0x00 = 'hA5;
    parameter DEFAULT_REG_0x01 = 0; // N/A fo Read-only
    parameter DEFAULT_REG_0x02 = 'hFF;
    parameter DEFAULT_REG_0x03 = 0;
    parameter DEFAULT_REG_0x04 = 'h96;
    parameter DEFAULT_REG_0x05 = 0;
    parameter DEFAULT_REG_0x06 = 'h01;
    parameter DEFAULT_REG_0x07 = 0;

    // Register Map description (belongs in a packger/header)
    // actual number of registers supported, sequentially, from i_address 0x0
    localparam SUPPORTED_REG_SPACE = 8;
    localparam LOG2_REG_SPACE = $clog2(SUPPORTED_REG_SPACE);
    reg [0:SUPPORTED_REG_SPACE-1] rw_state;
    localparam RO_REGISTER = 1'b1;
    localparam RW_REGISTER = 1'b0;

    localparam ADDR_REG_0x00_DESC = 0;
    localparam ADDR_REG_0x01_DESC = 1;
    localparam ADDR_REG_0x02_DESC = 2;
    localparam ADDR_REG_0x03_DESC = 3;
    localparam ADDR_REG_0x04_DESC = 4;
    localparam ADDR_REG_0x05_DESC = 5;
    localparam ADDR_REG_0x06_DESC = 6;
    localparam ADDR_REG_0x07_DESC = 7;

    reg [DATA_WIDTH-1:0] o_rddata;
    reg o_rdvalid;

    // Declare the RAM variable
    reg[DATA_WIDTH-1:0] regmap_array [0:SUPPORTED_REG_SPACE-1];

    // Write port
    always @ (posedge i_clk)
    begin
        if (i_rst_n == 1'b0) begin
            rw_state = 0;
            rw_state[ADDR_REG_0x01_DESC] = RO_REGISTER;
            rw_state[ADDR_REG_0x03_DESC] = RO_REGISTER;
            rw_state[ADDR_REG_0x05_DESC] = RO_REGISTER;
            rw_state[ADDR_REG_0x07_DESC] = RO_REGISTER;
            regmap_array[ADDR_REG_0x00_DESC] <= DEFAULT_REG_0x00;
            regmap_array[ADDR_REG_0x01_DESC] <= DEFAULT_REG_0x01;
            regmap_array[ADDR_REG_0x02_DESC] <= DEFAULT_REG_0x02;
            regmap_array[ADDR_REG_0x03_DESC] <= DEFAULT_REG_0x03;
            regmap_array[ADDR_REG_0x04_DESC] <= DEFAULT_REG_0x04;
            regmap_array[ADDR_REG_0x05_DESC] <= DEFAULT_REG_0x05;
            regmap_array[ADDR_REG_0x06_DESC] <= DEFAULT_REG_0x06;
            regmap_array[ADDR_REG_0x07_DESC] <= DEFAULT_REG_0x07;
        end else begin
            // re-assign input RO registers
            regmap_array[ADDR_REG_0x01_DESC] <= i_ro_reg0x01;
            regmap_array[ADDR_REG_0x03_DESC] <= i_ro_reg0x03;
            regmap_array[ADDR_REG_0x05_DESC] <= i_ro_reg0x05;
            regmap_array[ADDR_REG_0x07_DESC] <= i_ro_reg0x07;
            // if writen enable
            if (i_wren) begin
                // check if this is a writable address
                if (rw_state[i_addr[LOG2_REG_SPACE-1:0]] == RW_REGISTER) begin
                    // if writable, do it
                    regmap_array[i_addr[LOG2_REG_SPACE-1:0]] <= i_wrdata;
                end
            end
        end
    end

    // read data -- currently always valid, but could be pipelined if required
    always @(regmap_array[ADDR_REG_0x00_DESC] or i_addr) begin
    //always @(*) begin
        o_rddata <= regmap_array[i_addr[LOG2_REG_SPACE-1:0]];
        o_rdvalid <= 1'b1;
    end

endmodule
