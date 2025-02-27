#pragma once
// using path since I can't get MAKE include paths to work with Verilator/g++
#include "../../tb_common/tb_template.h"

class DUT_TB : public TESTBENCH<Vnrz>
{
public:
    // get the time value
    virtual unsigned long getTickCount(void)
    {
        return m_tickcount;
    }

    // reset
    virtual void setReset(uint32_t val)
    {
        m_core->reset = val;
    }

    // clken
    virtual void setClkEn(uint32_t val)
    {
        m_core->clken = val;
    }

    // valid
    virtual void setValid(uint32_t val)
    {
        m_core->valid = val;
    }

    // din
    virtual void setDin(uint32_t val)
    {
        m_core->din = val;
    }

    // done
    virtual bool getDone(void)
    {
        return m_core->done;
    }

    // dout
    virtual uint32_t getDout(void)
    {
        return m_core->dout;
    }

    virtual void resetDUT(void)
    {
        m_core->reset = 1;
        this->tick();
        this->tick();
        m_core->reset = 0;
    }

    virtual void tick(void)
    {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vnrz>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: clken %d valid %d din %d done %d dout %d\n",
            m_tickcount, m_core->clken, m_core->valid, m_core->din,
            m_core->done, m_core->dout);
    }
};