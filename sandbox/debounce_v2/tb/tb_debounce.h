#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vdebounce> {
public:
    // get the time value
    virtual unsigned long   getTickCount(void) {
        return m_tickcount;
    }

    // set the terminal count input
    virtual void    setDin(uint32_t din) {
        m_core->i_din = din;
    }

    // get the o_dout output
    virtual bool    getDoutOutput(void) {
        return m_core->o_dout;
    }

    // get the o_onlow output
    virtual bool    getOnlowOutput(void) {
        return m_core->o_onlow;
    }

    // get the o_onup output
    virtual bool    getOnhighOutput(void) {
        return m_core->o_onhigh;
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
        TESTBENCH<Vdebounce>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: dout %d onlow %d onhigh %d\n", m_tickcount, m_core->o_dout, m_core->o_onlow, m_core->o_onhigh);
    }
};