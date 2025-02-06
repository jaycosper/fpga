#pragma once
#include <verilated_vcd_c.h>

constexpr int CLOCK_PERIOD = 8;

template<class MODULE>    class TESTBENCH
{
    VerilatedVcdC   *m_trace;

public:
    unsigned long   m_tickcount;
    MODULE          *m_core;

    TESTBENCH(void)
    {
        // According to the Verilator spec, you *must* call
        // traceEverOn before calling any of the tracing functions
        // within Verilator.
        Verilated::traceEverOn(true);
        m_core = new MODULE;
        m_tickcount = 0l;
    }

    virtual ~TESTBENCH(void)
    {
        delete m_core;
        m_core = NULL;
    }

    // Open/create a trace file
    virtual void opentrace(const char *vcdname)
    {
        if (!m_trace)
        {
            m_trace = new VerilatedVcdC;
            m_core->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }

    // Close a trace file
    virtual void close(void)
    {
        if (m_trace) {
            m_trace->close();
            m_trace = NULL;
        }
    }

    virtual void tick(void)
    {
        // Increment our own internal time reference
        m_tickcount++;

        // Make sure any combinatorial logic depending upon
        // inputs that may have changed before we called tick()
        // has settled before the rising edge of the clock.
        m_core->clk = 0;
        m_core->eval();
        if (m_trace)
        {
            m_trace->dump(CLOCK_PERIOD*m_tickcount);
        }

        // Rising edge
        m_core->clk = 1;
        m_core->eval();
        if(m_trace)
        {
            m_trace->dump(CLOCK_PERIOD*m_tickcount+CLOCK_PERIOD/2);
            // We'll also need to make sure we flush any I/O to
            // the trace file, so that we can use the assert()
            // function between now and the next tick if we want to.
            m_trace->flush();
        }

        // Falling edge
        m_core->clk = 0;
        m_core->eval();
    }

    virtual bool done(void)
    {
        return (Verilated::gotFinish());
    }
};