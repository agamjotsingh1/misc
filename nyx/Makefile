CC := gcc
CFLAGS := -Wall -Wextra -Werror -std=c11

TARGET := lexer_bin
SRCS := lexer/lexer.c
OBJS := $(SRCS:.c=.o)
DEPS := lexer/lexer.h lexer/token.h

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

lexer/%.o: lexer/%.c $(DEPS)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)