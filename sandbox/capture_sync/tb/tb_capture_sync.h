#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vcapture_sync> {
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

    virtual void    activeHighReset(void) {
        m_core->i_rst = 1;
        this->tick();
        this->tick();
        m_core->i_rst = 0;
    }

    virtual void    tick(void) {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vcapture_sync>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: dout %x\n", m_tickcount, m_core->o_dout);
    }
};