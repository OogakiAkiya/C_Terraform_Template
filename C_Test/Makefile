CC = g++
OBJ_DIR = ./obj
BIN_DIR = ./bin

hello:$(BIN_DIR) $(OBJ_DIR) hello.o print.o
	$(CC) -Wall -O2 -o $(BIN_DIR)/hello $(OBJ_DIR)/hello.o $(OBJ_DIR)/print.o

#make obj directory
$(OBJ_DIR):
	@if [ ! -d $(OBJ_DIR) ]; then \
		echo";; mkdir $(OBJ_DIR)"; mkdir $(OBJ_DIR); \
	fi
#make bin directory
$(BIN_DIR):
	@if [ ! -d $(BIN_DIR) ]; then \
		echo";; mkdir $(BIN_DIR)"; mkdir $(BIN_DIR); \
	fi
hello.o:
	$(CC) -c ./src/hello.c -o $(OBJ_DIR)/hello.o
print.o:
	$(CC) -c ./src/print.c -o $(OBJ_DIR)/print.o
clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR)
