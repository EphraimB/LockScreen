include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)lockscreen

# This is all the make targets to produce said files
$(BIN)LockScreen: main.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)lockscreen

include .knightos/sdk.make
