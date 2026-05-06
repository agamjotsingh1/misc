#ifndef REGFILE_DEF
#define REGFILE_DEF

#include <stdbool.h>
#include <byte.h>

#define REGFILE_LEN 11

typedef enum {
    // individual 8 bit registers
    B = 0x0,
    C = 0x1,
    D = 0x2,
    E = 0x3,
    H = 0x4,
    L = 0x5,
    F = 0x6,
    A = 0x7
} reg_t;

typedef enum {
    // unified 16 bit registers
    AF = (A << 4) | F,
    BC = (B << 4) | C,
    DE = (D << 4) | E,
    HL = (H << 4) | L,
    SP = 0x89,
    PC = 0xab
} reg_unif_t;

typedef enum {
    z = 0x80,
    n = 0x40,
    h = 0x20,
    c = 0x10
} flag_t;

void write_reg(reg_t reg, byte val);
byte fetch_reg(reg_t reg);

// unified register writes/fetches
void write_unif_reg(reg_unif_t reg, dblbyte val);
dblbyte fetch_unif_reg(reg_unif_t reg);

bool is_active_flag(flag_t flag);
void set_flag(flag_t flag);
void clear_flag(flag_t flag);

#endif