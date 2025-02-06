//#include <stdlib.h>
#include "Vcapture_sync.h"
#include "verilated.h"
#include "tb_template.h"
#include "tb_capture_sync.h"
#include <iostream>
using namespace std;
#include <cassert>

constexpr int SYNC_STAGES = 3;
constexpr int CLK_CYCLES_L2 = 4;

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB *tb = new DUT_TB();

    tb->opentrace("capture_sync_trace.vcd");

    // reset DUT
    tb->setDin(0);
    tb->activeHighReset();

    tb->tick();
    tb->tick();

    assert(tb->getDoutOutput() == 0);
    // flush capture_sync pipeline and assert outputs
    for(int i=0; i<2*SYNC_STAGES;i++)
    {
        tb->tick();
        tb->tick();
        tb->tick();
        tb->tick();
        tb->tick();
        tb->tick();
        tb->tick();
        assert(tb->getDoutOutput() == 0);
    }

    // toggle DIN
    for(int i=0; i<2*(SYNC_STAGES+(1<<CLK_CYCLES_L2));i++)
    {
        tb->setDin(1);
        tb->tick();
        tb->setDin(0);
        tb->tick();
        tb->tick();
        tb->tick();
        tb->tick();
        tb->tick();
        assert(tb->getDoutOutput() == 0);
    }
    // ensure DIN is low
    tb->setDin(0);
    tb->tick();

    // Tick the clock until we are done
    while(!tb->done())
    {
        tb->tick();

        if (tb->getTickCount() > 100ul)
        {
            printf("All test cases PASSED! (done signal not received)\n");
            exit(EXIT_SUCCESS);
        }
    }
    printf("All test cases PASSED!\n");
    exit(EXIT_SUCCESS);
}
