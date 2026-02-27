# 8-bit Pipelined Von Neumann Processor – Verilog

Advanced Processor Architecture Project (ELC3030 – Winter 2025)  
Faculty of Engineering – Cairo University  

Designed and implemented a complete 5-stage pipelined 8-bit RISC-like processor in Verilog HDL with hazard mitigation, interrupt handling, and FPGA synthesis.

---

## 📌 Project Objective

The objective of this project is to:

1. Design and implement an 8-bit pipelined Von Neumann processor based on a custom ISA.
2. Use a single shared memory for instruction and data access.
3. Implement an FSM-based control unit.
4. Support pipeline execution with hazard detection and forwarding.
5. Verify functionality using HDL simulation and waveform analysis.
6. (Bonus) Synthesize and analyze FPGA performance.

---

## 🏗 Architecture Overview

The processor follows a classic 5-stage pipelined RISC architecture:

1. IF  – Instruction Fetch  
2. ID  – Instruction Decode  
3. EX  – Execute  
4. MEM – Memory Access  
5. WB  – Write Back  

Main architectural blocks:

- ALU (`another_ALU.v`)
- Control Unit (`Control_unit.v`)
- Hazard Unit (`HU.v`)
- Forwarding Unit (`FU.v`)
- Branch Unit (`Branch_Unit.v`)
- Program Counter (`Pc.v`)
- Memory – Dual Port Von Neumann (`Memory.v`)
- Register File (`Register_file.v`)
- CCR – Condition Code Register (`CCR.v`)
- Interrupt Register (`interrupt_reg.v`)
- Top-Level Integration (`CPU_WrapperV3.v`)

---

## ⚙️ Pipeline Registers

Implemented pipeline registers:

- `IF_ID_reg.v`
- `ID_EX_Reg.v`
- `Ex_Mem.v`
- `MEM_WB_Reg.v`

These registers isolate pipeline stages and allow concurrent execution of multiple instructions.

---

## 🧮 ALU

The ALU is a combinational execution unit located in the EX stage.

### Supported Operations:

- Arithmetic: ADD, SUB, INC, DEC, NEG
- Logical: AND, OR, NOT
- Rotate: RLC, RRC
- Flag Control: SETC, CLRC
- Data Movement: PASS A, PASS B

### Flags:

- Z – Zero
- N – Negative
- C – Carry
- V – Overflow

A flag mask mechanism enables selective flag updates, improving pipeline behavior.

---

## 🧠 Control Unit

The Control Unit:

- Decodes opcode and subfields
- Generates all pipeline control signals
- Handles CALL/RET/RTI
- Manages immediate instructions
- Controls interrupt injection
- Implements internal FSM:
  - RESET
  - FETCH
  - FETCH_IMM

---

## 🚦 Hazard Unit (HU)

The Hazard Unit handles:

### 🔹 Load-Use Data Hazards
- Stalls PC
- Freezes IF/ID
- Injects bubble into ID/EX

### 🔹 Control Hazards
- Flushes IF/ID when branch is taken

Truth table implemented for all hazard combinations.

---

## 🔁 Forwarding Unit (FU)

Eliminates unnecessary stalls caused by RAW hazards.

Supports:

- EX/MEM → EX forwarding (highest priority)
- MEM/WB → EX forwarding
- ID-stage forwarding

Forwarding select encoding:

| Code | Source        |
|------|--------------|
| 00   | ID/EX value  |
| 01   | MEM/WB value |
| 10   | EX/MEM value |

---

## 🌿 Branch Unit

Branch resolution occurs in the EX stage.

Supports:

- Conditional branches (JZ, JN, JC, JV)
- LOOP
- JMP
- CALL
- RET / RTI

Outputs:
- B_TAKE
- PC_SRC

---

## 🔔 Interrupt Handling

Interrupts are treated as implicit CALL instructions:

- PC pushed to stack
- Flags preserved
- PC redirected to interrupt vector
- Pipeline bubbles injected
- RTI restores flags and PC

Ensures precise interrupt behavior in a pipelined environment.

---

## 🗂 Memory (Von Neumann)

Dual-port memory:

- Port A → Instruction Fetch
- Port B → Data Access

Memory layout:

- 0–127 → Instruction Memory
- 128–255 → Data & Stack Memory

---

## 📦 Register File

- 4 general-purpose registers
- Asynchronous read
- Synchronous write
- Dedicated Stack Pointer (SP)
- SP supports increment/decrement for PUSH/POP

---

## 🏁 FPGA Synthesis (Bonus)

Synthesized using Xilinx Vivado on:

- AMD XC7A35T-1CPG FPGA

Obtained:
- Maximum operating frequency
- Resource utilization report

---

## 🧪 Verification

Simulation performed using:

- ModelSim
- Waveform analysis

Verified:

- Arithmetic instructions
- Logical instructions
- Branching
- Stack operations
- Interrupt behavior
- Hazard scenarios
- Forwarding correctness

---

## 📂 RTL File Structure

```
RTL/
├── another_ALU.v
├── Branch_Unit.v
├── CCR.v
├── Control_unit.v
├── CPU_WrapperV3.v
├── Ex_Mem.v
├── FU.v
├── HU.v
├── ID_EX_Reg.v
├── IF_ID_reg.v
├── interrupt_reg.v
├── MEM_WB_Reg.v
├── Memory.v
├── Mux2to1.v
├── Mux4to1.v
├── Mux4to1_pc.v
├── Out_reg.v
├── Pc.v
└── Register_file.v
```

---

## 🎯 Key Learning Outcomes

- Pipelined CPU Design
- Hazard Detection & Stall Control
- Data Forwarding Mechanisms
- Branch Resolution in EX Stage
- Interrupt Handling in Pipelines
- FSM-based Control Design
- FPGA Synthesis & Timing Analysis
- Modular RTL Architecture

---

## 📄 Full Report

Detailed documentation including architecture diagrams, module descriptions, truth tables, and FPGA synthesis results:

📘 See the full project report here:  
[Final Report v1.pdf](<sandbox:/mnt/data/Final Report v1.pdf>) :contentReference[oaicite:0]{index=0}

---

## 👨‍💻 Author

Mostafa Mohamed Farhan  
Electronics & Communications Engineering  
Cairo University – Winter 2025
