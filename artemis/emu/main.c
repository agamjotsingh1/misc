#include <stdio.h>
#include <stdint.h>

#include <cpu.h>
#include <regfile.h>
#include <logger.h>

int main(){
    // cart_load("roms/pokemon_red.gb");
    // cart_load("roms/dmg-acid2.gb");

    // write_reg(A, 0x12);
    // write_unif_reg(SP, 0x1234);
    // mem_write(ENTRY_PC, 0x47); // LD B, A
    // DEBUG("B value = %x", fetch_reg(B));

    // cpu_cold_start();
    // cpu_exec_once();

    // DEBUG("B value = %x", fetch_reg(B));

    // mem_write(ENTRY_PC + 1, 0x50); // LD D, B
    // DEBUG("D value = %x", fetch_reg(D));

    // cpu_exec_once();

    // DEBUG("D value = %x", fetch_reg(D));

    // mem_write(ENTRY_PC + 2, 0x0E); // LD C, n8
    // mem_write(ENTRY_PC + 3, 0xCC);
    // DEBUG("C value = %x", fetch_reg(C));

    // cpu_exec_once();

    // DEBUG("C value = %x", fetch_reg(C));

    // write_unif_reg(BC, 0x5678);
    // mem_write(ENTRY_PC + 4, 0xC5); // PUSH BC
    // mem_write(ENTRY_PC + 5, 0x0E); // LD C, n8
    // mem_write(ENTRY_PC + 6, 0xAA); // n8 value
    // mem_write(ENTRY_PC + 7, 0xC1); // POP BC
    // DEBUG("BC value = %x", fetch_unif_reg(BC));

    // cpu_exec_once();

    // DEBUG("BC value = %x", fetch_unif_reg(BC));

    // cpu_exec_once();

    // DEBUG("BC value = %x", fetch_unif_reg(BC));


    // cpu_exec_once();

    // DEBUG("BC value = %x", fetch_unif_reg(BC));


    write_reg(A, 0x12);


    return 0;
}
