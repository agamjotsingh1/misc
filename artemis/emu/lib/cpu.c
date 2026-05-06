#include <cpu.h>
#include <logger.h>
#include <instr.h>
#include <mem.h>
#include <regfile.h>

static cpu_ctx_t cpu_ctx;

byte gobble_byte(){
    byte val = mem_fetch(cpu_ctx.pc);
    cpu_ctx.pc += 1;
    return val;
}

val_t gobble_imm(val_type_t val_type){
    if(val_type == U_BYTE) {
        return ( VAL_U_BYTE(gobble_byte()) );
    }
    else if(val_type == U_DBLBYTE) {
        byte imm_low = gobble_byte();
        byte imm_high = gobble_byte();

        dblbyte imm = ((imm_high) << 8) & (imm_low);
        return ( VAL_U_DBLBYTE(imm) );
    }
    else if(val_type == S_BYTE) {
        return ( VAL_S_BYTE(gobble_byte()) );
    }
    else if(val_type == S_DBLBYTE) {
        byte imm_low = gobble_byte();
        byte imm_high = gobble_byte();

        dblbyte_s imm = (dblbyte_s) ((imm_high) << 8) & (imm_low);
        return ( VAL_S_DBLBYTE(imm) );
    }
    else {
        ERROR("Invalid value type requested to gobble!");
    }
}

instr_t fetch_instr(){
    byte opcode = gobble_byte();
    return parse_instr(opcode);
}


// write to location - either memory or regfile
void write_loc(op_t op, val_t val){
    // TODO!
    // Implement OT_MEM_IO_* operator types

    switch(op.type) {
        case OT_NONE:
        case OT_IMM8:
        case OT_IMM16:
        case OT_IMM8_SIGNED:
        case OT_SP_OFFSET: {
            ERROR("Requested write to OP Type NONE!");
            break;
        }

        case OT_R8: {
            if(val.type != U_BYTE) {
                ERROR("Value type (requested U_BYTE) does not match!");
            }

            write_reg(op.reg.r8, val.u_byte);
            break;
        }

        case OT_R16: {
            if(val.type != U_DBLBYTE) {
                ERROR("Value type (requested U_DBLBYTE) does not match!");
            }

            write_unif_reg(op.reg.r16, val.u_dblbyte);
            break;
        }

        case OT_MEM_R16: {
            if(val.type != U_BYTE) {
                ERROR("Value type (requested U_BYTE) does not match!");
            }

            addr_t addr = (addr_t) fetch_unif_reg(op.reg.r16);
            mem_write(addr, val.u_byte);
            break;
        }

        case OT_MEM_IMM16: {
            if(val.type != U_BYTE) {
                ERROR("Value type (requested U_BYTE) does not match!");
            }

            addr_t addr = (addr_t) (gobble_imm(U_DBLBYTE).u_dblbyte);
            mem_write(addr, val.u_byte);
            break;
        }

        case OT_MEM_HL_INC: {
            if(val.type != U_BYTE) {
                ERROR("Value type (requested U_BYTE) does not match!");
            }

            dblbyte hl_val = fetch_unif_reg(HL);
            write_unif_reg(HL, hl_val + 1);

            addr_t addr = (addr_t) hl_val;
            mem_write(addr, val.u_byte);
            break;
        }

        case OT_MEM_HL_DEC: {
            if(val.type != U_BYTE) {
                ERROR("Value type (requested U_BYTE) does not match!");
            }

            dblbyte hl_val = fetch_unif_reg(HL);
            write_unif_reg(HL, hl_val - 1);

            addr_t addr = (addr_t) hl_val;
            mem_write(addr, val.u_byte);
            break;
        }

        default: {
            ERROR("Requested write to Unknown OP Type!");
            break;
        }
    }
}

// fetch from location - either memory or regfile
val_t fetch_loc(op_t op){
    // TODO!
    // Implement OT_MEM_IO_* operator types

    switch(op.type) {
        case OT_NONE: {
            ERROR("Requested fetch from OP Type NONE!");
            break;
        }

        case OT_R8: {
            byte reg_val = fetch_reg(op.reg.r8);
            return ( VAL_U_BYTE(reg_val) );
        }

        case OT_R16: {
            dblbyte reg_val = fetch_unif_reg(op.reg.r16);
            return ( VAL_U_DBLBYTE(reg_val) );
        }

        case OT_IMM8: {
            return gobble_imm(U_BYTE);
        }

        case OT_IMM8_SIGNED: {
            return gobble_imm(S_BYTE);
        }

        case OT_IMM16: {
            return gobble_imm(U_DBLBYTE);
        }

        case OT_MEM_R16: {
            addr_t addr = (addr_t) fetch_unif_reg(op.reg.r16);
            return ( VAL_U_DBLBYTE(mem_fetch(addr)) );
        }

        case OT_MEM_IMM16: {
            addr_t addr = (addr_t) (gobble_imm(U_DBLBYTE).u_dblbyte);
            return ( VAL_U_DBLBYTE(mem_fetch(addr)) );
        }

        case OT_MEM_HL_INC: {
            dblbyte hl_val = fetch_unif_reg(HL);
            write_unif_reg(HL, hl_val + 1);

            addr_t addr = (addr_t) hl_val;
            return ( VAL_U_DBLBYTE(mem_fetch(addr)) );
        }
        
        case OT_MEM_HL_DEC: {
            dblbyte hl_val = fetch_unif_reg(HL);
            write_unif_reg(HL, hl_val - 1);

            addr_t addr = (addr_t) hl_val;
            return ( VAL_U_DBLBYTE(mem_fetch(addr)) );
        }

        case OT_SP_OFFSET: {
            dblbyte_s imm = gobble_imm(S_DBLBYTE).s_dblbyte;
            dblbyte sp_val = fetch_unif_reg(SP);

            dblbyte updated_sp_val = sp_val + imm;
            return ( VAL_U_DBLBYTE(updated_sp_val) );
        }

        default: {
            ERROR("Requested fetch from Unknown OP Type!");
            break;
        }
    }
}

