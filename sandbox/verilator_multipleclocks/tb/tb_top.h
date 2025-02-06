#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vtop>
{
public:

    // set the terminal count input
    virtual void reset(void)
    {
        // strobe async active-low reset pin
        m_core->i_arst_n = 0;
        this->tick();
        this->tick();
        this->tick();
        m_core->i_arst_n = 1;
    }

    virtual void setDin1(uint32_t din)
    {
        m_core->i_din1 = din;
    }
    virtual void setDin2(uint32_t din)
    {
        m_core->i_din2 = din;
    }

    // get the o_dout output
    virtual bool getDout1Output(void)
    {
        return m_core->o_dout1;
    }
    virtual bool getDout2Output(void)
    {
        return m_core->o_dout2;
    }

    void sim_clk_tick(void) {
        m_core->i_din1 = m_core->i_din1+1;
    }

    virtual void tick(void)
    {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vtop>::tick();

        // Now we'll debug by printf's and examine the internals of m_core
        printf("%8ld: dout1 %d dout2 %d\n", TESTBENCH<Vtop>::get_tick_time(), m_core->o_dout1, m_core->o_dout2);
    }
};