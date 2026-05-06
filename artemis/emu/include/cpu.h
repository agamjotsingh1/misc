#ifndef CPU_DEF
#define CPU_DEF

#include <byte.h>
#include <mem.h>

#define ENTRY_PC 0x100

typedef struct {
    addr_t pc;
} cpu_ctx_t;


void cpu_cold_start();
void cpu_exec_once();

#endif