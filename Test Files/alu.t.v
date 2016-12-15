//------------------------------------------------------------------------------
// Test harness validates alutestbench by connecting it to alucontrol
//    and sending the control signals generated to the alu,
//    then verifying that it works as intended.
//------------------------------------------------------------------------------
//`include "register.v"
//`include "alu.v"
//`include "alucontrol.v"
//`include "cpu.v"
//`include "instMem.v"
//`include "pc.v"
//`include "register.v"
//`include "signExtend.v"
//`include "control.v"
//`include "datamemory.v"

`timescale 1ns / 1ps

module alutestbenchharness();

  wire [31:0]	aluRes;	// alu result output
  wire        zero;	  // alu output (if output is zero = 1)
  wire [31:0]	a, b;	  // the two 31-bit inputs to be operated on
 
  wire [5:0]  instruction;       //instruction[31:26]
  wire [5:0]  instruction_funct;  //instruction[5:0]

  wire  [1:0] RegDst;             //Mux for Register_WriteRegister_in
  wire        Branch;             //AND with ALU_Zero_out to get PCSrc
  wire        MemRead;            //read data from data memory
  wire  [1:0] MemtoReg;           //Mux for selecting between DataMemory_ReadData_out
  wire  [2:0] ALUOp;              //for ALU control
  wire        MemWrite;           //write data to data memory
  wire        ALUSrc;             //goes to ALU control
  wire        RegWrite;           //Register write signal
  wire  [1:0] Jump;               //Jump signal

  reg		      begintest;	// Set High to begin testing alu
  wire		    dutpassed;	// Indicates whether alu passed tests



control ALUcontroltest  //instantiate control 
(
  .instruction(instruction),
  .instruction_funct(instruction_funct),
  .RegDst(RegDst),
  .Branch(Branch),
  .MemRead(MemRead),
  .MemtoReg(MemtoReg),
  .ALUOp(ALUOp),
  .MemWrite(MemWrite),
  .ALUSrc(ALUSrc),
  .RegWrite(RegWrite),
  .Jump(Jump)
  );

alu ALUtest  //instantiate alu
(
  .aluRes(aluRes),
  .zero(zero),
  .alucontrol(ALUOp),
  .a(a),
  .b(b)
);


  // Instantiate test bench to test the DUT
alutestbench tester
(
  .begintest(begintest),
  .endtest(endtest),
  .dutpassed(dutpassed),

  .aluRes(aluRes),
  .zero(zero),
  .a(a),
  .b(b),

  .instruction(instruction),
  .instruction_funct(instruction_funct),
  .RegDst(RegDst),
  .Branch(Branch),
  .MemRead(MemRead),
  .MemtoReg(MemtoReg),
  .ALUOp(ALUOp),
  .MemWrite(MemWrite),
  .ALUSrc(ALUSrc),
  .RegWrite(RegWrite),
  .Jump(Jump)
);

  // Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    begintest=0;
    #10;
    begintest=1;
    #1000;
  end

  // Display test results ('dutpassed' signal) once 'endtest' goes high
  always @(posedge endtest) begin
    $display("ALU passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// ALU test bench
//   Generates signals to drive control, uses control signals to drive alu, and passes them back up one
//   layer to the test harness.
//
//   Once 'begintest' is asserted, begin testing the control and alu.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module alutestbench
(
// Test bench driver signal connections
input	   		  begintest,	// Triggers start of testing
output reg 		endtest,	  // Raise once test completes
output reg 		dutpassed,	// Signal test result

// ALU DUT connections
  input [31:0]      aluRes,      // alu result output
  input             zero,        // alu output (if output is zero = 1)
  output reg [31:0] a, b,        // the two 31-bit inputs to be operated on
 
  output reg [5:0]  instruction,        //instruction[31:26]
  output reg [5:0]  instruction_funct,  //instruction[5:0]

  input  [1:0] RegDst,             //Mux for Register_WriteRegister_in
  input        Branch,             //AND with ALU_Zero_out to get PCSrc
  input        MemRead,            //read data from data memory
  input  [1:0] MemtoReg,           //Mux for selecting between DataMemory_ReadData_out
  input  [2:0] ALUOp,              //for ALU control
  input        MemWrite,           //write data to data memory
  input        ALUSrc,             //goes to ALU control
  input        RegWrite,           //Register write signal
  input  [1:0] Jump                //Jump signal
);

  // Initialize register driver signals
  initial begin
    instruction_funct=6'b100000;
    instruction = 6'b000000;
    a=32'd0;
    b=32'd0;
    // clk=0;
  end

  // Once 'begintest' is asserted, start running test cases
  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;
    #10

  // Test Case 1:
  //   Add 'a' and 'b': a = 30, b = 1.
  //   To pass, aluRes = 31.
    instruction_funct=6'b100000; // add instruction
    instruction = 6'b000000;     // add, sub, slt, jr instruction
    a=32'd30;
    b=32'd1;
    #10
  // Verify expectations and report test result
  if((aluRes != 31) || (zero != 0)) begin
    dutpassed = 0;	// Set to 'false' on failure
    $display("ALU: Test Case 1: Addition Failed");
  end

  // Test Case 2:
  //   Subtract 'b' from 'a', a = 45, b = 5.
  //   To pass, aluRes = 40, zero = 0.
    instruction_funct=6'b100010;// sub instruction
    instruction = 6'b000000;    // add, sub, slt, jr instruction
    a=32'd45;
    b=32'd5;
    #10
  if((aluRes != 40) || (zero != 0)) begin
    dutpassed = 0;
    $display("ALU: Test Case 2: Subtraction Failed");
  end

  // Test Case 3:
  //   Select-less-than a and b. a = 5, b = 6.
  //   To pass, aluRes = 1.
    instruction_funct=6'b101010;// slt instruction
    instruction = 6'b000000;    // add, sub, slt, jr instruction
    a=32'd5;
    b=32'd6;
  #10
  if((aluRes != 1) || (zero != 0)) begin
    dutpassed = 0;
    $display("ALU: Test Case 3: SLT Failed");
  end

  // Test Case 4:
  //   Xori a and b. a = 5, b = 6.
  //   To pass, aluRes = 3
    instruction_funct=6'b00_1110; 
    instruction = 6'b001110;      // xori instruction
    a=32'd5;
    b=32'd6;
  #10
  if((aluRes != 3) || (zero != 0)) begin
    dutpassed = 0;
    $display("ALU: Test Case 4: Xori Failed");
  end

  // Test Case 5:
  //   SLT a and b. a = 7, b = 6.
  //   To pass, aluRes = 0 and zero = 1
    instruction_funct=6'b101010;// slt instruction
    instruction = 6'b000000;    // add, sub, slt, jr instruction
    a=32'd7;
    b=32'd6;
    #10
  if((aluRes != 0) || (zero != 1)) begin
    dutpassed = 0;
    $display("ALU: Test Case 5: zeros Failed");
  end

  // All done!  Wait a moment and signal test completion.
  #5
  endtest = 1;

end

endmodule
