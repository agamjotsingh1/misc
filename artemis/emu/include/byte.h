#ifndef BYTE_DEF
#define BYTE_DEF

#include <stdint.h>

typedef uint8_t byte;
typedef uint16_t dblbyte;

typedef int8_t byte_s;
typedef int16_t dblbyte_s;

typedef enum {
    U_BYTE,
    U_DBLBYTE,
    S_BYTE,
    S_DBLBYTE
} val_type_t;

typedef struct {
    val_type_t type;
    union {
        byte u_byte; 
        dblbyte u_dblbyte; 
        byte_s s_byte;
        dblbyte_s s_dblbyte;
    };
} val_t;

#define VAL_U_BYTE(_val) \
    ((val_t) {.type = U_BYTE, .u_byte = _val})

#define VAL_U_DBLBYTE(_val) \
    ((val_t) {.type = U_DBLBYTE, .u_dblbyte = _val})

#define VAL_S_BYTE(_val) \
    ((val_t) {.type = S_BYTE, .s_byte = _val})

#define VAL_S_DBLBYTE(_val) \
    ((val_t) {.type = S_DBLBYTE, .s_dblbyte = _val})

#define STITCH(high, low) \
    ((dblbyte) ((high << 8) | (low)))

#define LOW_BYTE(val) \
    ((byte) (val & 0x00FF))

#define HIGH_BYTE(val) \
    ((byte) (val >> 8))

#define FETCH_BIT(val, pos) \
    ((byte) ((val >> pos) & 0x1))

#define WRITE_BIT(val, pos, bit) \
    do { \
        (val) = ((val) & ~(1U << (pos))) | ((!!(bit)) << (pos)); \
    } while (0);


typedef enum {
    NIBBLE,
    BYTE,
    DBLBYTE,
    TRIBYTE,
    QUADBYTE
} len_t;

#endif