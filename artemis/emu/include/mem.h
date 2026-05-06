#ifndef MEM_DEF
#define MEM_DEF

#include <byte.h>

#define MEM_SIZE 65536

typedef dblbyte addr_t;

void mem_write(addr_t addr, byte val);
void mem_write_chunk(addr_t addr, addr_t chunk_size, byte val[chunk_size]);
byte mem_fetch(addr_t addr);

#endif