#include <mem.h>
#include <logger.h>
#include <byte.h>

static byte mem[MEM_SIZE];

void mem_write(addr_t addr, byte val){
    if(addr >= MEM_SIZE) {
        ERROR("Memory 0b(%b) out of range!", addr);
    }

    mem[addr] = val;
}

void mem_write_chunk(addr_t addr, addr_t chunk_size, byte val[chunk_size]){
    if(addr + chunk_size >= MEM_SIZE) {
        ERROR("Memory chunk leaking out of range!");
    }

    for(dblbyte i = 0; i < chunk_size; i++){
        mem_write(addr + i, val[i]);
    }
}

byte mem_fetch(addr_t addr){
    if(addr >= MEM_SIZE) {
        ERROR("Memory 0b(%b) out of range!", addr);
    }

    return mem[addr];
}