# 8-bit Pipelined Processor – Verilog

Designed and implemented a 5-stage 8-bit RISC-like pipelined processor in Verilog HDL  
(ELC3030 – Advanced Processor Architecture, Cairo University)

---

## 📌 Overview

This project implements a fully functional 8-bit CPU based on a custom ISA specification.

The processor supports:

- 32 ISA Instructions
- 5-stage Pipelined Architecture
- Data Hazard Detection
- Forwarding Unit
- Branch Control Logic
- Interrupt Handling (RTI supported)
- Stack Operations (PUSH / POP)
- Von Neumann Memory Architecture
- FSM-based Control Unit

---

## 🏗 Processor Architecture

The processor consists of the following main components:

- Program Counter → `Pc.v`
- Register File → `Register_file.v`
- ALU → `another_ALU.v`
- Control Unit → `Control_unit.v`
- Condition Code Register → `CCR.v`
- Forwarding Unit → `FU.v`
- Hazard Unit → `HU.v`
- Branch Unit → `Branch_Unit.v`
- Interrupt Register → `interrupt_reg.v`
- Memory → `Memory.v`
- Output Register → `Out_reg.v`

Top-level integration of all modules is handled by:

```
CPU_WrapperV3.v
```

---

## ⚙ Pipeline Architecture

The processor implements a 5-stage pipeline:

1. IF  – Instruction Fetch  
2. ID  – Instruction Decode  
3. EX  – Execute  
4. MEM – Memory Access  
5. WB  – Write Back  

### Pipeline Registers Implemented:

- `IF_ID_reg.v`
- `ID_EX_Reg.v`
- `Ex_Mem.v`
- `MEM_WB_Reg.v`

These registers isolate pipeline stages and enable parallel instruction execution.

---

## 🚦 Hazard Handling

### 🔹 Data Hazards

- Detected by `HU.v`
- Resolved using forwarding logic implemented in `FU.v`
- Forwarding paths from:
  - EX/MEM stage
  - MEM/WB stage

This reduces unnecessary stalls and improves performance.

---

### 🔹 Control Hazards

- Managed using `Branch_Unit.v`
- Pipeline control logic performs stall and flush operations when required.

---

## ⚡ Interrupt Handling

On rising edge of interrupt signal:

- Current PC is pushed to stack
- Flags are preserved
- PC is loaded from memory location 1
- Interrupt Service Routine executes
- `RTI` restores PC and condition flags

Interrupt logic implemented in:

```
interrupt_reg.v
```

---

## 📂 RTL Structure

```
RTL/
│
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

## 🧪 Testbench

Testbench verifies:

- Arithmetic instructions (ADD, SUB, INC, DEC)
- Logical instructions (AND, OR, NOT)
- Branch instructions (JZ, JN, JC, JV)
- Memory operations (LDM, LDD, STD, LDI, STI)
- Stack operations (PUSH, POP)
- Interrupt behavior

Simulation performed using:

- ModelSim
- EDA Playground

---

## 🛠 Tools Used

- Verilog HDL
- ModelSim
- Git & GitHub

---

## 🎯 Key Learning Outcomes

- Pipelined CPU Design
- Hazard Detection & Forwarding
- Interrupt Mechanisms
- FSM-based Control Design
- Modular RTL Design
- Hardware Debugging & Simulation

---

## 👨‍💻 Author

Mostafa Farhan  
Electronics & Communications Engineering  
Cairo University
