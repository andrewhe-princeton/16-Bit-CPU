This repository contains the design and implementation of a RISC 16-bit CPU

The CPU is built using digital logic components and follows a von Neumann architecture.

Features
- 16-bit data width
- 16-bit address bus
- 16 general-purpose registers
- Support for basic arithmetic and logical instructions
- Instruction set architecture (ISA) designed for simplicity and efficiency
Architecture Overview
The 16-bit CPU consists of the following main components:
- Control Unit (CU): Responsible for fetching instructions, decoding them, and controlling the execution flow of the CPU.
- Arithmetic Logic Unit (ALU): Performs arithmetic and logical operations on the data.
- Register File: Contains 16 general-purpose registers for storing data and intermediate results.
- Memory Interface: Provides an interface to connect the CPU to external memory for instruction and data storage.
- Instruction Set Architecture (ISA)

The CPU supports a simple and efficient instruction set, which includes:
- Arithmetic instructions: ADD, SUB, MUL, DIV
- Logical instructions: AND, OR, XOR, NOT
- Data transfer instructions: LOAD, STORE, MOVE
- Control flow instructions: JUMP, BRANCH, CALL, RETURN
- Refer to the ISA documentation for detailed information on the instruction formats and encoding.
