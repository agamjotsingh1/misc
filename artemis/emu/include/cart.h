#ifndef CART_DEF
#define CART_DEF

#include <stdint.h>
#include <byte.h>

#define CART_FILENAME_SIZE 1024

#define CART_HEADER_ENTRY_SIZE 0x4
#define CART_HEADER_LOGO_SIZE 0x30
#define CART_HEADER_TITLE_SIZE 0x10

#define CART_HEADER_OFFSET 0x100

typedef struct {
    byte entry[CART_HEADER_ENTRY_SIZE];
    byte logo[CART_HEADER_LOGO_SIZE];
    byte title[CART_HEADER_TITLE_SIZE];
    dblbyte new_licensee;

    byte sgb;
    byte type;
    byte rom_size;
    byte ram_size;
    byte dest;
    byte licensee;
    byte version;
    byte checksum;

    dblbyte global_checksum;
} cart_header_t;

typedef struct {
    char filename[CART_FILENAME_SIZE];
    unsigned int size;
    byte *data;
    cart_header_t *header;
} cart_ctx_t;

void cart_load(char cart_filename[CART_FILENAME_SIZE]);

#endif