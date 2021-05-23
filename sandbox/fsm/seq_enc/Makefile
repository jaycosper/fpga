TOP = seq_enc_tb
SRC = seq_enc.v
TEST_SRC= seq_enc_tb.v
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