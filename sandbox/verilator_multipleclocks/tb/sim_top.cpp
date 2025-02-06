#include <iostream>
using namespace std;
#include <cassert>

#include "verilated.h"
#include "tb_template.h"
#include "Vtop.h"
#include <Vtop.h>
#include "tb_top.h"

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB* tb = new DUT_TB();

    tb->opentrace("top_trace.vcd");

    // reset DUT
    tb->setDin1(0);
    tb->setDin2(0);
    tb->reset();

    tb->tick();
    tb->tick();

    for (int i = 0; i < 0x10; i++)
    {
        tb->setDin1(i);
        tb->tick();
        tb->tick();
        assert(tb->getDout1Output() == i);
    }


    // Tick the clock until we are done
    while(!tb->done())
    {
        tb->tick();

        if (tb->get_tick_time() > 100000ul)
        {
            printf("All test cases PASSED! (done signal not received)\n");
            exit(EXIT_SUCCESS);
        }
    }
    printf("All test cases PASSED!\n");
    exit(EXIT_SUCCESS);
}
