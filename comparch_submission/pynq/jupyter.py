import struct
# SOME HELPER FUNCTIONS AND ASSEMBLER

# Load specified instructions into instruction memory
def load_instructions(instr_mmio, instr_str):
    for index, line in enumerate(instr_str.strip().split('\n')):
        instr_mmio.array[index] = int(line.strip(), 16)
    
    time.sleep(0.01)

# Write data into data memory
def write_data(data_mmio, address, value, size):
    """
    size: "b" = byte
          "h" = halfword
          "w" = word
          "d" = doubleword
    """

    size_map = {
        "b": 1,
        "h": 2,
        "w": 4,
        "d": 8
    }

    if size not in size_map:
        raise ValueError("size must be one of: 'b', 'h', 'w', 'd'")

    num_bytes = size_map[size]

    # Check bounds
    if address + num_bytes > len(data_mmio.array):
        raise IndexError("write out of memory bounds")

    # Write in little-endian order
    for i in range(num_bytes):
        data_mmio.array[address + i] = (value >> (8 * i)) & 0xFF
        
MAX_ADDRESS = 500
COLUMNS = 8

# Configuration
MAX_ADDRESS = 1024  # Example size
BYTES_PER_WORD = 4 # 32-bit word
WORDS_PER_ROW = 2

def print_memory_map(data_mmio):    
    # Updated header to include Decimal columns
    print(f"{'Addr':<10} | {'Hex (Word 1)':<12} {'Dec (Word 1)':<12} {'Float (Word 1)':<20} | {'Hex (Word 2)':<12} {'Dec (Word 2)':<12} {'Float (Word 2)':<20}")
    print("-" * 100)

    step = WORDS_PER_ROW * BYTES_PER_WORD
    
    for start_addr in range(0, MAX_ADDRESS, step):
        
        row_addrs = []
        row_hex = []
        row_dec = []
        row_floats = []
        
        for word_idx in range(WORDS_PER_ROW):
            addr = start_addr + (word_idx * BYTES_PER_WORD)
            
            # Bounds check
            if addr + BYTES_PER_WORD <= MAX_ADDRESS:
                # 1. Get the chunk
                byte_chunk = data_mmio.array[addr : addr + BYTES_PER_WORD]
                
                # SAFETY CHECK: Ensure we actually got 4 bytes
                if len(byte_chunk) != 4:
                    raise ValueError(f"Chunk size {len(byte_chunk)}!=4")

                # SAFETY CHECK: Force values to 0-255 integers
                clean_bytes = [int(b) & 0xFF for b in byte_chunk]
                binary_data = bytes(clean_bytes)
                
                # 2. Convert to Hex Integer and Decimal
                int_val = struct.unpack('<I', binary_data)[0]
                hex_str = f"0x{int_val:08x}"
                dec_str = f"{int_val}"
                
                # 3. Convert to Float
                float_val = struct.unpack('<f', binary_data)[0]
                float_str = f"{float_val: .4e}" 

                row_addrs.append(f"0x{addr:04x}")
                row_hex.append(hex_str)
                row_dec.append(dec_str)
                row_floats.append(float_str)
                
            else:
                row_addrs.append("      ")
                row_hex.append("          ")
                row_dec.append("          ")
                row_floats.append("             ")

        if len(row_addrs) >= 2:
            print(f"{row_addrs[0]:<10} | {row_hex[0]:<12} {row_dec[0]:<12} {row_floats[0]:<20} | {row_hex[1]:<12} {row_dec[1]:<12} {row_floats[1]:<20}")

        
def clear_dmem(data_mmio, clear_amt):
    for addr in range(0, clear_amt):
        data_mmio.array[addr] = 0
        
def clear_imem(instr_mmio, clear_amt):
    for i in range(clear_amt):
        instr_mmio.array[i] = 0x0
        