void cpu_cold_start() {
    cpu_ctx.pc = ENTRY_PC;
}

void cpu_exec_once(){
    instr_t instr = fetch_instr();

    switch(instr.instr_class) {
        case IN_NONE: {
            ERROR("Invalid instruction provided!");
            break;
        }

        case IN_NOP: {
            break;
        }

        case IN_LD: {
            if(instr.op1.type == OT_NONE || instr.op2.type == OT_NONE) {
                ERROR("Invalid LD instruction operands!");
            }

            write_loc(instr.op1, fetch_loc(instr.op2));
            break;
        }

        case IN_LDH: {
            ERROR("Entered TODO territory!");

            // TODO!
            // Implement LDH
            write_loc(instr.op1, fetch_loc(instr.op2));
            break;
        }

        case IN_PUSH: {
            if(instr.op1.type != OT_R16) {
                ERROR("Invalid PUSH instruction operands!");
            }

            dblbyte reg_val = fetch_unif_reg(instr.op1.reg.r16);

            write_unif_reg(SP, fetch_unif_reg(SP) - 1);
            mem_write((addr_t) fetch_unif_reg(SP), HIGH_BYTE(reg_val));

            write_unif_reg(SP, fetch_unif_reg(SP) - 1);
            mem_write((addr_t) fetch_unif_reg(SP), LOW_BYTE(reg_val));

            break;
        }

        case IN_POP: {
            if(instr.op1.type != OT_R16) {
                ERROR("Invalid POP instruction operands!");
            }

            reg_unif_t reg = instr.op1.reg.r16;

            byte low = mem_fetch((addr_t) fetch_unif_reg(SP));
            write_unif_reg(SP, fetch_unif_reg(SP) + 1);

            byte high = mem_fetch((addr_t) fetch_unif_reg(SP));
            write_unif_reg(SP, fetch_unif_reg(SP) + 1);

            write_unif_reg(reg, STITCH(high, low));
            break;
        }

        case IN_ADD: {
            if(
                (instr.op1.type == OT_NONE || instr.op2.type == OT_NONE) ||
                (instr.op1.type != instr.op2.type)
            ) {
                ERROR("Invalid ADD instruction operands!");
            }

            // destination register value
            val_t rd_val = fetch_loc(instr.op1);

            // source register value
            val_t rs_val = fetch_loc(instr.op2);

            // result = rd_val + rs_val

            // 8-bit rd
            // flags.Z = 1 if result == 0 else 0
            // flags.N = 0
            // flags.H = 1 if carry_per_bit[3] else 0
            // flags.C = 1 if carry_per_bit[7] else 0

            if(instr.op1.type == OT_R8) {
                byte carry = 0;
                byte result = 0;

                for(byte i = 0; i < 8; i++){
                    byte rd_bit = FETCH_BIT(rd_val.u_byte, i);
                    byte rs_bit = FETCH_BIT(rs_val.u_byte, i);
                    byte subres = rd_bit + rs_bit + carry;

                    WRITE_BIT(result, i, (subres) & 0x1);
                    carry = subres & 0x2;

                    if(i == 3) {
                        if(carry) set_flag(h);
                        else clear_flag(h);
                    }
                    else if(i == 7) {
                        if(carry) set_flag(c);
                        else clear_flag(c);
                    }
                }

                if(result == 0) set_flag(z);
                else clear_flag(z);

                clear_flag(n);
            }
            else if(instr.op1.type == OT_R16) {
                byte carry = 0;
                dblbyte result = 0;

                for(byte i = 0; i < 16; i++){
                    byte rd_bit = FETCH_BIT(rd_val.u_dblbyte, i);
                    byte rs_bit = FETCH_BIT(rs_val.u_dblbyte, i);
                    byte subres = rd_bit + rs_bit + carry;

                    WRITE_BIT(result, i, (subres) & 0x1);
                    carry = subres & 0x2;

                    if(i == 11) {
                        if(carry) set_flag(h);
                        else clear_flag(h);
                    }
                    else if(i == 15) {
                        if(carry) set_flag(c);
                        else clear_flag(c);
                    }
                }

                clear_flag(n);
            }

        }
        
        default: {
            ERROR("Invalid/Unimplemented instruction class (%d)!", instr.instr_class);
            break;
        }
    }
}