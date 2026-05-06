#ifndef LEXER_H
#define LEXER_H

#define MAX_CAPTURE_LEN 256

enum State {
    ALPHA,
    OPERATOR,
    DIGIT,
    DIGIT_DOT,
    EQUALS,
    WHITESPACE,
    PAREN,
    ERROR
};

#endif