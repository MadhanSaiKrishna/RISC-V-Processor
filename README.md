# IPA Project (Spring 2025)

*Total Marks: 100*  

---

### Note:
1. In the Instruction Fetch stage:
      The MUX is just there, nothing to do with the functionality of IF stage for now, the select signal for the mux will be useful after the instruction is decoded and if it's a branch instruction then we have to use the zero output of the alu to get the select signal.
2. 


## 1. Overall Goal

Each group is required to develop a processor architecture design based on the *RISC-V ISA* using *Verilog*. The design must be thoroughly tested through simulations to ensure it meets all specification requirements. The project submission must include the following:

- *Report*: A detailed description of the design, including the various stages of the processor architecture, supported features (with simulation snapshots), and challenges encountered.
- *Verilog Code*: The processor design and testbench code.

---

## 2. Specifications

The processor design must meet the following specifications:

### Minimum Requirements:
- *Sequential Design*: A bare minimum processor architecture implementing a sequential design.

### Advanced Requirements:
- *Pipelined Design*: A 5-stage pipelined processor architecture with support for eliminating pipeline hazards.

*Note*: Your submission must at least include the sequential design to receive minimal marks. However, the goal is to submit a pipelined architecture.

### Supported Instructions:
Both implementations (sequential and pipelined) must execute the following RISC-V ISA instructions:
- add
- sub
- and
- or
- ld
- sd
- beq

---

## 3. Design Approach

The design should follow a *modular approach*:
- Each stage of the processor should be coded as a separate module.
- Test each module independently to ensure proper functionality before integration.
- This approach will help minimize issues during the integration phase.

---

## 4. Targets and Evaluation

The project will be evaluated twice:

1. *First Evaluation (February 24, 2025)*:
   - Expected completion: Sequential implementation.

2. *Final Evaluation (First week of March 2025)*:
   - Dates will be announced later.

---

## 5. Suggestions for Design Verification

To ensure the correctness of your design, follow these verification approaches:

1. *Module Testing*:
   - Test each stage/module individually with specific test inputs to verify its functionality.

2. *Assembly Program Testing*:
   - Write an assembly program for an algorithm (e.g., sorting algorithm) using the RISC-V ISA.
   - Encode the instructions and use them to test your integrated design.

3. *Automated Testbench* (Optional but recommended):
   - Develop an automated testbench to verify the state of the processor and memory after each instruction execution.

---

## 6. Evaluation Criteria

Marks will be assigned as follows:

| *Component*                     | *Marks* |
|------------------------------------|-----------|
| Report                             | 10        |
| Assignment                         | 15        |
| First Evaluation                   | 15        |
| Sequential Design Implementation   | 20        |
| Pipelined Design Implementation    | 40        |

---

## Contributors:
Roshan Kondabattini  
Chamarthy Madhan Sai Krishna  
Kaamya Dasika
