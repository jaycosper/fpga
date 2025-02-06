#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vfifosc>
{
public:
    // get the time value
    virtual unsigned long getTickCount(void)
    {
        return m_tickcount;
    }

    // flush
    virtual void setFlush(uint32_t val)
    {
        m_core->flush = val;
    }

    // insert
    virtual void setInsert(uint32_t val)
    {
        m_core->insert = val;
    }

    // remove
    virtual void setRemove(uint32_t val)
    {
        m_core->remove = val;
    }

    // set the terminal count input
    virtual void setDin(uint32_t val)
    {
        m_core->din = val;
    }

    // empty
    virtual bool getEmpty(void)
    {
        return m_core->empty;
    }

    // full
    virtual uint32_t getFull(void)
    {
        return m_core->full;
    }

    // get the dout
    virtual uint32_t getDout(void)
    {
        return m_core->dout;
    }

    virtual void resetDUT(void)
    {
        m_core->flush = 1;
        this->tick();
        this->tick();
        m_core->flush = 0;
    }

    virtual void    tick(void)
    {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vfifosc>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: flush %d insert %d remove %d din %d dout %d empty %d full %d\n",
            m_tickcount, m_core->flush, m_core->insert, m_core->remove, m_core->din,
            m_core->dout, m_core->empty, m_core->full);
    }
};