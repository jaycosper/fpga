//#include <stdlib.h>
#include "Vmealy.h"
#include "verilated.h"
#include "tb_template.h"
#include "tb_mealy.h"
#include <iostream>
using namespace std;
#include <cassert>

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB *tb = new DUT_TB();
    int testcase = 0;

    tb->opentrace("mealy_trace.vcd");

    // reset DUT
    tb->setFlag(0);

    tb->tick();
    tb->tick();

    tb->resetDUT();

    tb->tick();
    tb->tick();

    testcase++;
    printf("Test Case #%d: Reset state...\n", testcase);
    tb->resetDUT();
    tb->tick();
    assert(tb->getOut() == 2);
    printf("passed!\n");

    testcase++;
    printf("Test Case #%d: All states...\n", testcase);
    tb->resetDUT();
    assert(tb->getOut() == 1);
    tb->tick();
    assert(tb->getOut() == 2);
    tb->tick();
    assert(tb->getOut() == 3);
    tb->tick();
    assert(tb->getOut() == 4);
    tb->tick();
    assert(tb->getOut() == 1);
    printf("passed!\n");

    testcase++;
    printf("Test Case #%d: Flag set...\n", testcase);
    tb->resetDUT();
    assert(tb->getOut() == 1);
    tb->tick();
    tb->setFlag(1);
    assert(tb->getOut() == 2);
    tb->tick();
    tb->setFlag(0);
    assert(tb->getOut() == 4);
    tb->tick();
    assert(tb->getOut() == 1);
    tb->tick();
    printf("passed!\n");

    // All done... cleanup
    tb->setFlag(0);
    tb->tick();
    printf("All %d test case(s) PASSED!\n", testcase);
    exit(EXIT_SUCCESS);
}
