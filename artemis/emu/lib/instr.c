#include <instr.h>

static const instr_t INSTR_LOOKUP[256] = {
    // 0x00 - 0x0F
    [0x00] = INSTR(4, 1, IN_NOP, OP_NONE, OP_NONE, CT_NONE),
    [0x01] = INSTR(12, 3, IN_LD, OP_R16(BC), OP_IMM16, CT_NONE),
    [0x02] = INSTR(8, 1, IN_LD, OP_MEM_R16(BC), OP_R8(A), CT_NONE),
    [0x03] = INSTR(8, 1, IN_INC, OP_R16(BC), OP_NONE, CT_NONE),
    [0x04] = INSTR(4, 1, IN_INC, OP_R8(B), OP_NONE, CT_NONE),
    [0x05] = INSTR(4, 1, IN_DEC, OP_R8(B), OP_NONE, CT_NONE),
    [0x06] = INSTR(8, 2, IN_LD, OP_R8(B), OP_IMM8, CT_NONE),
    [0x07] = INSTR(4, 1, IN_RLCA, OP_NONE, OP_NONE, CT_NONE),
    [0x08] = INSTR(20, 3, IN_LD, OP_MEM_IMM16, OP_R16(SP), CT_NONE),
    [0x09] = INSTR(8, 1, IN_ADD, OP_R16(HL), OP_R16(BC), CT_NONE),
    [0x0A] = INSTR(8, 1, IN_LD, OP_R8(A), OP_MEM_R16(BC), CT_NONE),
    [0x0B] = INSTR(8, 1, IN_DEC, OP_R16(BC), OP_NONE, CT_NONE),
    [0x0C] = INSTR(4, 1, IN_INC, OP_R8(C), OP_NONE, CT_NONE),
    [0x0D] = INSTR(4, 1, IN_DEC, OP_R8(C), OP_NONE, CT_NONE),
    [0x0E] = INSTR(8, 2, IN_LD, OP_R8(C), OP_IMM8, CT_NONE),
    [0x0F] = INSTR(4, 1, IN_RRCA, OP_NONE, OP_NONE, CT_NONE),

    // 0x10 - 0x1F
    [0x10] = INSTR(4, 2, IN_STOP, OP_NONE, OP_NONE, CT_NONE),
    [0x11] = INSTR(12, 3, IN_LD, OP_R16(DE), OP_IMM16, CT_NONE),
    [0x12] = INSTR(8, 1, IN_LD, OP_MEM_R16(DE), OP_R8(A), CT_NONE),
    [0x13] = INSTR(8, 1, IN_INC, OP_R16(DE), OP_NONE, CT_NONE),
    [0x14] = INSTR(4, 1, IN_INC, OP_R8(D), OP_NONE, CT_NONE),
    [0x15] = INSTR(4, 1, IN_DEC, OP_R8(D), OP_NONE, CT_NONE),
    [0x16] = INSTR(8, 2, IN_LD, OP_R8(D), OP_IMM8, CT_NONE),
    [0x17] = INSTR(4, 1, IN_RLA, OP_NONE, OP_NONE, CT_NONE),
    [0x18] = INSTR(12, 2, IN_JR, OP_IMM8_S, OP_NONE, CT_NONE),
    [0x19] = INSTR(8, 1, IN_ADD, OP_R16(HL), OP_R16(DE), CT_NONE),
    [0x1A] = INSTR(8, 1, IN_LD, OP_R8(A), OP_MEM_R16(DE), CT_NONE),
    [0x1B] = INSTR(8, 1, IN_DEC, OP_R16(DE), OP_NONE, CT_NONE),
    [0x1C] = INSTR(4, 1, IN_INC, OP_R8(E), OP_NONE, CT_NONE),
    [0x1D] = INSTR(4, 1, IN_DEC, OP_R8(E), OP_NONE, CT_NONE),
    [0x1E] = INSTR(8, 2, IN_LD, OP_R8(E), OP_IMM8, CT_NONE),
    [0x1F] = INSTR(4, 1, IN_RRA, OP_NONE, OP_NONE, CT_NONE),

    // 0x20 - 0x2F
    [0x20] = INSTR(8, 2, IN_JR, OP_IMM8_S, OP_NONE, CT_NZ),
    [0x21] = INSTR(12, 3, IN_LD, OP_R16(HL), OP_IMM16, CT_NONE),
    [0x22] = INSTR(8, 1, IN_LD, OP_HL_INC, OP_R8(A), CT_NONE),
    [0x23] = INSTR(8, 1, IN_INC, OP_R16(HL), OP_NONE, CT_NONE),
    [0x24] = INSTR(4, 1, IN_INC, OP_R8(H), OP_NONE, CT_NONE),
    [0x25] = INSTR(4, 1, IN_DEC, OP_R8(H), OP_NONE, CT_NONE),
    [0x26] = INSTR(8, 2, IN_LD, OP_R8(H), OP_IMM8, CT_NONE),
    [0x27] = INSTR(4, 1, IN_DAA, OP_NONE, OP_NONE, CT_NONE),
    [0x28] = INSTR(8, 2, IN_JR, OP_IMM8_S, OP_NONE, CT_Z),
    [0x29] = INSTR(8, 1, IN_ADD, OP_R16(HL), OP_R16(HL), CT_NONE),
    [0x2A] = INSTR(8, 1, IN_LD, OP_R8(A), OP_HL_INC, CT_NONE),
    [0x2B] = INSTR(8, 1, IN_DEC, OP_R16(HL), OP_NONE, CT_NONE),
    [0x2C] = INSTR(4, 1, IN_INC, OP_R8(L), OP_NONE, CT_NONE),
    [0x2D] = INSTR(4, 1, IN_DEC, OP_R8(L), OP_NONE, CT_NONE),
    [0x2E] = INSTR(8, 2, IN_LD, OP_R8(L), OP_IMM8, CT_NONE),
    [0x2F] = INSTR(4, 1, IN_CPL, OP_NONE, OP_NONE, CT_NONE),

    // 0x30 - 0x3F
    [0x30] = INSTR(8, 2, IN_JR, OP_IMM8_S, OP_NONE, CT_NC),
    [0x31] = INSTR(12, 3, IN_LD, OP_R16(SP), OP_IMM16, CT_NONE),
    [0x32] = INSTR(8, 1, IN_LD, OP_HL_DEC, OP_R8(A), CT_NONE),
    [0x33] = INSTR(8, 1, IN_INC, OP_R16(SP), OP_NONE, CT_NONE),
    [0x34] = INSTR(12, 1, IN_INC, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x35] = INSTR(12, 1, IN_DEC, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x36] = INSTR(12, 2, IN_LD, OP_MEM_R16(HL), OP_IMM8, CT_NONE),
    [0x37] = INSTR(4, 1, IN_SCF, OP_NONE, OP_NONE, CT_NONE),
    [0x38] = INSTR(8, 2, IN_JR, OP_IMM8_S, OP_NONE, CT_C),
    [0x39] = INSTR(8, 1, IN_ADD, OP_R16(HL), OP_R16(SP), CT_NONE),
    [0x3A] = INSTR(8, 1, IN_LD, OP_R8(A), OP_HL_DEC, CT_NONE),
    [0x3B] = INSTR(8, 1, IN_DEC, OP_R16(SP), OP_NONE, CT_NONE),
    [0x3C] = INSTR(4, 1, IN_INC, OP_R8(A), OP_NONE, CT_NONE),
    [0x3D] = INSTR(4, 1, IN_DEC, OP_R8(A), OP_NONE, CT_NONE),
    [0x3E] = INSTR(8, 2, IN_LD, OP_R8(A), OP_IMM8, CT_NONE),
    [0x3F] = INSTR(4, 1, IN_CCF, OP_NONE, OP_NONE, CT_NONE),

    // 0x40 - 0x47 (LD B, y)
    [0x40] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(B), CT_NONE),
    [0x41] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(C), CT_NONE),
    [0x42] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(D), CT_NONE),
    [0x43] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(E), CT_NONE),
    [0x44] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(H), CT_NONE),
    [0x45] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(L), CT_NONE),
    [0x46] = INSTR(8, 1, IN_LD, OP_R8(B), OP_MEM_R16(HL), CT_NONE),
    [0x47] = INSTR(4, 1, IN_LD, OP_R8(B), OP_R8(A), CT_NONE),

    // 0x48 - 0x4F (LD C, y)
    [0x48] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(B), CT_NONE),
    [0x49] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(C), CT_NONE),
    [0x4A] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(D), CT_NONE),
    [0x4B] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(E), CT_NONE),
    [0x4C] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(H), CT_NONE),
    [0x4D] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(L), CT_NONE),
    [0x4E] = INSTR(8, 1, IN_LD, OP_R8(C), OP_MEM_R16(HL), CT_NONE),
    [0x4F] = INSTR(4, 1, IN_LD, OP_R8(C), OP_R8(A), CT_NONE),

    // 0x50 - 0x57 (LD D, y)
    [0x50] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(B), CT_NONE),
    [0x51] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(C), CT_NONE),
    [0x52] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(D), CT_NONE),
    [0x53] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(E), CT_NONE),
    [0x54] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(H), CT_NONE),
    [0x55] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(L), CT_NONE),
    [0x56] = INSTR(8, 1, IN_LD, OP_R8(D), OP_MEM_R16(HL), CT_NONE),
    [0x57] = INSTR(4, 1, IN_LD, OP_R8(D), OP_R8(A), CT_NONE),

    // 0x58 - 0x5F (LD E, y)
    [0x58] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(B), CT_NONE),
    [0x59] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(C), CT_NONE),
    [0x5A] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(D), CT_NONE),
    [0x5B] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(E), CT_NONE),
    [0x5C] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(H), CT_NONE),
    [0x5D] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(L), CT_NONE),
    [0x5E] = INSTR(8, 1, IN_LD, OP_R8(E), OP_MEM_R16(HL), CT_NONE),
    [0x5F] = INSTR(4, 1, IN_LD, OP_R8(E), OP_R8(A), CT_NONE),

    // 0x60 - 0x67 (LD H, y)
    [0x60] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(B), CT_NONE),
    [0x61] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(C), CT_NONE),
    [0x62] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(D), CT_NONE),
    [0x63] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(E), CT_NONE),
    [0x64] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(H), CT_NONE),
    [0x65] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(L), CT_NONE),
    [0x66] = INSTR(8, 1, IN_LD, OP_R8(H), OP_MEM_R16(HL), CT_NONE),
    [0x67] = INSTR(4, 1, IN_LD, OP_R8(H), OP_R8(A), CT_NONE),

    // 0x68 - 0x6F (LD L, y)
    [0x68] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(B), CT_NONE),
    [0x69] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(C), CT_NONE),
    [0x6A] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(D), CT_NONE),
    [0x6B] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(E), CT_NONE),
    [0x6C] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(H), CT_NONE),
    [0x6D] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(L), CT_NONE),
    [0x6E] = INSTR(8, 1, IN_LD, OP_R8(L), OP_MEM_R16(HL), CT_NONE),
    [0x6F] = INSTR(4, 1, IN_LD, OP_R8(L), OP_R8(A), CT_NONE),

    // 0x70 - 0x77 (LD (HL), y) and HALT
    [0x70] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(B), CT_NONE),
    [0x71] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(C), CT_NONE),
    [0x72] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(D), CT_NONE),
    [0x73] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(E), CT_NONE),
    [0x74] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(H), CT_NONE),
    [0x75] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(L), CT_NONE),
    [0x76] = INSTR(4, 1, IN_HALT, OP_NONE, OP_NONE, CT_NONE),
    [0x77] = INSTR(8, 1, IN_LD, OP_MEM_R16(HL), OP_R8(A), CT_NONE),

    // 0x78 - 0x7F (LD A, y)
    [0x78] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(B), CT_NONE),
    [0x79] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(C), CT_NONE),
    [0x7A] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(D), CT_NONE),
    [0x7B] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(E), CT_NONE),
    [0x7C] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(H), CT_NONE),
    [0x7D] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(L), CT_NONE),
    [0x7E] = INSTR(8, 1, IN_LD, OP_R8(A), OP_MEM_R16(HL), CT_NONE),
    [0x7F] = INSTR(4, 1, IN_LD, OP_R8(A), OP_R8(A), CT_NONE),

    // 0x80 - 0x87 (ADD A, y)
    [0x80] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(B), CT_NONE),
    [0x81] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(C), CT_NONE),
    [0x82] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(D), CT_NONE),
    [0x83] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(E), CT_NONE),
    [0x84] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(H), CT_NONE),
    [0x85] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(L), CT_NONE),
    [0x86] = INSTR(8, 1, IN_ADD, OP_R8(A), OP_MEM_R16(HL), CT_NONE),
    [0x87] = INSTR(4, 1, IN_ADD, OP_R8(A), OP_R8(A), CT_NONE),

    // 0x88 - 0x8F (ADC A, y)
    [0x88] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(B), CT_NONE),
    [0x89] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(C), CT_NONE),
    [0x8A] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(D), CT_NONE),
    [0x8B] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(E), CT_NONE),
    [0x8C] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(H), CT_NONE),
    [0x8D] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(L), CT_NONE),
    [0x8E] = INSTR(8, 1, IN_ADC, OP_R8(A), OP_MEM_R16(HL), CT_NONE),
    [0x8F] = INSTR(4, 1, IN_ADC, OP_R8(A), OP_R8(A), CT_NONE),

    // 0x90 - 0x97 (SUB A, y) -> dest A implied
    [0x90] = INSTR(4, 1, IN_SUB, OP_R8(B), OP_NONE, CT_NONE),
    [0x91] = INSTR(4, 1, IN_SUB, OP_R8(C), OP_NONE, CT_NONE),
    [0x92] = INSTR(4, 1, IN_SUB, OP_R8(D), OP_NONE, CT_NONE),
    [0x93] = INSTR(4, 1, IN_SUB, OP_R8(E), OP_NONE, CT_NONE),
    [0x94] = INSTR(4, 1, IN_SUB, OP_R8(H), OP_NONE, CT_NONE),
    [0x95] = INSTR(4, 1, IN_SUB, OP_R8(L), OP_NONE, CT_NONE),
    [0x96] = INSTR(8, 1, IN_SUB, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x97] = INSTR(4, 1, IN_SUB, OP_R8(A), OP_NONE, CT_NONE),

    // 0x98 - 0x9F (SBC A, y) -> dest A implied
    [0x98] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(B), CT_NONE),
    [0x99] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(C), CT_NONE),
    [0x9A] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(D), CT_NONE),
    [0x9B] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(E), CT_NONE),
    [0x9C] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(H), CT_NONE),
    [0x9D] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(L), CT_NONE),
    [0x9E] = INSTR(8, 1, IN_SBC, OP_R8(A), OP_MEM_R16(HL), CT_NONE),
    [0x9F] = INSTR(4, 1, IN_SBC, OP_R8(A), OP_R8(A), CT_NONE),

    // 0xA0 - 0xA7 (AND y) -> dest A implied
    [0xA0] = INSTR(4, 1, IN_AND, OP_R8(B), OP_NONE, CT_NONE),
    [0xA1] = INSTR(4, 1, IN_AND, OP_R8(C), OP_NONE, CT_NONE),
    [0xA2] = INSTR(4, 1, IN_AND, OP_R8(D), OP_NONE, CT_NONE),
    [0xA3] = INSTR(4, 1, IN_AND, OP_R8(E), OP_NONE, CT_NONE),
    [0xA4] = INSTR(4, 1, IN_AND, OP_R8(H), OP_NONE, CT_NONE),
    [0xA5] = INSTR(4, 1, IN_AND, OP_R8(L), OP_NONE, CT_NONE),
    [0xA6] = INSTR(8, 1, IN_AND, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0xA7] = INSTR(4, 1, IN_AND, OP_R8(A), OP_NONE, CT_NONE),

    // 0xA8 - 0xAF (XOR y) -> dest A implied
    [0xA8] = INSTR(4, 1, IN_XOR, OP_R8(B), OP_NONE, CT_NONE),
    [0xA9] = INSTR(4, 1, IN_XOR, OP_R8(C), OP_NONE, CT_NONE),
    [0xAA] = INSTR(4, 1, IN_XOR, OP_R8(D), OP_NONE, CT_NONE),
    [0xAB] = INSTR(4, 1, IN_XOR, OP_R8(E), OP_NONE, CT_NONE),
    [0xAC] = INSTR(4, 1, IN_XOR, OP_R8(H), OP_NONE, CT_NONE),
    [0xAD] = INSTR(4, 1, IN_XOR, OP_R8(L), OP_NONE, CT_NONE),
    [0xAE] = INSTR(8, 1, IN_XOR, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0xAF] = INSTR(4, 1, IN_XOR, OP_R8(A), OP_NONE, CT_NONE),

    // 0xB0 - 0xB7 (OR y) -> dest A implied
    [0xB0] = INSTR(4, 1, IN_OR, OP_R8(B), OP_NONE, CT_NONE),
    [0xB1] = INSTR(4, 1, IN_OR, OP_R8(C), OP_NONE, CT_NONE),
    [0xB2] = INSTR(4, 1, IN_OR, OP_R8(D), OP_NONE, CT_NONE),
    [0xB3] = INSTR(4, 1, IN_OR, OP_R8(E), OP_NONE, CT_NONE),
    [0xB4] = INSTR(4, 1, IN_OR, OP_R8(H), OP_NONE, CT_NONE),
    [0xB5] = INSTR(4, 1, IN_OR, OP_R8(L), OP_NONE, CT_NONE),
    [0xB6] = INSTR(8, 1, IN_OR, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0xB7] = INSTR(4, 1, IN_OR, OP_R8(A), OP_NONE, CT_NONE),

    // 0xB8 - 0xBF (CP y) -> dest A implied
    [0xB8] = INSTR(4, 1, IN_CP, OP_R8(B), OP_NONE, CT_NONE),
    [0xB9] = INSTR(4, 1, IN_CP, OP_R8(C), OP_NONE, CT_NONE),
    [0xBA] = INSTR(4, 1, IN_CP, OP_R8(D), OP_NONE, CT_NONE),
    [0xBB] = INSTR(4, 1, IN_CP, OP_R8(E), OP_NONE, CT_NONE),
    [0xBC] = INSTR(4, 1, IN_CP, OP_R8(H), OP_NONE, CT_NONE),
    [0xBD] = INSTR(4, 1, IN_CP, OP_R8(L), OP_NONE, CT_NONE),
    [0xBE] = INSTR(8, 1, IN_CP, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0xBF] = INSTR(4, 1, IN_CP, OP_R8(A), OP_NONE, CT_NONE),

    // 0xC0 - 0xCF
    [0xC0] = INSTR(8, 1, IN_RET, OP_NONE, OP_NONE, CT_NZ),
    [0xC1] = INSTR(12, 1, IN_POP, OP_R16(BC), OP_NONE, CT_NONE),
    [0xC2] = INSTR(12, 3, IN_JP, OP_IMM16, OP_NONE, CT_NZ),
    [0xC3] = INSTR(16, 3, IN_JP, OP_IMM16, OP_NONE, CT_NONE),
    [0xC4] = INSTR(12, 3, IN_CALL, OP_IMM16, OP_NONE, CT_NZ),
    [0xC5] = INSTR(16, 1, IN_PUSH, OP_R16(BC), OP_NONE, CT_NONE),
    [0xC6] = INSTR(8, 2, IN_ADD, OP_R8(A), OP_IMM8, CT_NONE),
    [0xC7] = INSTR(16, 1, IN_RST, OP_FIX(0x00), OP_NONE, CT_NONE),
    [0xC8] = INSTR(8, 1, IN_RET, OP_NONE, OP_NONE, CT_Z),
    [0xC9] = INSTR(16, 1, IN_RET, OP_NONE, OP_NONE, CT_NONE),
    [0xCA] = INSTR(12, 3, IN_JP, OP_IMM16, OP_NONE, CT_Z),
    [0xCB] = INSTR(4, 1, IN_NONE, OP_NONE, OP_NONE, CT_NONE), // PREFIX
    [0xCC] = INSTR(12, 3, IN_CALL, OP_IMM16, OP_NONE, CT_Z),
    [0xCD] = INSTR(24, 3, IN_CALL, OP_IMM16, OP_NONE, CT_NONE),
    [0xCE] = INSTR(8, 2, IN_ADC, OP_R8(A), OP_IMM8, CT_NONE),
    [0xCF] = INSTR(16, 1, IN_RST, OP_FIX(0x08), OP_NONE, CT_NONE),

    // 0xD0 - 0xDF
    [0xD0] = INSTR(8, 1, IN_RET, OP_NONE, OP_NONE, CT_NC),
    [0xD1] = INSTR(12, 1, IN_POP, OP_R16(DE), OP_NONE, CT_NONE),
    [0xD2] = INSTR(12, 3, IN_JP, OP_IMM16, OP_NONE, CT_NC),
    [0xD3] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xD4] = INSTR(12, 3, IN_CALL, OP_IMM16, OP_NONE, CT_NC),
    [0xD5] = INSTR(16, 1, IN_PUSH, OP_R16(DE), OP_NONE, CT_NONE),
    [0xD6] = INSTR(8, 2, IN_SUB, OP_IMM8, OP_NONE, CT_NONE),
    [0xD7] = INSTR(16, 1, IN_RST, OP_FIX(0x10), OP_NONE, CT_NONE),
    [0xD8] = INSTR(8, 1, IN_RET, OP_NONE, OP_NONE, CT_C),
    [0xD9] = INSTR(16, 1, IN_RETI, OP_NONE, OP_NONE, CT_NONE),
    [0xDA] = INSTR(12, 3, IN_JP, OP_IMM16, OP_NONE, CT_C),
    [0xDB] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xDC] = INSTR(12, 3, IN_CALL, OP_IMM16, OP_NONE, CT_C),
    [0xDD] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xDE] = INSTR(8, 2, IN_SBC, OP_R8(A), OP_IMM8, CT_NONE),
    [0xDF] = INSTR(16, 1, IN_RST, OP_FIX(0x18), OP_NONE, CT_NONE),

    // 0xE0 - 0xEF
    [0xE0] = INSTR(12, 2, IN_LDH, OP_IO_IMM8, OP_R8(A), CT_NONE),
    [0xE1] = INSTR(12, 1, IN_POP, OP_R16(HL), OP_NONE, CT_NONE),
    [0xE2] = INSTR(8, 1, IN_LDH, OP_IO_C, OP_R8(A), CT_NONE),
    [0xE3] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xE4] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xE5] = INSTR(16, 1, IN_PUSH, OP_R16(HL), OP_NONE, CT_NONE),
    [0xE6] = INSTR(8, 2, IN_AND, OP_IMM8, OP_NONE, CT_NONE),
    [0xE7] = INSTR(16, 1, IN_RST, OP_FIX(0x20), OP_NONE, CT_NONE),
    [0xE8] = INSTR(16, 2, IN_ADD, OP_R16(SP), OP_IMM8_S, CT_NONE),
    [0xE9] = INSTR(4, 1, IN_JP, OP_R16(HL), OP_NONE, CT_NONE),
    [0xEA] = INSTR(16, 3, IN_LD, OP_MEM_IMM16, OP_R8(A), CT_NONE),
    [0xEB] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xEC] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xED] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xEE] = INSTR(8, 2, IN_XOR, OP_IMM8, OP_NONE, CT_NONE),
    [0xEF] = INSTR(16, 1, IN_RST, OP_FIX(0x28), OP_NONE, CT_NONE),

    // 0xF0 - 0xFF
    [0xF0] = INSTR(12, 2, IN_LDH, OP_R8(A), OP_IO_IMM8, CT_NONE),
    [0xF1] = INSTR(12, 1, IN_POP, OP_R16(AF), OP_NONE, CT_NONE),
    [0xF2] = INSTR(8, 1, IN_LDH, OP_R8(A), OP_IO_C, CT_NONE),
    [0xF3] = INSTR(4, 1, IN_DI, OP_NONE, OP_NONE, CT_NONE),
    [0xF4] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xF5] = INSTR(16, 1, IN_PUSH, OP_R16(AF), OP_NONE, CT_NONE),
    [0xF6] = INSTR(8, 2, IN_OR, OP_IMM8, OP_NONE, CT_NONE),
    [0xF7] = INSTR(16, 1, IN_RST, OP_FIX(0x30), OP_NONE, CT_NONE),
    [0xF8] = INSTR(12, 2, IN_LD, OP_R16(HL), OP_SP_OFF, CT_NONE),
    [0xF9] = INSTR(8, 1, IN_LD, OP_R16(SP), OP_R16(HL), CT_NONE),
    [0xFA] = INSTR(16, 3, IN_LD, OP_R8(A), OP_MEM_IMM16, CT_NONE),
    [0xFB] = INSTR(4, 1, IN_EI, OP_NONE, OP_NONE, CT_NONE),
    [0xFC] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xFD] = INSTR(0, 0, IN_NONE, OP_NONE, OP_NONE, CT_NONE),
    [0xFE] = INSTR(8, 2, IN_CP, OP_IMM8, OP_NONE, CT_NONE),
    [0xFF] = INSTR(16, 1, IN_RST, OP_FIX(0x38), OP_NONE, CT_NONE)
};

