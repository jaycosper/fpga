//#include <stdlib.h>
#include "Vfifosc.h"
#include "verilated.h"
#include "tb_template.h"
#include "tb_fifosc.h"
#include <iostream>
using namespace std;
#include <cassert>

constexpr int FIFO_DEPTH = 4;

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB *tb = new DUT_TB();
    int testcase = 0;

    tb->opentrace("fifosc_trace.vcd");

    // reset DUT
    tb->setDin(0);
    tb->setInsert(0);
    tb->setFlush(0);
    tb->setRemove(0);

    tb->tick();
    tb->tick();

    tb->resetDUT();

    tb->tick();
    tb->tick();

    testcase++;
    printf("Test Case #%d: Initial state...\n", testcase);
    assert(tb->getEmpty() == 1);
    assert(tb->getFull() == 0);
    printf("passed!\n");

    testcase++;
    printf("Test Case #%d: Fill FIFO...\n", testcase);
    // flush debounce pipeline and assert outputs
    int i = 0;
    do
    {
        tb->setDin(i);
        tb->setInsert(1);
        tb->tick();
        i++;
    } while (tb->getFull() != 1);

    tb->setDin(0xF);
    tb->setInsert(0);
    assert(tb->getEmpty() == 0);
    assert(tb->getFull() == 1);
    assert(i == 7);

    // first pushed value should be on output
    assert(tb->getDout() == 0);
    printf("passed!\n");

    testcase++;
    printf("Test Case #%d: Drain FIFO...\n", testcase);
    i = 0;
    do
    {
        tb->setRemove(1);
        tb->tick();
        assert(tb->getDout() == i);
        i++;
    } while (tb->getEmpty() != 1);

    assert(tb->getEmpty() == 1);
    assert(tb->getFull() == 0);
    printf("passed!\n");

    testcase++;
    printf("Test Case #%d: Simultaneous insert/remove...\n", testcase);
    tb->setDin(0xA);
    tb->setInsert(1);
    tb->setRemove(1);
    tb->tick();
    assert(tb->getEmpty() == 1);
    assert(tb->getFull() == 0);
    assert(tb->getDout() == 0xA);
    printf("passed!\n");

    /*
    int din = 0;
    // toggle DIN
    for(int i=0; i<2*(SYNC_STAGES+(1<<CLK_CYCLES_L2));i++)
    {
        tb->setDin(din);
        tb->tick();
        din = !din;
        assert(tb->getDoutOutput() == 0);
        assert(tb->getOnlowOutput() == 0);
        assert(tb->getOnhighOutput() == 0);
    }
    // ensure DIN is low
    tb->setDin(0);
    tb->tick();

    // stablize DIN at '1'
    tb->setDin(1);
    for(int i=0; i<(SYNC_STAGES+(1<<CLK_CYCLES_L2));i++)
    {
        assert(tb->getOnlowOutput() == 0);
        assert(tb->getOnhighOutput() == 0);
        assert(tb->getDoutOutput() == 0); // next clock cycle
        tb->setDin(1);
        tb->tick();
    }
    // assert expected conditions
    assert(tb->getOnlowOutput() == 0);
    assert(tb->getOnhighOutput() == 1);
    assert(tb->getDoutOutput() == 1);
    tb->tick();
    assert(tb->getOnlowOutput() == 0);
    assert(tb->getOnhighOutput() == 0);
    assert(tb->getDoutOutput() == 1);

    tb->tick();
    tb->tick();
    tb->tick();
    tb->tick();
    // stablize DIN at '0'
    tb->setDin(0);
    for(int i=0; i<(SYNC_STAGES+(1<<CLK_CYCLES_L2));i++)
    {
        assert(tb->getOnlowOutput() == 0);
        assert(tb->getOnhighOutput() == 0);
        // should still be high
        assert(tb->getDoutOutput() == 1);
        tb->setDin(0);
        tb->tick();
    }
    // assert expected conditions
    assert(tb->getDoutOutput() == 0);
    assert(tb->getOnlowOutput() == 1);
    assert(tb->getOnhighOutput() == 0);
    tb->tick();
    assert(tb->getOnlowOutput() == 0);
    assert(tb->getOnhighOutput() == 0);
    assert(tb->getDoutOutput() == 0);

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
    */
    tb->setDin(0);
    tb->setFlush(0);
    tb->setInsert(0);
    tb->setRemove(0);
    tb->tick();
    printf("All test cases PASSED!\n");
    exit(EXIT_SUCCESS);
}
