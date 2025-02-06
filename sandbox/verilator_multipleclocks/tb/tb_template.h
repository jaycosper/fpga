#pragma once
#include <verilated_vcd_c.h>
#include "tb_clock.h"

constexpr unsigned long CLK_PERIOD_PS=10000; // 100MHz
constexpr unsigned long CLK2_PERIOD_PS=11340; // ??MHz
template<class TB> class TESTBENCH
{
public:
    TB*             m_core;
    bool            m_changed;
    VerilatedVcdC*  m_trace;
    bool            m_done;
    unsigned long   m_time_ps;
    TBCLOCK         m_clk;
    TBCLOCK         m_clk2;

    TESTBENCH(void)
    {
        m_core = new TB;
        m_time_ps  = 0ul;
        m_trace    = NULL;
        m_done     = false;
        Verilated::traceEverOn(true);
        m_clk.init(CLK_PERIOD_PS);
        m_clk2.init(CLK2_PERIOD_PS);
    }

    virtual ~TESTBENCH(void)
    {
        if (m_trace) m_trace->close();
        delete m_core;
        m_core = NULL;
    }

    virtual void opentrace(const char* vcdname)
    {
        if (!m_trace)
        {
            m_trace = new VerilatedVcdC;
            m_core->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }

    void trace(const char* vcdname)
    {
        opentrace(vcdname);
    }

    virtual void closetrace(void)
    {
        if (m_trace)
        {
            m_trace->close();
            delete m_trace;
            m_trace = NULL;
        }
    }

    virtual void eval(void)
    {
        m_core->eval();
    }

    virtual void tick(void)
    {
        unsigned mintime = m_clk.time_to_tick();

        // determine smallest minimum time for all clocks
        if (m_clk2.time_to_tick() < mintime)
        {
            mintime = m_clk2.time_to_tick();
        }

        assert(mintime > 1);

        eval();

        // advance all clocks
        m_core->i_clk = m_clk.advance(mintime);
        m_core->i_clk2 = m_clk2.advance(mintime);

        m_time_ps += mintime;

        eval();
        if (m_trace) {
            m_trace->dump(m_time_ps+1);
            m_trace->flush();
        }

        if (m_clk.falling_edge())
        {
            m_changed = true;
            sim_clk_tick();
        }
        if (m_clk2.falling_edge())
        {
            m_changed = true;
            sim_clk2_tick();
        }
    }

    unsigned long get_tick_time(void)
    {
        return m_time_ps;
    }

    virtual void sim_clk_tick(void)
    {
            // Your test fixture should over-ride this method.
            // If you change any of the inputs to the design
            // (i.e. w/in main.v), then set m_changed to true.
            m_changed = false;
    }
    virtual void sim_clk2_tick(void)
    {
            // Your test fixture should over-ride this method.
            // If you change any of the inputs to the design
            // (i.e. w/in main.v), then set m_changed to true.
            m_changed = false;
    }

    virtual bool done(void)
    {
        if (m_done)
        {
            return true;
        }

        if (Verilated::gotFinish())
        {
            m_done = true;
        }

        return m_done;
    }
};