static const instr_t CB_INSTR_LOOKUP[256] = {
    // 0x00 - 0x07 (RLC)
    [0x00] = INSTR(8, 2, IN_RLC, OP_R8(B), OP_NONE, CT_NONE),
    [0x01] = INSTR(8, 2, IN_RLC, OP_R8(C), OP_NONE, CT_NONE),
    [0x02] = INSTR(8, 2, IN_RLC, OP_R8(D), OP_NONE, CT_NONE),
    [0x03] = INSTR(8, 2, IN_RLC, OP_R8(E), OP_NONE, CT_NONE),
    [0x04] = INSTR(8, 2, IN_RLC, OP_R8(H), OP_NONE, CT_NONE),
    [0x05] = INSTR(8, 2, IN_RLC, OP_R8(L), OP_NONE, CT_NONE),
    [0x06] = INSTR(16, 2, IN_RLC, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x07] = INSTR(8, 2, IN_RLC, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x08 - 0x0F (RRC)
    [0x08] = INSTR(8, 2, IN_RRC, OP_R8(B), OP_NONE, CT_NONE),
    [0x09] = INSTR(8, 2, IN_RRC, OP_R8(C), OP_NONE, CT_NONE),
    [0x0A] = INSTR(8, 2, IN_RRC, OP_R8(D), OP_NONE, CT_NONE),
    [0x0B] = INSTR(8, 2, IN_RRC, OP_R8(E), OP_NONE, CT_NONE),
    [0x0C] = INSTR(8, 2, IN_RRC, OP_R8(H), OP_NONE, CT_NONE),
    [0x0D] = INSTR(8, 2, IN_RRC, OP_R8(L), OP_NONE, CT_NONE),
    [0x0E] = INSTR(16, 2, IN_RRC, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x0F] = INSTR(8, 2, IN_RRC, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x10 - 0x17 (RL)
    [0x10] = INSTR(8, 2, IN_RL, OP_R8(B), OP_NONE, CT_NONE),
    [0x11] = INSTR(8, 2, IN_RL, OP_R8(C), OP_NONE, CT_NONE),
    [0x12] = INSTR(8, 2, IN_RL, OP_R8(D), OP_NONE, CT_NONE),
    [0x13] = INSTR(8, 2, IN_RL, OP_R8(E), OP_NONE, CT_NONE),
    [0x14] = INSTR(8, 2, IN_RL, OP_R8(H), OP_NONE, CT_NONE),
    [0x15] = INSTR(8, 2, IN_RL, OP_R8(L), OP_NONE, CT_NONE),
    [0x16] = INSTR(16, 2, IN_RL, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x17] = INSTR(8, 2, IN_RL, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x18 - 0x1F (RR)
    [0x18] = INSTR(8, 2, IN_RR, OP_R8(B), OP_NONE, CT_NONE),
    [0x19] = INSTR(8, 2, IN_RR, OP_R8(C), OP_NONE, CT_NONE),
    [0x1A] = INSTR(8, 2, IN_RR, OP_R8(D), OP_NONE, CT_NONE),
    [0x1B] = INSTR(8, 2, IN_RR, OP_R8(E), OP_NONE, CT_NONE),
    [0x1C] = INSTR(8, 2, IN_RR, OP_R8(H), OP_NONE, CT_NONE),
    [0x1D] = INSTR(8, 2, IN_RR, OP_R8(L), OP_NONE, CT_NONE),
    [0x1E] = INSTR(16, 2, IN_RR, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x1F] = INSTR(8, 2, IN_RR, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x20 - 0x27 (SLA)
    [0x20] = INSTR(8, 2, IN_SLA, OP_R8(B), OP_NONE, CT_NONE),
    [0x21] = INSTR(8, 2, IN_SLA, OP_R8(C), OP_NONE, CT_NONE),
    [0x22] = INSTR(8, 2, IN_SLA, OP_R8(D), OP_NONE, CT_NONE),
    [0x23] = INSTR(8, 2, IN_SLA, OP_R8(E), OP_NONE, CT_NONE),
    [0x24] = INSTR(8, 2, IN_SLA, OP_R8(H), OP_NONE, CT_NONE),
    [0x25] = INSTR(8, 2, IN_SLA, OP_R8(L), OP_NONE, CT_NONE),
    [0x26] = INSTR(16, 2, IN_SLA, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x27] = INSTR(8, 2, IN_SLA, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x28 - 0x2F (SRA)
    [0x28] = INSTR(8, 2, IN_SRA, OP_R8(B), OP_NONE, CT_NONE),
    [0x29] = INSTR(8, 2, IN_SRA, OP_R8(C), OP_NONE, CT_NONE),
    [0x2A] = INSTR(8, 2, IN_SRA, OP_R8(D), OP_NONE, CT_NONE),
    [0x2B] = INSTR(8, 2, IN_SRA, OP_R8(E), OP_NONE, CT_NONE),
    [0x2C] = INSTR(8, 2, IN_SRA, OP_R8(H), OP_NONE, CT_NONE),
    [0x2D] = INSTR(8, 2, IN_SRA, OP_R8(L), OP_NONE, CT_NONE),
    [0x2E] = INSTR(16, 2, IN_SRA, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x2F] = INSTR(8, 2, IN_SRA, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x30 - 0x37 (SWAP)
    [0x30] = INSTR(8, 2, IN_SWAP, OP_R8(B), OP_NONE, CT_NONE),
    [0x31] = INSTR(8, 2, IN_SWAP, OP_R8(C), OP_NONE, CT_NONE),
    [0x32] = INSTR(8, 2, IN_SWAP, OP_R8(D), OP_NONE, CT_NONE),
    [0x33] = INSTR(8, 2, IN_SWAP, OP_R8(E), OP_NONE, CT_NONE),
    [0x34] = INSTR(8, 2, IN_SWAP, OP_R8(H), OP_NONE, CT_NONE),
    [0x35] = INSTR(8, 2, IN_SWAP, OP_R8(L), OP_NONE, CT_NONE),
    [0x36] = INSTR(16, 2, IN_SWAP, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x37] = INSTR(8, 2, IN_SWAP, OP_R8(A), OP_NONE, CT_NONE),
    
    // 0x38 - 0x3F (SRL)
    [0x38] = INSTR(8, 2, IN_SRL, OP_R8(B), OP_NONE, CT_NONE),
    [0x39] = INSTR(8, 2, IN_SRL, OP_R8(C), OP_NONE, CT_NONE),
    [0x3A] = INSTR(8, 2, IN_SRL, OP_R8(D), OP_NONE, CT_NONE),
    [0x3B] = INSTR(8, 2, IN_SRL, OP_R8(E), OP_NONE, CT_NONE),
    [0x3C] = INSTR(8, 2, IN_SRL, OP_R8(H), OP_NONE, CT_NONE),
    [0x3D] = INSTR(8, 2, IN_SRL, OP_R8(L), OP_NONE, CT_NONE),
    [0x3E] = INSTR(16, 2, IN_SRL, OP_MEM_R16(HL), OP_NONE, CT_NONE),
    [0x3F] = INSTR(8, 2, IN_SRL, OP_R8(A), OP_NONE, CT_NONE),

    // 0x40 - 0x47 (BIT 0)
    [0x40] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(B), CT_NONE),
    [0x41] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(C), CT_NONE),
    [0x42] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(D), CT_NONE),
    [0x43] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(E), CT_NONE),
    [0x44] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(H), CT_NONE),
    [0x45] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(L), CT_NONE),
    [0x46] = INSTR(12, 2, IN_BIT, OP_FIX(0), OP_MEM_R16(HL), CT_NONE),
    [0x47] = INSTR(8, 2, IN_BIT, OP_FIX(0), OP_R8(A), CT_NONE),

    // 0x48 - 0x4F (BIT 1)
    [0x48] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(B), CT_NONE),
    [0x49] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(C), CT_NONE),
    [0x4A] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(D), CT_NONE),
    [0x4B] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(E), CT_NONE),
    [0x4C] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(H), CT_NONE),
    [0x4D] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(L), CT_NONE),
    [0x4E] = INSTR(12, 2, IN_BIT, OP_FIX(1), OP_MEM_R16(HL), CT_NONE),
    [0x4F] = INSTR(8, 2, IN_BIT, OP_FIX(1), OP_R8(A), CT_NONE),

    // 0x50 - 0x57 (BIT 2)
    [0x50] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(B), CT_NONE),
    [0x51] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(C), CT_NONE),
    [0x52] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(D), CT_NONE),
    [0x53] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(E), CT_NONE),
    [0x54] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(H), CT_NONE),
    [0x55] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(L), CT_NONE),
    [0x56] = INSTR(12, 2, IN_BIT, OP_FIX(2), OP_MEM_R16(HL), CT_NONE),
    [0x57] = INSTR(8, 2, IN_BIT, OP_FIX(2), OP_R8(A), CT_NONE),

    // 0x58 - 0x5F (BIT 3)
    [0x58] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(B), CT_NONE),
    [0x59] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(C), CT_NONE),
    [0x5A] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(D), CT_NONE),
    [0x5B] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(E), CT_NONE),
    [0x5C] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(H), CT_NONE),
    [0x5D] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(L), CT_NONE),
    [0x5E] = INSTR(12, 2, IN_BIT, OP_FIX(3), OP_MEM_R16(HL), CT_NONE),
    [0x5F] = INSTR(8, 2, IN_BIT, OP_FIX(3), OP_R8(A), CT_NONE),

    // 0x60 - 0x67 (BIT 4)
    [0x60] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(B), CT_NONE),
    [0x61] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(C), CT_NONE),
    [0x62] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(D), CT_NONE),
    [0x63] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(E), CT_NONE),
    [0x64] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(H), CT_NONE),
    [0x65] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(L), CT_NONE),
    [0x66] = INSTR(12, 2, IN_BIT, OP_FIX(4), OP_MEM_R16(HL), CT_NONE),
    [0x67] = INSTR(8, 2, IN_BIT, OP_FIX(4), OP_R8(A), CT_NONE),

    // 0x68 - 0x6F (BIT 5)
    [0x68] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(B), CT_NONE),
    [0x69] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(C), CT_NONE),
    [0x6A] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(D), CT_NONE),
    [0x6B] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(E), CT_NONE),
    [0x6C] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(H), CT_NONE),
    [0x6D] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(L), CT_NONE),
    [0x6E] = INSTR(12, 2, IN_BIT, OP_FIX(5), OP_MEM_R16(HL), CT_NONE),
    [0x6F] = INSTR(8, 2, IN_BIT, OP_FIX(5), OP_R8(A), CT_NONE),

    // 0x70 - 0x77 (BIT 6)
    [0x70] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(B), CT_NONE),
    [0x71] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(C), CT_NONE),
    [0x72] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(D), CT_NONE),
    [0x73] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(E), CT_NONE),
    [0x74] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(H), CT_NONE),
    [0x75] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(L), CT_NONE),
    [0x76] = INSTR(12, 2, IN_BIT, OP_FIX(6), OP_MEM_R16(HL), CT_NONE),
    [0x77] = INSTR(8, 2, IN_BIT, OP_FIX(6), OP_R8(A), CT_NONE),

    // 0x78 - 0x7F (BIT 7)
    [0x78] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(B), CT_NONE),
    [0x79] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(C), CT_NONE),
    [0x7A] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(D), CT_NONE),
    [0x7B] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(E), CT_NONE),
    [0x7C] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(H), CT_NONE),
    [0x7D] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(L), CT_NONE),
    [0x7E] = INSTR(12, 2, IN_BIT, OP_FIX(7), OP_MEM_R16(HL), CT_NONE),
    [0x7F] = INSTR(8, 2, IN_BIT, OP_FIX(7), OP_R8(A), CT_NONE),

    // 0x80 - 0x87 (RES 0)
    [0x80] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(B), CT_NONE),
    [0x81] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(C), CT_NONE),
    [0x82] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(D), CT_NONE),
    [0x83] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(E), CT_NONE),
    [0x84] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(H), CT_NONE),
    [0x85] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(L), CT_NONE),
    [0x86] = INSTR(16, 2, IN_RES, OP_FIX(0), OP_MEM_R16(HL), CT_NONE),
    [0x87] = INSTR(8, 2, IN_RES, OP_FIX(0), OP_R8(A), CT_NONE),

    // 0x88 - 0x8F (RES 1)
    [0x88] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(B), CT_NONE),
    [0x89] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(C), CT_NONE),
    [0x8A] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(D), CT_NONE),
    [0x8B] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(E), CT_NONE),
    [0x8C] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(H), CT_NONE),
    [0x8D] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(L), CT_NONE),
    [0x8E] = INSTR(16, 2, IN_RES, OP_FIX(1), OP_MEM_R16(HL), CT_NONE),
    [0x8F] = INSTR(8, 2, IN_RES, OP_FIX(1), OP_R8(A), CT_NONE),

    // 0x90 - 0x97 (RES 2)
    [0x90] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(B), CT_NONE),
    [0x91] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(C), CT_NONE),
    [0x92] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(D), CT_NONE),
    [0x93] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(E), CT_NONE),
    [0x94] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(H), CT_NONE),
    [0x95] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(L), CT_NONE),
    [0x96] = INSTR(16, 2, IN_RES, OP_FIX(2), OP_MEM_R16(HL), CT_NONE),
    [0x97] = INSTR(8, 2, IN_RES, OP_FIX(2), OP_R8(A), CT_NONE),

    // 0x98 - 0x9F (RES 3)
    [0x98] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(B), CT_NONE),
    [0x99] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(C), CT_NONE),
    [0x9A] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(D), CT_NONE),
    [0x9B] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(E), CT_NONE),
    [0x9C] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(H), CT_NONE),
    [0x9D] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(L), CT_NONE),
    [0x9E] = INSTR(16, 2, IN_RES, OP_FIX(3), OP_MEM_R16(HL), CT_NONE),
    [0x9F] = INSTR(8, 2, IN_RES, OP_FIX(3), OP_R8(A), CT_NONE),

    // 0xA0 - 0xA7 (RES 4)
    [0xA0] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(B), CT_NONE),
    [0xA1] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(C), CT_NONE),
    [0xA2] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(D), CT_NONE),
    [0xA3] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(E), CT_NONE),
    [0xA4] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(H), CT_NONE),
    [0xA5] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(L), CT_NONE),
    [0xA6] = INSTR(16, 2, IN_RES, OP_FIX(4), OP_MEM_R16(HL), CT_NONE),
    [0xA7] = INSTR(8, 2, IN_RES, OP_FIX(4), OP_R8(A), CT_NONE),

    // 0xA8 - 0xAF (RES 5)
    [0xA8] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(B), CT_NONE),
    [0xA9] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(C), CT_NONE),
    [0xAA] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(D), CT_NONE),
    [0xAB] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(E), CT_NONE),
    [0xAC] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(H), CT_NONE),
    [0xAD] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(L), CT_NONE),
    [0xAE] = INSTR(16, 2, IN_RES, OP_FIX(5), OP_MEM_R16(HL), CT_NONE),
    [0xAF] = INSTR(8, 2, IN_RES, OP_FIX(5), OP_R8(A), CT_NONE),

    // 0xB0 - 0xB7 (RES 6)
    [0xB0] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(B), CT_NONE),
    [0xB1] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(C), CT_NONE),
    [0xB2] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(D), CT_NONE),
    [0xB3] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(E), CT_NONE),
    [0xB4] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(H), CT_NONE),
    [0xB5] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(L), CT_NONE),
    [0xB6] = INSTR(16, 2, IN_RES, OP_FIX(6), OP_MEM_R16(HL), CT_NONE),
    [0xB7] = INSTR(8, 2, IN_RES, OP_FIX(6), OP_R8(A), CT_NONE),

    // 0xB8 - 0xBF (RES 7)
    [0xB8] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(B), CT_NONE),
    [0xB9] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(C), CT_NONE),
    [0xBA] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(D), CT_NONE),
    [0xBB] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(E), CT_NONE),
    [0xBC] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(H), CT_NONE),
    [0xBD] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(L), CT_NONE),
    [0xBE] = INSTR(16, 2, IN_RES, OP_FIX(7), OP_MEM_R16(HL), CT_NONE),
    [0xBF] = INSTR(8, 2, IN_RES, OP_FIX(7), OP_R8(A), CT_NONE),

    // 0xC0 - 0xC7 (SET 0)
    [0xC0] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(B), CT_NONE),
    [0xC1] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(C), CT_NONE),
    [0xC2] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(D), CT_NONE),
    [0xC3] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(E), CT_NONE),
    [0xC4] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(H), CT_NONE),
    [0xC5] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(L), CT_NONE),
    [0xC6] = INSTR(16, 2, IN_SET, OP_FIX(0), OP_MEM_R16(HL), CT_NONE),
    [0xC7] = INSTR(8, 2, IN_SET, OP_FIX(0), OP_R8(A), CT_NONE),

    // 0xC8 - 0xCF (SET 1)
    [0xC8] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(B), CT_NONE),
    [0xC9] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(C), CT_NONE),
    [0xCA] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(D), CT_NONE),
    [0xCB] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(E), CT_NONE),
    [0xCC] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(H), CT_NONE),
    [0xCD] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(L), CT_NONE),
    [0xCE] = INSTR(16, 2, IN_SET, OP_FIX(1), OP_MEM_R16(HL), CT_NONE),
    [0xCF] = INSTR(8, 2, IN_SET, OP_FIX(1), OP_R8(A), CT_NONE),

    // 0xD0 - 0xD7 (SET 2)
    [0xD0] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(B), CT_NONE),
    [0xD1] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(C), CT_NONE),
    [0xD2] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(D), CT_NONE),
    [0xD3] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(E), CT_NONE),
    [0xD4] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(H), CT_NONE),
    [0xD5] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(L), CT_NONE),
    [0xD6] = INSTR(16, 2, IN_SET, OP_FIX(2), OP_MEM_R16(HL), CT_NONE),
    [0xD7] = INSTR(8, 2, IN_SET, OP_FIX(2), OP_R8(A), CT_NONE),

    // 0xD8 - 0xDF (SET 3)
    [0xD8] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(B), CT_NONE),
    [0xD9] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(C), CT_NONE),
    [0xDA] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(D), CT_NONE),
    [0xDB] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(E), CT_NONE),
    [0xDC] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(H), CT_NONE),
    [0xDD] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(L), CT_NONE),
    [0xDE] = INSTR(16, 2, IN_SET, OP_FIX(3), OP_MEM_R16(HL), CT_NONE),
    [0xDF] = INSTR(8, 2, IN_SET, OP_FIX(3), OP_R8(A), CT_NONE),

    // 0xE0 - 0xE7 (SET 4)
    [0xE0] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(B), CT_NONE),
    [0xE1] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(C), CT_NONE),
    [0xE2] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(D), CT_NONE),
    [0xE3] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(E), CT_NONE),
    [0xE4] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(H), CT_NONE),
    [0xE5] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(L), CT_NONE),
    [0xE6] = INSTR(16, 2, IN_SET, OP_FIX(4), OP_MEM_R16(HL), CT_NONE),
    [0xE7] = INSTR(8, 2, IN_SET, OP_FIX(4), OP_R8(A), CT_NONE),

    // 0xE8 - 0xEF (SET 5)
    [0xE8] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(B), CT_NONE),
    [0xE9] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(C), CT_NONE),
    [0xEA] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(D), CT_NONE),
    [0xEB] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(E), CT_NONE),
    [0xEC] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(H), CT_NONE),
    [0xED] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(L), CT_NONE),
    [0xEE] = INSTR(16, 2, IN_SET, OP_FIX(5), OP_MEM_R16(HL), CT_NONE),
    [0xEF] = INSTR(8, 2, IN_SET, OP_FIX(5), OP_R8(A), CT_NONE),

    // 0xF0 - 0xF7 (SET 6)
    [0xF0] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(B), CT_NONE),
    [0xF1] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(C), CT_NONE),
    [0xF2] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(D), CT_NONE),
    [0xF3] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(E), CT_NONE),
    [0xF4] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(H), CT_NONE),
    [0xF5] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(L), CT_NONE),
    [0xF6] = INSTR(16, 2, IN_SET, OP_FIX(6), OP_MEM_R16(HL), CT_NONE),
    [0xF7] = INSTR(8, 2, IN_SET, OP_FIX(6), OP_R8(A), CT_NONE),

    // 0xF8 - 0xFF (SET 7)
    [0xF8] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(B), CT_NONE),
    [0xF9] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(C), CT_NONE),
    [0xFA] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(D), CT_NONE),
    [0xFB] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(E), CT_NONE),
    [0xFC] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(H), CT_NONE),
    [0xFD] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(L), CT_NONE),
    [0xFE] = INSTR(16, 2, IN_SET, OP_FIX(7), OP_MEM_R16(HL), CT_NONE),
    [0xFF] = INSTR(8, 2, IN_SET, OP_FIX(7), OP_R8(A), CT_NONE)
};


instr_t parse_instr(byte opcode){
    /* always false
        if(opcode >= 256) {
            ERROR("Invalid opcode 0b%b provided!", opcode);
        }
    */

    if(opcode == 0xCB) {
        return CB_INSTR_LOOKUP[opcode];
    }
    else {
        return INSTR_LOOKUP[opcode];
    }
}