`timescale 1ns / 1ps

// Instruction Memory
// 		Takes as input read_address (PC) and outputs the instruction for that value. 

module instMem
(
    input  [31:0]       read_address, //PC
    output [31:0]       instruction   //instruction
);
    reg [31:0] instructionMem [20:0]; // Instantiate the instructionMem

    initial $readmemh("assembled_code.dat", instructionMem); // Read the file containing the instructions
 	
    assign instruction = instructionMem[read_address>>2];	// Assign the appropriate data to instruction

endmodule
