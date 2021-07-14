#pragma once
#include "tb_template.h"

class DUT_TB : public TESTBENCH<Vclk_pulse_gen> {
public:
    // get the time value
    virtual unsigned long   getTickCount(void) {
        return m_tickcount;
    }

    // set the terminal count input
    virtual void    setTC(uint32_t tc) {
        m_core->i_pulse_tc = tc;
    }

    // set the data input
    virtual void    setData(uint32_t data) {
        m_core->i_data = data;
    }

    // get the o_clk_pulse output
    virtual bool    getClkPulseOuput(void) {
        return m_core->o_clk_pulse;
    }

    // get the o_data_redge output
    virtual bool    getDataRedgeOuput(void) {
        return m_core->o_data_redge;
    }

    // get the o_data_fedge output
    virtual bool    getDataFedgeOuput(void) {
        return m_core->o_data_fedge;
    }

    virtual void reset(void) {
        m_core->i_rst_n = 0;
        this->tick();
        m_core->i_rst_n = 1;
    }

    virtual void    tick(void) {
        // Request that the testbench toggle the clock within Verilator
        TESTBENCH<Vclk_pulse_gen>::tick();

        // Now we'll debug by printf's and examine the
        // internals of m_core
        printf("%8ld: %s ...\n", m_tickcount,
            (m_core->o_clk_pulse)?"o_clk_pulse":"   ");
    }
};