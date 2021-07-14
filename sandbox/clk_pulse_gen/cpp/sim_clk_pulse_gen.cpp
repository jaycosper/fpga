//#include <stdlib.h>
#include "Vclk_pulse_gen.h"
#include "verilated.h"
#include "tb_template.h"
#include "tb_clk_pulse_gen.h"
#include <iostream>
using namespace std;
#include <cassert>

//#define ALT_VERILATOR_TB
#ifndef ALT_VERILATOR_TB
int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    DUT_TB *tb = new DUT_TB();

    tb->opentrace("clk_pulse_gen_trace.vcd");

    // reset DUT
    tb->reset();
    tb->setTC(0x3);

    tb->tick();
    tb->tick();

    // data <= 1;
    // while (data_redge != 1'b1) begin
    //     @(negedge clk);
    // end
    // `assert(data_redge, 1'b1);
    // `assert(data_fedge, 1'b0)
    tb->setData(1);
    while(!tb->getDataRedgeOuput()) tb->tick();
    assert(tb->getDataRedgeOuput());
    assert(!tb->getDataFedgeOuput());
    // @(negedge clk);
    // @(negedge clk);
    // @(negedge clk);
    // @(negedge clk);
//
    // data <= 0;
    // while (data_fedge != 1'b1) begin
    //     @(negedge clk);
    // end
    // `assert(data_redge, 1'b0);
    // `assert(data_fedge, 1'b1);
    tb->tick();
    tb->tick();
    tb->tick();
    tb->tick();
    tb->setData(0);
    while(!tb->getDataFedgeOuput()) tb->tick();
    assert(!tb->getDataRedgeOuput());
    assert(tb->getDataFedgeOuput());

    // Tick the clock until we are done
    while(!tb->done())
    {
        tb->tick();

        if (tb->getClkPulseOuput())
            cout << ".";

        if (tb->getTickCount() > 100ul)
            exit(EXIT_SUCCESS);
    }
    exit(EXIT_SUCCESS);
}

#else // ALT_VERILATOR_TB
#include <iostream>
Vclk_pulse_gen *dut;    // Instantiation of module

unsigned int main_time = 0;     // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);   // Remember args

    dut = new Vclk_pulse_gen;   // Create instance

    dut->i_rst_n = 0;           // Set some inputs

    while (!Verilated::gotFinish()) {
        if (main_time > 10) {
            dut->i_rst_n = 1;   // Deassert reset
        }
        if ((main_time % 10) == 1) {
            dut->i_clk = 1;       // Toggle clock
        }
        if ((main_time % 10) == 6) {
            dut->i_clk = 0;
        }
        dut->eval();            // Evaluate model
        cout << "o_clk_pulse: " << dut->o_clk_pulse << endl;       // Read a output
        main_time++;            // Time passes...
    }

    dut->final();               // Done simulating
    //    // (Though this example doesn't get here)
}
#endif // ALT_VERILATOR_TB