#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexer.h"
#include "token.h"

struct Token* new_token(enum TokenType type, union TokenVal val) {
    struct Token* token = malloc(sizeof(struct Token));
    token->type = type;
    token->val = val;
    token->next = NULL;
    return token;
}

struct Token* append_token(struct Token** token_head, struct Token* token_tail, struct Token* new_token) {
    if(token_tail == NULL) {
        *token_head = new_token;
        return new_token;
    }

    token_tail->next = new_token;
    return new_token;
}

int is_alpha(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_');
}

int is_digit(char c) {
    return (c >= '0' && c <= '9');
}

int is_dot(char c) {
    return (c == '.');
}

int is_equals(char c) {
    return (c == '=');
}

int is_whitespace(char c) {
    return (c == ' ');
}

int is_paren(char c) {
    return (c == ')') || (c == '(');
}

int is_op(char c) {
    return (c == '+') || (c == '-') || (c == '*') || (c == '/');
}

enum State state_transition(enum State cur_state, char input, int* capture) {
    switch (cur_state)
    {
        case WHITESPACE:
            if(is_alpha(input)) { *capture = 1; return ALPHA; }
            else if(is_digit(input)) { *capture = 1; return DIGIT; }
            else if(is_dot(input)) return ERROR;
            else if(is_op(input)) return OPERATOR;
            else if(is_whitespace(input)) return WHITESPACE;
            else if(is_paren(input)) return PAREN;
            else if(is_equals(input)) return EQUALS;

            break;

        case DIGIT:
            if(is_alpha(input)) { *capture = 0; return ERROR; }
            else if(is_digit(input)) return DIGIT;
            else if(is_dot(input)) return DIGIT_DOT;
            else if(is_op(input)) { *capture = 0; return OPERATOR; }
            else if(is_whitespace(input)) { *capture = 0; return WHITESPACE; }
            else if(is_paren(input)) { *capture = 0; return PAREN; }
            else if(is_equals(input)) { *capture = 0; return EQUALS; }

            break;

        case DIGIT_DOT:
            if(is_alpha(input)) return ERROR;
            else if(is_digit(input)) return DIGIT_DOT;
            else if(is_dot(input)) { *capture = 0; return ERROR; }
            else if(is_op(input)) { *capture = 0; return OPERATOR; }
            else if(is_whitespace(input)) { *capture = 0; return WHITESPACE; }
            else if(is_paren(input)) { *capture = 0; return PAREN; }
            else if(is_equals(input)) { *capture = 0; return EQUALS; }

            break;

        case ALPHA:
            if(is_alpha(input)) return ALPHA;
            else if(is_digit(input)) return ALPHA;
            else if(is_dot(input)) { *capture = 0; return ERROR; }
            else if(is_op(input)) { *capture = 0; return OPERATOR; }
            else if(is_whitespace(input)) { *capture = 0; return WHITESPACE; }
            else if(is_paren(input)) { *capture = 0; return PAREN; }
            else if(is_equals(input)) { *capture = 0; return EQUALS; }

            break;

        case OPERATOR:
            if(is_alpha(input)) { *capture = 1; return ALPHA; }
            else if(is_digit(input)) { *capture = 1; return DIGIT; }
            else if(is_dot(input)) return ERROR;
            else if(is_op(input)) return OPERATOR;
            else if(is_whitespace(input)) { *capture = 0; return WHITESPACE; }
            else if(is_paren(input)) { *capture = 0; return PAREN; }
            else if(is_equals(input)) { *capture = 0; return EQUALS; }

            break;

        case EQUALS:
            if(is_alpha(input)) { *capture = 1; return ALPHA; }
            else if(is_digit(input)) { *capture = 1; return DIGIT; }
            else if(is_op(input)) { *capture = 0; return OPERATOR; }
            else if(is_dot(input)) return ERROR;
            else if(is_whitespace(input)) return WHITESPACE;
            else if(is_paren(input)) return PAREN;

            break;

        case PAREN:
            if(is_alpha(input)) { *capture = 1; return ALPHA; }
            else if(is_digit(input)) { *capture = 1; return DIGIT; }
            else if(is_op(input)) { *capture = 0; return OPERATOR; }
            else if(is_dot(input)) return ERROR;
            else if(is_whitespace(input)) return WHITESPACE;
            else if(is_paren(input)) return PAREN;

            break;

        case ERROR:
            return ERROR;
            break;
        
        default:
            break;
}

    return ERROR;
}

void clear_capture(int* capture_idx, char captured_token[MAX_CAPTURE_LEN]) {
    for(int i = 0; i < *capture_idx; i++) {
        captured_token[i] = '\0';
    }

    *capture_idx = 0;
}

int append_capture(int* capture_idx, char captured_token[MAX_CAPTURE_LEN], char ch) {
    if(*capture_idx >= MAX_CAPTURE_LEN) return 1;

    captured_token[*capture_idx] = ch;
    *capture_idx += 1;
    return 0;
}

struct Token* tokenize(char* prog, int* errflag) {
    enum State state = WHITESPACE;
    enum State next_state;

    struct Token* token_head = NULL;
    struct Token* token_tail = token_head;

