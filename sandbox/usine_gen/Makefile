TOP = usine_gen_tb
SRC = usine_gen.v
TEST_SRC= usine_gen_tb.v
BIN = $(TOP).vvp
WAVEFILE = wave.vcd

CC = iverilog
FLAGS = -Wall

$(BIN): $(SRC) $(TEST_SRC)
	$(CC) $(FLAGS) -o $(BIN) -s $(TOP) $(SRC) $(TEST_SRC)

.PHONY: all clean test wave

all: $(BIN)

test: $(BIN)
	vvp $(BIN)

wave: test
	gtkwave $(WAVEFILE)

clean:
	rm -f *.vvp *.vcd