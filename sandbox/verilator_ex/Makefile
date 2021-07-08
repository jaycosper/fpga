# Verilator makefile

PROJECT = example
#TOP = test_our
SRC = $(PROJECT).v
TEST_SRC= sim_$(PROJECT).cpp
OUTPUT_DIR = obj_dir
EXE = V$(PROJECT)
#WAVEFILE = wave.vcd

CC = verilator
FLAGS = -Wall -cc

.PHONY: all clean lint sim test wave

all: test

lint:
	$(CC) $(FLAGS) $(SRC)

sim:
	$(CC) $(FLAGS) -exe $(TEST_SRC) $(SRC)
	make -j -C $(OUTPUT_DIR) -f V$(PROJECT).mk V$(PROJECT)

test: sim
	./$(OUTPUT_DIR)/$(EXE)

#wave: test
#	gtkwave $(WAVEFILE)

clean:
	rm -rf obj_dir