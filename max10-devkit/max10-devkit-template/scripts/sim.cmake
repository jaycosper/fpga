cmake_minimum_required(VERSION 3.10)

# Define the simulation executable
set(SIMULATION_APP_NAME TBD-SystemVerilog-Simulator)
find_program(VERILOG_SIMULATOR ${SIMULATION_APP_NAME})

if(NOT VERILOG_SIMULATOR)
    message(WARNING "Code simulator ${SIMULATION_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(GLOBAL_SIM_OPTIONS)
