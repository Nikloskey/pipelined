# RISC-V Pipelined Processor

A 5-stage pipelined RISC-V processor implementation in Verilog with support for a subset of RV32I instructions.

## Overview

This project implements a classic 5-stage pipeline architecture (IF → ID → EX → MEM → WB) with advanced hazard handling including:
- **Data forwarding** for reducing stalls
- **Branch prediction/flushing** for pipeline correction
- **Load-use hazard detection** to inject stalls when needed

## Supported Instructions

### R-Type (Register-Register Operations)
- `add` - Add two registers
- `sub` - Subtract two registers  
- `and` - Bitwise AND
- `or` - Bitwise OR

### I-Type (Register-Immediate Operations)
- `addi` - Add immediate to register
- `ori` - Bitwise OR with immediate
- `slli` - Shift left logical by immediate

### Load/Store
- `lw` - Load word from memory
- `sw` - Store word to memory

### Branch
- `beq` - Branch if equal

## Architecture

### Pipeline Stages

1. **IF (Instruction Fetch)** - Fetches instructions from instruction memory
2. **ID (Instruction Decode)** - Decodes opcode, reads registers, generates immediates
3. **EX (Execute)** - Executes ALU operations, calculates branch targets
4. **MEM (Memory)** - Performs load/store operations on data memory
5. **WB (Write-Back)** - Writes results back to registers

### Hazard Handling

- **Data Hazards**: Resolved via forwarding (EX/MEM and MEM/WB forwarding paths)
- **Control Hazards**: Handled by branch detection and pipeline flushing
- **Load-Use Hazards**: Detected and stalled when necessary

## File Descriptions

### Core Modules

| File | Purpose |
|------|---------|
| `riscv_core.v` | Top-level processor module integrating all pipeline stages |
| `tb_riscv_core.v` | Testbench with clock generation and pipeline monitoring |

### Instruction Fetch Stage

| File | Purpose |
|------|---------|
| `pc_reg.v` | Program counter register with stall support |
| `imem.v` | Instruction memory (64 words, loads from `program.hex`) |
| `IF_ID_reg.v` | IF/ID pipeline register with flush capability |

### Instruction Decode Stage

| File | Purpose |
|------|---------|
| `control_unit.v` | Decodes opcode and generates control signals |
| `regfile.v` | 32×32 register file with 2 read ports and 1 write port |
| `imm_gen.v` | Immediate generator supporting all instruction formats (I/S/B/U/J-Type) |
| `hazard_detection_unit.v` | Detects load-use hazards and triggers stalls |
| `ID_EX_reg.v` | ID/EX pipeline register with flush capability |

### Execute Stage

| File | Purpose |
|------|---------|
| `alu_control.v` | Generates ALU control signals from opcode and funct bits |
| `main_alu.v` | 32-bit ALU supporting ADD, SUB, AND, OR, SLT operations |
| `ksa.v` | Kogge-Stone parallel prefix adder for high-speed addition |
| `forwarding_unit.v` | Detects data hazards and routes forwarded data to ALU |
| `EX_MEM_reg.v` | EX/MEM pipeline register |

### Memory Stage

| File | Purpose |
|------|---------|
| `dmem.v` | Data memory (64 words) for load/store operations |
| `MEM_WB_reg.v` | MEM/WB pipeline register |

## Building and Running

### Prerequisites
- Icarus Verilog (`iverilog`)
- VVP (part of Icarus Verilog)
- GTKWave (optional, for waveform viewing)

### Compilation
```bash
iverilog -o sim.out tb_riscv_core.v
```

### Execution
```bash
vvp sim.out
```

This generates `pipeline_wave.vcd` and prints pipeline activity to console.

### Waveform Viewing
```bash
gtkwave pipeline_wave.vcd
```

## Program Format

Programs are loaded from `program.hex` in hexadecimal format (one instruction per line, 32-bit words).

Example:
```
00060413  # addi x8, x12, 0
00041463  # beq x8, x0, 8
```

## Memory Map

- **Instruction Memory**: 64×32 bits (addresses 0x00 - 0xFC, word-aligned)
- **Data Memory**: 64×32 bits (addresses 0x00 - 0xFC, word-aligned)

## Key Features

✓ Configurable pipeline depth  
✓ Parallel prefix adder for performance  
✓ Forwarding paths for data hazard mitigation  
✓ Load-use hazard detection and stalling  
✓ Branch flushing on misprediction  
✓ Comprehensive pipeline monitoring output  

## Future Enhancements

- [ ] J-Type and JAL instruction support
- [ ] More ALU operations (multiply, divide)
- [ ] Cache simulation
- [ ] Extended instruction format support
- [ ] Performance counters
