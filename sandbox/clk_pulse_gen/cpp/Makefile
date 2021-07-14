# Verilator makefile

PROJECT = clk_pulse_gen
#TOP = test_our
SRC = ../$(PROJECT).v
TEST_SRC= sim_$(PROJECT).cpp
OUTPUT_DIR = obj_dir
EXE = V$(PROJECT)

GFLAGS = -S ${FPGA_PROJDIR}/tools/gtkwave/gtkwave.tcl
WAVEFILE = $(PROJECT)_trace.vcd

CC = verilator
FLAGS = -Wall -cc --trace

.PHONY: all clean lint sim test wave

all: test

lint:
	$(CC) $(FLAGS) --lint-only $(SRC)

sim:
	$(CC) $(FLAGS) -exe $(TEST_SRC) $(SRC)
	make -j -C $(OUTPUT_DIR) -f V$(PROJECT).mk V$(PROJECT)

test: sim
	./$(OUTPUT_DIR)/$(EXE)

wave:
	gtkwave $(GFLAGS) ./$(WAVEFILE)

clean:
	rm -rf obj_dir *.vcd
