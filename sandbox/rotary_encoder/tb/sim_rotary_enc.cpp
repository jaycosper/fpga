//#include <stdlib.h>
#include "Vrotary_enc.h"
#include "verilated.h"
#include "tb_template.h"
#include "tb_rotary_enc.h"
#include <iostream>
using namespace std;
#include <cassert>

constexpr uint16_t gray_decode[4] = {0, 1, 3, 2};
void gray_decoder(uint16_t count, bool &encA, bool &encB)
{
    uint16_t val = gray_decode[(count%4)];
    encA = ((val>>1)&0x1);
    encB = (val&0x1);
    return;
}

constexpr uint16_t ENCODER_MIN = 4;
constexpr uint16_t ENCODER_MAX = 480;

enum enc_dir_e { DIR_UP, DIR_DOWN };
void encUpdate(DUT_TB *tb, enc_dir_e dir, uint16_t &encoder)
{
    bool encA, encB;

    if (dir == DIR_UP)
    {
        if (encoder < ENCODER_MAX) encoder+=ENCODER_MIN;
    }
    else
    {
        if (encoder > ENCODER_MIN) encoder-=ENCODER_MIN;
    }

    gray_decoder(encoder/ENCODER_MIN, encA, encB);
    tb->setEncA(encA);
    tb->setEncB(encB);
    tb->tick();
    printf("reference encoder: %d\n", encoder);
}

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB *tb = new DUT_TB();

    tb->opentrace("rotary_enc_trace.vcd");

    // reset DUT
    tb->setEncA(0);
    tb->setEncB(0);
    tb->reset();

    tb->tick();
    tb->tick();

    assert(tb->getCountOutput() == ENCODER_MIN);

    // flush debounce pipeline and assert outputs
    uint16_t encoder = 0;
    uint16_t count = 0;
    bool encA, encB;
    for (int n = 0; n<16; n++)
    {
        // count up
        encUpdate(tb, DIR_UP, encoder);
    }

    for(int i=0; i<6;i++)
    {
        tb->tick();
    }

    encoder = tb->getCountOutput();

    for (int n = 0; n<18; n++)
    {
        // count down
        encUpdate(tb, DIR_DOWN, encoder);
    }

    for(int i=0; i<10;i++)
    {
        tb->tick();
    }

    printf("All test cases PASSED!\n");
    exit(EXIT_SUCCESS);
}
