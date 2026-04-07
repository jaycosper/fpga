# Verilator makefile

PROJECT = toggle_sync
#TOP = test_our
SRC = ../$(PROJECT).sv
TEST_NAME= tb_$(PROJECT)
TEST_SRC= $(TEST_NAME).sv
OUTPUT_DIR = obj_dir
EXE = V$(TEST_NAME)

GFLAGS = -S ${FPGA_PROJDIR}/tools/gtkwave/gtkwave.tcl
WAVEFILE = $(TEST_NAME).vcd

CC = verilator
FLAGS = -cc --exe --timing --trace -j 0 --main

PARAMS = #-GSYNC_STAGES=3 -GCLK_CYCLES_L2=4

.PHONY: all clean lint sim test wave

all: test

lint:
	$(CC) -Wall $(FLAGS) $(PARAMS) --lint-only $(SRC)

sim:
	$(CC) $(FLAGS) --build $(PARAMS) $(TEST_SRC) $(SRC)
	# make -j -C $(OUTPUT_DIR) -f V$(PROJECT).mk V$(PROJECT)

test: sim
	./$(OUTPUT_DIR)/$(EXE)

wave:
	gtkwave $(GFLAGS) ./$(WAVEFILE)

clean:
	rm -rf $(OUTPUT_DIR) *.vcd
