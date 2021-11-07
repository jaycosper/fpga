#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vrotary_enc> {
public:
    // get the time value
    virtual unsigned long   getTickCount(void) {
        return m_tickcount;
    }

    // set the encoder channel A input
    virtual void    setEncA(bool enc_a) {
        m_core->i_enc_a = enc_a;
    }

    // set the encoder channel B input
    virtual void    setEncB(bool enc_b) {
        m_core->i_enc_b = enc_b;
    }

    // get the o_dout output
    virtual uint16_t    getCountOutput(void) {
        return m_core->o_enc_cnt;
    }

    virtual void    al_reset(void) {
        m_core->i_rst = 0;
        m_core->i_rst_n = 0;
        this->tick();
        this->tick();
        m_core->i_rst_n = 1;
    }

    virtual void    tick(void) {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vrotary_enc>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: enc_cnt %d\n", m_tickcount, m_core->o_enc_cnt);
    }
};