#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vmoore>
{
public:
    // get the time value
    virtual unsigned long getTickCount(void)
    {
        return m_tickcount;
    }

    // flag
    virtual void setFlag(uint32_t val)
    {
        m_core->flag = val;
    }

    // out
    virtual int getOut(void)
    {
        return m_core->out;
    }

    virtual void resetDUT(void)
    {
        m_core->reset = 1;
        this->tick();
        this->tick();
        m_core->reset = 0;
    }

    virtual void    tick(void)
    {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vmoore>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: reset %d flag %d out %d\n",
            m_tickcount, m_core->reset, m_core->flag, m_core->out);
    }
};