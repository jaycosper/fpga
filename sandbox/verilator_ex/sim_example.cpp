#include <stdlib.h>
#include "Vexample.h"
#include "verilated.h"

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    // Create an instance of our module under test
    Vexample *tb = new Vexample;
    //tb->opentrace("trace.vcd");

    // Tick the clock until we are done
    while(!Verilated::gotFinish()) {
        //tb->i_clk = 1;
        //tb->eval();
        //tb->i_clk = 0;
        tb->eval();
    } exit(EXIT_SUCCESS);
}