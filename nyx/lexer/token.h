#ifndef TOKEN_H
#define TOKEN_H

enum Op {
    ADD,
    SUB,
    MULT,
    DIV
};

enum TokenType {
    IDENT,
    INT,
    FLOAT,
    ASSIGN,
    OP,
    R_PAREN,
    L_PAREN
};

union TokenVal {
    enum Op op;
    char* ident;
    int n_int;
    float n_float;
};


struct Token {
    enum TokenType type;
    union TokenVal val;
    struct Token* next;
};

#endif