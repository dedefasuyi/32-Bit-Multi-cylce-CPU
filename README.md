# 32-Bit-Multi-cylce-CPU



Final Project – Spring 2023
Oluwademilade Fasuyi Section 002










Introduction:
The design of the multi-cycle implementation is well-organized to handle instructions of the R-type, I-type, and J-type. The multi-cycle CPU comprises various components, including a Control Unit, a Program Counter, and both state and combinational logic. 

All instructions use a set of common components that includes the instruction memory, program counter (PC), and adder for performing instruction fetch. The PC provides the address to the instruction memory, which outputs the instruction contents. The adder increments the PC to the address of the next instructionF. R-type instructions use the Registerfile, which has two read registers for rt and rd, one write register for rd, and a write data register for inputs, along with two read data values for outputs. The ALU performs arithmetic and logical operations for the instructions, and the control unit selects the ALU operation using the aluc control signal. For I-type instructions, the Load and Store instructions use read data 1 from the Registerfile as the base register value for the ALU and read data 2 as the data value to be stored in data memory. The MemRead and MemWrite controls determine whether to read or write data memory. The Signextend and Data Memory components are used for Load and Store instructions. The Branch instruction compares the contents of two registers and shifts the 16-bit offset left by 2 bits to get the word address. The shifted offset value is added to the value of PC + 4 to get the branch target address. If the operands are equal, the PC is updated with the branch target, and the instruction fetch datapath is modified to allow the PC to be updated with the new value. J-type instructions require a different address calculation. The lower 28 bits of the PC are replaced with the 26 bits from the instruction, shifted left 2 bits and added using the input (jpc) from multiplexer 4to1. The control signal jal determines the jump and link instruction with two multiplexers used to pass the values for the instructions into the Registerfile.

This type of architecture is important in computer organization and design because it is simple and can be designed easier for many applications than other, more complex architectures. Pipelining with this architecture is effective and cheap, making it adequate for many applications.