    int capture = 0;
    int capture_idx = 0;
    char captured_token [MAX_CAPTURE_LEN];

    capture_idx = MAX_CAPTURE_LEN;
    clear_capture(&capture_idx, captured_token);

    enum TokenType type;
    union TokenVal val;

    while(*prog != '\0') {
        char ch = *prog;
        int prev_capture = capture;
        next_state = state_transition(state, ch, &capture);
        // printf("state %d -> %d, capture = %d\n", state, next_state, capture);

        
        if(prev_capture == 1 && capture == 1) {
            append_capture(&capture_idx, captured_token, ch);
        }
        else {
            if(prev_capture == 0 && capture == 1) {
                clear_capture(&capture_idx, captured_token);
                append_capture(&capture_idx, captured_token, ch);
            }
            else if(prev_capture == 1 && capture == 0) {
                switch (state) {
                    case ALPHA:
                        type = IDENT;
                        char* ident = malloc(sizeof(char) * capture_idx);
                        memcpy(ident, captured_token, capture_idx);
                        val.ident = ident;
                        token_tail = append_token(&token_head, token_tail, new_token(type, val));
                        break;

                    case DIGIT:
                        type = INT;
                        val.n_int = (int) atoi(captured_token);
                        token_tail = append_token(&token_head, token_tail, new_token(type, val));
                        break;

                    case DIGIT_DOT:
                        type = FLOAT;
                        append_capture(&capture_idx, captured_token, '0');
                        val.n_float = (float) atof(captured_token);
                        token_tail = append_token(&token_head, token_tail, new_token(type, val));
                        break;

                    default:
                        break;
                }
            }

            switch (next_state){
                case OPERATOR:
                    type = OP;
                    if(ch == '+') val.op = ADD;
                    else if(ch == '-') val.op = SUB;
                    else if(ch == '*') val.op = MULT;
                    else if(ch == '/') val.op = DIV;
                    token_tail = append_token(&token_head, token_tail, new_token(type, val));
                    break;

                case EQUALS:
                    type = ASSIGN;
                    token_tail = append_token(&token_head, token_tail, new_token(type, val));
                    break;

                case PAREN:
                    if(ch == '(') type = L_PAREN;
                    else if(ch == ')') type = R_PAREN;
                    token_tail = append_token(&token_head, token_tail, new_token(type, val));
                    break;

                case ERROR:
                    *errflag = 1;
                    return token_head;

                default:
                    break;
            }
        }

        state = next_state;
        prog++;
    }

    if (capture == 1) {
        captured_token[capture_idx] = '\0'; 
        
        switch (state) {
            case ALPHA:
                type = IDENT;
                char* ident = malloc(capture_idx + 1);
                strcpy(ident, captured_token);
                val.ident = ident;
                token_tail = append_token(&token_head, token_tail, new_token(type, val));
                break;

            case DIGIT:
                type = INT;
                val.n_int = atoi(captured_token);
                token_tail = append_token(&token_head, token_tail, new_token(type, val));
                break;

            case DIGIT_DOT:
                type = FLOAT;
                val.n_float = (float) atof(captured_token);
                token_tail = append_token(&token_head, token_tail, new_token(type, val));
                break;

            default:
                break;
        }
    }

    return token_head;
}

int main() {
    // char prog[] = "my_var = (123.4*3+32-1) + hello";
    // char prog[] = "a=(b*c)-1.5";
    // char prog[] = "_var123 = val_1 * 2";
    // char prog[] = "x = ((-y) + 5)";
    // char prog[] = "invalid = 1.2.3";
    // char prog[] = "total = price $ discount";
    // char prog[] = "12bad_var = 5";
    char prog[] = "";
    int errflag = 0;

    struct Token* tokens = tokenize(prog, &errflag);

    if (errflag) {
        printf("Lexer error.\n");
    }

    struct Token* curr = tokens;
    while (curr != NULL) {
        switch (curr->type) {
            case IDENT:
                printf("Token: IDENT\t Value: %s\n", curr->val.ident);
                break;
            case INT:
                printf("Token: INT\t Value: %d\n", curr->val.n_int);
                break;
            case FLOAT:
                printf("Token: FLOAT\t Value: %f\n", curr->val.n_float);
                break;
            case OP:
                char ch;
                if(curr->val.op == ADD) ch = '+';
                else if(curr->val.op == SUB) ch = '-';
                else if(curr->val.op == MULT) ch = '*';
                else if(curr->val.op == DIV) ch = '/';

                printf("Token: OP\t Value: %c\n", ch);
                break;
            case ASSIGN:
                printf("Token: ASSIGN\t Value: =\n");
                break;
            case L_PAREN:
                printf("Token: L_PAREN\t Value: (\n");
                break;
            case R_PAREN:
                printf("Token: R_PAREN\t Value: )\n");
                break;
            default:
                printf("Token: UNKNOWN\n");
                break;
        }
        curr = curr->next;
    }

    curr = tokens;
    while (curr != NULL) {
        struct Token* next = curr->next;
        if (curr->type == IDENT && curr->val.ident != NULL) {
            free(curr->val.ident);
        }
        free(curr);
        curr = next;
    }

    return 0;
}