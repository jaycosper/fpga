//#include <stdlib.h>
#include "Vnrz.h"
#include "verilated.h"
#include "tb_nrz.h"
#include <iostream>
using namespace std;
#include <cassert>

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB *tb = new DUT_TB();
    int testcase = 0;

    tb->opentrace("nrz_trace.vcd");

    // reset DUT
    tb->setReset(0);
    tb->setClkEn(0);
    tb->setValid(0);
    tb->setDin(0);

    tb->tick();
    tb->tick();

    tb->resetDUT();

    tb->tick();
    tb->tick();
    printf("DUT Reset complete!\n");
    tb->tick();
    tb->tick();

    testcase++;
    printf("Test Case #%d: Initial state...\n", testcase);
    assert(tb->getDout() == 0);
    assert(tb->getDone() == 0);
    printf("passed!\n");

    testcase++;
    printf("Test Case #%d: Zeros DIN...\n", testcase);
    tb->setClkEn(1);
    tb->setValid(1);
    tb->setDin(0);
    tb->tick();
    tb->setValid(0);
    tb->setDin(0);
    while(!tb->getDone()) tb->tick();
    tb->tick();
    assert(tb->getDone() == 0);
    printf("passed!\n");

    tb->tick(); tb->tick(); tb->tick(); tb->tick();

    testcase++;
    printf("Test Case #%d: Ones DIN...\n", testcase);
    tb->setClkEn(1);
    tb->setValid(1);
    tb->setDin(0xFFFFFF);
    tb->tick();
    tb->setValid(0);
    tb->setDin(0);
    while(!tb->getDone()) tb->tick();
    tb->tick();
    assert(tb->getDone() == 0);
    printf("passed!\n");

    tb->tick(); tb->tick(); tb->tick(); tb->tick();

    testcase++;
    printf("Test Case #%d: Back to Back DIN...\n", testcase);
    tb->setClkEn(1);
    tb->setValid(1);
    tb->setDin(0xAAAAAA);
    tb->tick();
    tb->setValid(0);
    tb->setDin(0);
    while(!tb->getDone()) tb->tick();
    tb->setValid(1);
    tb->setDin(0x555555);
    tb->tick();
    tb->setValid(0);
    tb->setDin(0);
    while(!tb->getDone()) tb->tick();
    assert(tb->getDone() == 1);
    tb->tick();
    assert(tb->getDone() == 0);
    printf("passed!\n");

    tb->tick(); tb->tick(); tb->tick(); tb->tick();
    tb->tick(); tb->tick(); tb->tick(); tb->tick();
    tb->tick(); tb->tick(); tb->tick(); tb->tick();
    tb->tick(); tb->tick(); tb->tick(); tb->tick();

    // All done... cleanup
    tb->setClkEn(0);
    tb->setValid(0);
    tb->setDin(0);
    tb->tick();
    printf("All %d test case(s) PASSED!\n", testcase);
    exit(EXIT_SUCCESS);
}
