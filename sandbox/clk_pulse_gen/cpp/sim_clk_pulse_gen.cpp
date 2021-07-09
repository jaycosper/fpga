//#include <stdlib.h>
#include "Vclk_pulse_gen.h"
#include "verilated.h"
#include "tb_template.h"
#include "tb_clk_pulse_gen.h"

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    MODULE_TB *tb = new MODULE_TB();

    tb->opentrace("clk_pulse_gen_trace.vcd");

    // reset DUT
    tb->reset();
    tb->setTC(0x3);
    // Tick the clock until we are done
    while(!tb->done())
    {
        tb->tick();
    } exit(EXIT_SUCCESS);
}