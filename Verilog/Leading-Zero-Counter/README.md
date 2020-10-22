# Digital Design of a Leading Zero Counter using Recursion in Verilog

A “Leading Zero Counter” (LZC) determines the number of zeros in a binary number up to the most significant 1. For example, the 8-bit number, 00010101 has three leading zeros, 1000000 has none and 00000000 has eight. Finding the LZC is useful in a variety of applications such as floating-point normalization and calculating the reciprocal square root of a number using Newton’s Method. This article introduces a digital hardware design for finding the leading zero count of an 8-bit number using only wires and multiplexers that are recursively instantiated during HDL compile time.
Hardware Overview

The following LZC design uses a ‘divide and conquer’ algorithm that enables it to be recursively instantiated as a Verilog module. The 8-bit input is continually split in half, as a left-hand side (LHS) and right-hand side (RHS), until the input signal is 2-bits wide. Once the input signal is 2-bits wide, it is fed into a multiplexer that returns the corresponding 2-bit LZC. The LHS and RHS are then combined and decoded to output the leading zero count for the next stage. This is repeated until the last decoding at the top level.

## 8-Bit Logic Diagram using Digital
![](./images/Fig1.PNG?raw=true)

Fig. 1 Combinational logic for an 8-bit LZC using only multiplexers and bit concatenation wires.

## 8-Bit LZC Top-Level using Verilog
![](./images/Fig2.PNG?raw=true)

Fig.2 Verilog LZC top-level module. The IO encapsulates all signals and parameters for recursive module instantiation. The input width is 8 and the output width is log2(8)+1 = 4.

The Verilog leading_zero_cnt module includes a generate statement that allows for conditional logic instantiation. Within the generate block are two conditional cases; a base case and a recursive case.

## Base Case: 2-Bit Multiplexer

When a hardware module is instantiated recursively, all the wires and logic must be determined at HDL compile time. This means that the continuous splitting of the input until it reaches the base case is done 'instantaneously' with wires and does not take time to procedurally reach. The top-level input is routed directly into the base case because all other logic depends on the base case output.


![](./images/Fig3.PNG?raw=true)
Fig. 3 If the Input Width (WI_SZ) is equal to two bits, then instantiate base case multiplexer.

The base case logic is simply a multiplexer that uses the 2-bit signal, 'in' , as a control signal to output the corresponding leading zeros.

![](./images/Fig4.PNG?raw=true)
Fig. 4 Multiplexer diagram of base case logic.

The base case output is routed as either a LHS or RHS signal to the module that called it. In the module that called the base case, the LHS and RHS needs to be decoded into a single LZC output to propagate to the next calling module. This is done with logic instantiated within the 'Recursive Case'.
Recursive Case: Module Instantiation

The recursive case splits its input signal into a LHS and RHS signal. The split signals are then used to instantiate the same module again.

![](./images/Fig5.PNG?raw=true)
Fig. 5 Verilog for the module instantiation and their corresponding parameters.

The output LZC of the LHS and RHS modules that are recursively instantiated need to be decoded into the next LZC output. The following Verilog decodes the LHS and RHS LZC into a single LZC output.

![](./images/Fig6.PNG?raw=true)
Fig. 6 Verilog for decoding the LZC output from the LHS and RHS modules. Only a single multiplexer is used, along with wires for concatenating bits together.

The following is the logic diagram that corresponds to the Verilog in Fig. 6.


![](./images/Fig7.PNG?raw=true)
Fig. 7 displays the logic diagram corresponding to the Verilog in Fig. 6. There are some extra bit concatenation wires in the diagram compared to the Verilog. Such as {1, RHS_no_MSB} really being {01, RHS_no_MSB}. This is needed for simulation using 'Digital'.

The reasoning for this logic is explored below with a truth table for a 2-bit LHS/RHS.

![](./images/Table1.PNG?raw=true)
Table 1. shows the LHS and RHS decoder logic with 2-bit Input, 3-bit Output and a 2-bit control signal. Note: “{}” is the concatenation operator in Verilog and “X” is don’t care.
No alt text provided for this image

The multiplexer output, “Output LZC”, is formed by decoding the left and right LZC using bit concatenations as a “Logic Operation”. The "Control" signal is the most significant bit of the left and right LZC concatenated to each other.
Logic Operation Explanations

Control: 0X Operation: {0, LHS}

The first two logic cases in Table 1. are when the LHS LZC is less than its max count. This can be determined when the most significant bit in the LHS LZC is a zero. 

For this case, the output is just the LHS LZC. Since the RHS doesn’t matter, its most significant bit is represented as an “X” or a “don’t care”.

NOTE: A 0 is prepended to the most significant bit when simulating with 'Digital' so that the mux input width is the same as the output.

Control: 10 and 11

When the LHS LZC is maxed out, then the RHS LZC needs to be considered. There are two unique cases when considering the RHS LZC; when the RHS LZC is not maxed out and when it is.

Control: 10 Operation: {1,RHS_no_MSB}

When the RHS LZC is less than max, the combined LZC for the output is created by reshaping the RHS LZC using just wires.

First, the RHS LZC is truncated by removing its most significant-bit and then a 1 is prepended as the most significant bit.

This is a faster way to add the LHS and RHS LZC without using an adder.

Control: 11 Operation: {RHS, 0}

When both the RHS and LHS LZC are max, the combined LZC is the RHS(or LHS) LZC appended with a 0 to its least significant bit.

 This is a simplification for adding the right and left with an overflow without needing an adder.

## Conclusion

An 8-bit Leading Zero Counter (LZC) was explored. The design utilized a 'divide and conquer' hardware algorithm that continually split the initial input into a left-hand side (LHS) and right-hand side (RHS) until the input is only 2-bits wide. Once the 2-bit width base case was reached, a multiplexer returns the LZC for the 2-bit input. The 2-bit LZC output signals are routed as either a LHS or RHS into the module that instantiated it. The LHS and RHS are decoded into a single LZC using a multiplexer and bit concatenation wires. The decoded LZC is output to the next module as either a LHS or RHS signal. The process of decoding a LHS and RHS LZC into a single output LZC is repeated until after the last decoding at the module that was initially instantiated (top level).
Stay In Touch

Thank you for reading. I hope that you found the material useful.

Tool Suite, HDL Design, Simulation and Synthesis.

EDA Playground, HDL IDE, 32-Bit LZC at EDA Playground

Icarus Verilog, Simulation and Synthesis, http://iverilog.icarus.com/

Yosys, Open Synthesis Suite, http://www.clifford.at/yosys/

Digital, "A simple simulator for digital circuits", https://github.com/hneemann/Digital