class RISCVAssembler:
    def __init__(self):
        # --- 1. Register Maps ---
        self.regs = {}
        # Integer Registers (x0-x31)
        abi_int = ['zero','ra','sp','gp','tp','t0','t1','t2','s0','s1','a0',
                   'a1','a2','a3','a4','a5','a6','a7','s2','s3','s4','s5',
                   's6','s7','s8','s9','s10','s11','t3','t4','t5','t6']
        for i in range(32):
            self.regs[f'x{i}'] = i
            self.regs[abi_int[i]] = i
        self.regs['fp'] = 8 

        # Float Registers (f0-f31)
        abi_float = ['ft0','ft1','ft2','ft3','ft4','ft5','ft6','ft7','fs0','fs1','fa0',
                     'fa1','fa2','fa3','fa4','fa5','fa6','fa7','fs2','fs3','fs4','fs5',
                     'fs6','fs7','fs8','fs9','fs10','fs11','ft8','ft9','ft10','ft11']
        for i in range(32):
            self.regs[f'f{i}'] = i
            self.regs[abi_float[i]] = i

        # Symbol Table
        self.labels = {}

        # --- 2. Instruction Database ---
        # NOTE: FP Arithmetic uses rm=7 (Dynamic).
        self.instrs = {
            # Base Integer
            'lui':   ('U', 0x37, None, None), 'auipc': ('U', 0x17, None, None),
            'jal':   ('J', 0x6F, None, None), 'jalr':  ('I', 0x67, 0x0, None),
            'beq':   ('B', 0x63, 0x0, None), 'bne':   ('B', 0x63, 0x1, None),
            'blt':   ('B', 0x63, 0x4, None), 'bge':   ('B', 0x63, 0x5, None),
            'bltu':  ('B', 0x63, 0x6, None), 'bgeu':  ('B', 0x63, 0x7, None),
            'lb':    ('I', 0x03, 0x0, None), 'lh':    ('I', 0x03, 0x1, None),
            'lw':    ('I', 0x03, 0x2, None), 'ld':    ('I', 0x03, 0x3, None),
            'lbu':   ('I', 0x03, 0x4, None), 'lhu':   ('I', 0x03, 0x5, None),
            'lwu':   ('I', 0x03, 0x6, None),
            'sb':    ('S', 0x23, 0x0, None), 'sh':    ('S', 0x23, 0x1, None),
            'sw':    ('S', 0x23, 0x2, None), 'sd':    ('S', 0x23, 0x3, None),
            'addi':  ('I', 0x13, 0x0, None), 'slti':  ('I', 0x13, 0x2, None),
            'sltiu': ('I', 0x13, 0x3, None), 'xori':  ('I', 0x13, 0x4, None),
            'ori':   ('I', 0x13, 0x6, None), 'andi':  ('I', 0x13, 0x7, None),
            'slli':  ('I', 0x13, 0x1, 0x00), 'srli':  ('I', 0x13, 0x5, 0x00), 'srai': ('I', 0x13, 0x5, 0x20),
            'add':   ('R', 0x33, 0x0, 0x00), 'sub':   ('R', 0x33, 0x0, 0x20),
            'sll':   ('R', 0x33, 0x1, 0x00), 'slt':   ('R', 0x33, 0x2, 0x00),
            'sltu':  ('R', 0x33, 0x3, 0x00), 'xor':   ('R', 0x33, 0x4, 0x00),
            'srl':   ('R', 0x33, 0x5, 0x00), 'sra':   ('R', 0x33, 0x5, 0x20),
            'or':    ('R', 0x33, 0x6, 0x00), 'and':   ('R', 0x33, 0x7, 0x00),
            
            # M-Ext
            'mul':   ('R', 0x33, 0x0, 0x01), 'mulh':  ('R', 0x33, 1, 0x01),
            'mulhsu':('R', 0x33, 2, 0x01),   'mulhu': ('R', 0x33, 3, 0x01),
            'div':   ('R', 0x33, 4, 0x01),   'divu':  ('R', 0x33, 5, 0x01),
            'rem':   ('R', 0x33, 6, 0x01),   'remu':  ('R', 0x33, 7, 0x01),
            
            # F/D Ext - Arithmetic (Use RM=7)
            'flw':   ('I', 0x07, 0x2, None), 'fsw':   ('S', 0x27, 0x2, None),
            'fld':   ('I', 0x07, 0x3, None), 'fsd':   ('S', 0x27, 0x3, None),
            'fadd.s':('R', 0x53, 0x7, 0x00), 'fsub.s':('R', 0x53, 0x7, 0x04),
            'fmul.s':('R', 0x53, 0x7, 0x08), 'fdiv.s':('R', 0x53, 0x7, 0x0C),
            'fsqrt.s':('R', 0x53, 0x7, 0x2C), 
            'fsgnj.s':('R', 0x53, 0x0, 0x10), 'fmin.s':('R', 0x53, 0x0, 0x14), 'fmax.s':('R', 0x53, 1, 0x14),

            'fadd.d':('R', 0x53, 0x7, 0x01), 'fsub.d':('R', 0x53, 0x7, 0x05),
            'fmul.d':('R', 0x53, 0x7, 0x09), 'fdiv.d':('R', 0x53, 0x7, 0x0D),
            'fsqrt.d':('R', 0x53, 0x7, 0x2D), 
            'fsgnj.d':('R', 0x53, 0x0, 0x11), 'fmin.d':('R', 0x53, 0x0, 0x15), 'fmax.d':('R', 0x53, 1, 0x15),
            
            # === Comparisons (Fixed Funct7) ===
            'feq.s': ('R', 0x53, 0x2, 0x50), 'flt.s': ('R', 0x53, 0x1, 0x50), 'fle.s': ('R', 0x53, 0x0, 0x50),
            'feq.d': ('R', 0x53, 0x2, 0x51), 'flt.d': ('R', 0x53, 0x1, 0x51), 'fle.d': ('R', 0x53, 0x0, 0x51),
            
            # === Classify ===
            'fclass.s': ('R', 0x53, 0x1, 0xE0), 
            'fclass.d': ('R', 0x53, 0x1, 0xE1),

            # === Moves (Corrected Funct7) ===
            # fmv.x.w (Float to Int): 0x70
            # fmv.w.x (Int to Float): 0x78
            'fmv.x.w':  ('R', 0x53, 0x0, 0x70), 
            'fmv.w.x':  ('R', 0x53, 0x0, 0x78),
            
            # fmv.x.d (Double to Long): 0x71
            # fmv.d.x (Long to Double): 0x79
            'fmv.x.d':  ('R', 0x53, 0x0, 0x71), 
            'fmv.d.x':  ('R', 0x53, 0x0, 0x79),

            # === Conversions (Rounding Mode 7) ===
            'fcvt.w.s':  ('R', 0x53, 0x7, 0x60), 'fcvt.wu.s': ('R', 0x53, 0x7, 0x60),
            'fcvt.l.s':  ('R', 0x53, 0x7, 0x60), 'fcvt.lu.s': ('R', 0x53, 0x7, 0x60),
            'fcvt.s.w':  ('R', 0x53, 0x7, 0x68), 'fcvt.s.wu': ('R', 0x53, 0x7, 0x68),
            'fcvt.s.l':  ('R', 0x53, 0x7, 0x68), 'fcvt.s.lu': ('R', 0x53, 0x7, 0x68),

            'fcvt.w.d':  ('R', 0x53, 0x7, 0x61), 'fcvt.wu.d': ('R', 0x53, 0x7, 0x61),
            'fcvt.l.d':  ('R', 0x53, 0x7, 0x61), 'fcvt.lu.d': ('R', 0x53, 0x7, 0x61),
            'fcvt.d.w':  ('R', 0x53, 0x7, 0x69), 'fcvt.d.wu': ('R', 0x53, 0x7, 0x69),
            'fcvt.d.l':  ('R', 0x53, 0x7, 0x69), 'fcvt.d.lu': ('R', 0x53, 0x7, 0x69),
            
            'fcvt.s.d':  ('R', 0x53, 0x7, 0x20), 
            'fcvt.d.s':  ('R', 0x53, 0x7, 0x21),
        }

    def parse_reg(self, token):
        token = token.strip().replace(',', '')
        if token in self.regs: return self.regs[token]
        raise ValueError(f"Unknown register: {token}")

    def parse_imm(self, token, current_pc, bits=12):
        token = token.strip().replace(',', '')
        if token in self.labels:
            val = self.labels[token] - current_pc
        else:
            try:
                val = int(token, 0)
            except ValueError:
                raise ValueError(f"Invalid immediate/label: {token}")
        if val < 0: val = (1 << bits) + val
        return val & ((1 << bits) - 1)

    def expand_pseudo(self, line):
        label = ""
        instr = line
        if ':' in line:
            label_part, instr_part = line.split(':', 1)
            label = label_part + ": "
            instr = instr_part.strip()
        if not instr: return [line]

        parts = instr.replace(',', ' ').split()
        mnemonic = parts[0]
        args = parts[1:]
        expanded = []

        if mnemonic == 'nop':
            expanded.append(f"addi x0, x0, 0")
        elif mnemonic == 'mv':
            expanded.append(f"addi {args[0]}, {args[1]}, 0")
        elif mnemonic == 'not':
            expanded.append(f"xori {args[0]}, {args[1]}, -1")
        elif mnemonic == 'neg':
            expanded.append(f"sub {args[0]}, x0, {args[1]}")
        elif mnemonic == 'j':
            expanded.append(f"jal x0, {args[0]}")
        elif mnemonic == 'jr':
            expanded.append(f"jalr x0, 0({args[0]})")
        elif mnemonic == 'ret':
            expanded.append(f"jalr x0, 0(ra)")
        elif mnemonic == 'li':
            # LI Optimization: Skip addi if lower 12 bits are 0
            rd = args[0]
            try:
                val = int(args[1], 0)
                if -2048 <= val <= 2047:
                    expanded.append(f"addi {rd}, x0, {val}")
                else:
                    lo = val & 0xFFF
                    hi_adjust = 1 if lo >= 0x800 else 0
                    if lo >= 0x800: lo -= 0x1000 
                    hi = ((val >> 12) & 0xFFFFF) + hi_adjust
                    expanded.append(f"lui {rd}, {hi}")
                    # Only add the LO part if it is not zero
                    if lo != 0:
                        expanded.append(f"addi {rd}, {rd}, {lo}")
            except:
                return [line]
        elif mnemonic == 'fmv.s':
            expanded.append(f"fsgnj.s {args[0]}, {args[1]}, {args[1]}")
        elif mnemonic == 'fmv.d':
            expanded.append(f"fsgnj.d {args[0]}, {args[1]}, {args[1]}")
        else:
            return [line]

        final_lines = []
        if label:
            final_lines.append(label + expanded[0])
            for i in range(1, len(expanded)):
                final_lines.append(expanded[i])
        else:
            final_lines = expanded
        return final_lines

    def preprocess(self, source_code):
        lines = source_code.split('\n')
        processed_lines = []
        for line in lines:
            clean = line.split('#')[0].split('//')[0].strip()
            if not clean: continue
            processed_lines.extend(self.expand_pseudo(clean))
        return processed_lines

    def first_pass(self, lines):
        pc = 0
        self.labels = {}
        clean_lines = []
        for line in lines:
            line = line.strip()
            if not line: continue
            if line.endswith(':'):
                self.labels[line[:-1]] = pc
                continue 
            if ':' in line:
                label, instr = line.split(':', 1)
                self.labels[label.strip()] = pc
                line = instr.strip()
            clean_lines.append((pc, line))
            pc += 4 
        return clean_lines

    def assemble(self, source_code):
        output_hex = []
        expanded_code = self.preprocess(source_code)
        lines_with_pc = self.first_pass(expanded_code)
        
        for pc, line in lines_with_pc:
            parts = line.replace(',', ' ').split()
            mnemonic = parts[0]
            args = parts[1:]

            if mnemonic not in self.instrs:
                output_hex.append(f"ERROR: Unknown instruction '{mnemonic}'")
                continue

            itype, opcode, funct3, funct7 = self.instrs[mnemonic]
            mc = 0

            try:
                if itype == 'I':
                    if '(' in args[-1]: 
                        rd = self.parse_reg(args[0])
                        off_str, rs_str = args[1].split('(')
                        rs1 = self.parse_reg(rs_str.replace(')', ''))
                        imm = self.parse_imm(off_str, pc, 12)
                    else:
                        rd = self.parse_reg(args[0])
                        rs1 = self.parse_reg(args[1])
                        if mnemonic in ['slli', 'srli', 'srai']:
                            shamt = self.parse_imm(args[2], pc, 6)
                            f7_val = funct7 if funct7 else 0
                            imm = (f7_val << 5) | shamt
                        else:
                            imm = self.parse_imm(args[2], pc, 12)
                    mc = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

                elif itype == 'J':
                    rd = self.parse_reg(args[0])
                    imm = self.parse_imm(args[1], pc, 21)
                    bit_20 = (imm >> 20) & 1
                    bit_10_1 = (imm >> 1) & 0x3FF
                    bit_11 = (imm >> 11) & 1
                    bit_19_12 = (imm >> 12) & 0xFF
                    mc = (bit_20 << 31) | (bit_10_1 << 21) | (bit_11 << 20) | (bit_19_12 << 12) | (rd << 7) | opcode

                elif itype == 'B':
                    rs1 = self.parse_reg(args[0])
                    rs2 = self.parse_reg(args[1])
                    imm = self.parse_imm(args[2], pc, 13)
                    bit_12 = (imm >> 12) & 1
                    bit_10_5 = (imm >> 5) & 0x3F
                    bit_4_1 = (imm >> 1) & 0xF
                    bit_11 = (imm >> 11) & 1
                    mc = (bit_12 << 31) | (bit_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (bit_4_1 << 8) | (bit_11 << 7) | opcode

                elif itype == 'R':
                    if mnemonic.startswith('fcvt'):
                        rd = self.parse_reg(args[0])
                        rs1 = self.parse_reg(args[1])
                        if '.wu.' in mnemonic or mnemonic.endswith('.wu'): rs2 = 1
                        elif '.lu.' in mnemonic or mnemonic.endswith('.lu'): rs2 = 3
                        elif '.l.' in mnemonic or mnemonic.endswith('.l'): rs2 = 2
                        elif '.w.' in mnemonic or mnemonic.endswith('.w'): rs2 = 0
                        else: rs2 = 0 
                    elif mnemonic.startswith('fsqrt') or mnemonic.startswith('fmv') or mnemonic.startswith('fclass'):
                        rd = self.parse_reg(args[0])
                        rs1 = self.parse_reg(args[1])
                        rs2 = 0
                    else:
                        rd = self.parse_reg(args[0])
                        rs1 = self.parse_reg(args[1])
                        rs2 = self.parse_reg(args[2])
                    
                    f7_val = funct7 if funct7 else 0
                    mc = (f7_val << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

                elif itype == 'S':
                    rs2 = self.parse_reg(args[0])
                    off_str, rs_str = args[1].split('(')
                    rs1 = self.parse_reg(rs_str.replace(')', ''))
                    imm = self.parse_imm(off_str, pc, 12)
                    imm_11_5 = (imm >> 5) & 0x7F
                    imm_4_0 = imm & 0x1F
                    mc = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode

                elif itype == 'U':
                    rd = self.parse_reg(args[0])
                    val = int(args[1].replace(',',''), 0)
                    imm = val & 0xFFFFF
                    mc = (imm << 12) | (rd << 7) | opcode

                output_hex.append(f"{mc:08x}")

            except Exception as e:
                output_hex.append(f"ERROR: {line} -> {str(e)}")

        return "\n".join(output_hex)

def load_asm_data_segment(data_mmio, base_addr, text_lines):
    addr = base_addr

    for line in text_lines.splitlines():
        # remove comments
        line = line.split('#')[0].strip()
        
        if not line:
            continue

        # detect .word / .dword
        if line.startswith(".word"):
            size = "w"
        elif line.startswith(".dword"):
            size = "d"
        else:
            continue

        # extract the hex value
        m = re.search(r"0x[0-9A-Fa-f]+", line)
        if not m:
            raise ValueError(f"Invalid line, no hex found: {line}")

        value = int(m.group(0), 16)

        # write and advance
        write_data(data_mmio, addr, value, size)

        # advance address
        addr += 4 if size == "w" else 8

from pynq import Overlay
from pynq.lib import AxiGPIO
import time
import re

# Load the overlay (bit file and hardware handoff file)
# Make sure that both files have the same name
ol = Overlay("./design_1.bit")

# Instantiating channels and MMIO interfaces
rst_channel = ol.axi_rst.channel1
running_channel = ol.axi_running.channel1
pc_channel = ol.axi_if_pc.channel1
instr_channel = ol.axi_if_instr.channel1
is_static_prediction_channel = ol.axi_is_static_prediction.channel1
static_prediction_channel = ol.axi_static_prediction.channel1
is_program_done_channel = ol.axi_is_program_done.channel1
program_cycles_channel = ol.axi_program_cycles.channel1
data_bram = ol.axi_data_mem_controller
data_mmio = data_bram.mmio
instr_bram = ol.axi_instr_mem_controller
instr_mmio = instr_bram.mmio

# --- 1. Configuration & Loading ---
print(f"{'='*10} RISC-V System Startup {'='*10}")

assembler = RISCVAssembler()
print("[-] Assembling instructions...")

code = """
"""

instructions = assembler.assemble(code)

print(f"[-] Loading {len(instructions)} instructions to IMEM...")
clear_imem(instr_mmio, len(instructions))
load_instructions(instr_mmio, instructions)

# Data Setup
BASE_ADDR = 0x100
print(f"[-] Clearing DMEM and loading Data Segment at Base: {hex(BASE_ADDR)}...")
clear_dmem(data_mmio, MAX_ADDRESS)

data_segment = """
"""

load_asm_data_segment(data_mmio, BASE_ADDR, data_segment)


# --- 2. Core Execution ---
print(f"\n{'='*10} Execution Control {'='*10}")

# Start the core
print("[-] Starting Core Clock...")
running_channel.write(1, 0xFFFFFFFF)

# Configure Prediction
print("[-] Configuring Static/Dynamic Prediction...")
is_static_prediction = 1
static_prediction = 1
if(is_static_prediction): print(f"[*] Configured for Static Prediction {static_prediction}...")
else: print("[*] Configured for Dynamic Prediction...")
is_static_prediction_channel.write(is_static_prediction, 0xFFFFFFFF) # 0 = Enable static
static_prediction_channel.write(static_prediction, 0xFFFFFFFF)                       # 1 = Predict Taken

# Reset Sequence
print("[-] Reset the pipeline...")
rst_channel.write(1, 0xFFFFFFFF)
time.sleep(1)

print("[-] Starting the core...")
rst_channel.write(0, 0xFFFFFFFF)
time.sleep(1) # Allow program to run


# --- 3. Results & Debugging ---
print(f"\n{'='*10} System Status {'='*10}")

# Check Completion
is_done = is_program_done_channel.read()
status_msg = "COMPLETED" if is_done else "RUNNING / STALLED"
print(f"Program Status:  [{status_msg}]")

# Cycle Count
cycles = program_cycles_channel.read()
print(f"Number of cycles:  {cycles:,} cycles")

# --- 4. Cleanup & Memory Dump ---
running_channel.write(0, 0xFFFFFFFF) # Stop the core

print(f"\n{'='*10} Final Memory Dump {'='*10}")
print_memory_map(data_mmio)