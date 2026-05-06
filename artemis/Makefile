# ----------------------------
# Compiler & Flags
# ----------------------------
CC      = gcc
CFLAGS  = -Wall -Wextra -Iemu/include

# ----------------------------
# Directories
# ----------------------------
SRC_DIRS := emu emu/lib
OBJ_DIR  := build

# ----------------------------
# Source discovery
# ----------------------------
SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))

# Object files (flattened)
OBJS := $(SRCS:%.c=$(OBJ_DIR)/%.o)

# Fix paths: build/./main.o -> build/main.o
OBJS := $(subst $(OBJ_DIR)/./,$(OBJ_DIR)/,$(OBJS))

TARGET := artemis

# ----------------------------
# Default target
# ----------------------------
all: $(TARGET)

# ----------------------------
# Link
# ----------------------------
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@

# ----------------------------
# Compile rule (generic)
# ----------------------------
$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# ----------------------------
# Build directory
# ----------------------------
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# ----------------------------
# Clean
# ----------------------------
clean:
	rm -rf $(OBJ_DIR) $(TARGET)

.PHONY: all clean
