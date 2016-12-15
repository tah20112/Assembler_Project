//------------------------------------------------------------------------------
// Test harness to test cpu
//------------------------------------------------------------------------------
//`include "register.v"
//`include "alu.v"
//`include "alucontrol.v"
`include "cpu.v"
//`include "instMem.v"
//`include "pc.v"
//`include "register.v"
//`include "signExtend.v"
//`include "control.v"
//`include "datamemory.v"
//`include "alu.t.v"
//`include "datamem.t.v"
//`include "instructionmem.t.v"

`timescale 1ns / 1ps

module cputestbenchharness();

  wire        clk;              // Clock (Positive Edge Triggered)
  wire [31:0] datamem_readData; // Data read from data memory
  wire [31:0] writeData;        // Data to be written to data memory
  wire [31:0] addALUres;        // Result of PC + 4
  wire [31:0] reg_readData1;    // Data from first register port
  wire [31:0] reg_readData2;    // Data from second register port
  wire [31:0] ALUresult;        // Result from main ALU

  reg		  begintest;	// Set High to begin testing alu 
  wire		dutpassed;	// Indicates whether alu passed tests


  cpu cputest
  (
    .clk(clk),
    .datamem_readData(datamem_readData),
    .writeData(writeData),
    .addALUres(addALUres),
    .reg_readData1(reg_readData1),
    .reg_readData2(reg_readData2),
    .ALUresult(ALUresult)
  );

  // Instantiate test bench to test the DUT
  cputestbench tester
  (
    .begintest(begintest),
    .endtest(endtest), 
    .dutpassed(dutpassed),
    .clk(clk),
    .datamem_readData(datamem_readData),
    .writeData(writeData),
    .addALUres(addALUres),
    .reg_readData1(reg_readData1),
    .reg_readData2(reg_readData2),
    .ALUresult(ALUresult)
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
    $display("CPU passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// CPU test bench
//   Generates signals to drive CPU and passes them back up one
//   layer to the test harness. Each instruction in our test set is tested, and
//   an output from that cycle is selected to be tested for correctness
//
//   Once 'begintest' is asserted, begin testing the CPU.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module cputestbench
  #(parameter clktime = 1)
  (
    // Test bench driver signal connections
    input	   		  begintest,	// Triggers start of testing
    output reg 		endtest,	  // Raise once test completes
    output reg 		dutpassed,	// Signal test result


    // ALU DUT connections
    output reg    clk,
    input [31:0]  datamem_readData, // Data read from data memory
    input [31:0]  writeData,        // Data to be written to data memory
    input [31:0]  addALUres,        // Result of PC + 4
    input [31:0]  reg_readData1,    // Data from first register port
    input [31:0]  reg_readData2,    // Data from second register port
    input [31:0]  ALUresult         // Result from main ALU
  );

  // Initialize register driver signals
  initial begin
    clk = 0;
  end

  // Once 'begintest' is asserted, start running test cases
  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;
    #10

  // Test Case 1: 
  //   Run first instruction: to pass, writeData = 3ffc.
  // First case takes place before first clock cycle
  if(writeData != 32'h3ffc) begin
    dutpassed = 0;	// Set to 'false' on failure
    $display("CPU: Test Case 1 Failed");
  end

  // Test Case 2: 
  //   Run second instruction: to pass, writeData = 4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(writeData != 4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 2 Failed");
  end

  // Test Case 3: 
  //   Run third instruction: to pass, writeData = 1.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(writeData != 1) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 3 Failed");
  end

  // Test Case 4: 
  //   Run fourth instruction: to pass, addALUres = 14098h.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h014098) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 4 Failed");
  end


  // Test Case 5: 
  //   Run fifth instruction: to pass, addALUres = 16094.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h16094) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 5 Failed");
  end

  // Test Case 6: 
  //   Run sixth instruction: to pass, reg_readData1 = 1.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h1) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 6 Failed");
  end

  // Test Case 7: 
  //   Run seventh instruction: to pass, reg_readData1 = 4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h0) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 7 Failed");
  end

  // Test Case 8: 
  //   Run eigth instruction: to pass, writeData = 3ff8.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(writeData != 32'h3ff8) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 8 Failed");
  end

  // Test Case 9: 
  //   Run 9th instruction: to pass, reg_readData1 = 3ff8.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h3ff8) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 9 Failed");
  end

  // Test Case 10: 
  //   Run 10th instruction: to pass, reg_readData1 = 3ff4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h3ff4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 10 Failed");
  end

  // Test Case 11: 
  //   Run 11th instruction: to pass, reg_readData2 = 1.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData2 != 32'h1) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 11 Failed");
  end

  // Test Case 12: 
  //   Run 12th instruction: to pass, datamem_readData = 4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(datamem_readData != 32'h4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 12 Failed");
  end

  // Test Case 13: 
  //   Run 13th instruction: to pass, datamem_readData = 1.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(datamem_readData != 32'h1) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 13 Failed");
  end

  // Test Case 14: 
  //   Run 14th instruction: to pass, addALUres = ffffa0c0.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'hffffa0c0) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 14 Failed");
  end

  // Test Case 15: 
  //   Run 15th instruction: to pass, ALUresult = 3ffc.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(ALUresult != 32'h3ffc) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 15 Failed");
  end

  // Test Case 16: 
  //   Run 16th instruction: to pass, reg_readData1 = 1c.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h1c) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 16 Failed");
  end

  // Test Case 17: 
  //   Run 17th instruction: to pass, reg_readData1 = 4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 17 Failed");
  end

  // Test Case 18: 
  //   Run 18th instruction: to pass, addALUres = 100d4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h100d4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 18 Failed");
  end

  // Test Case 19: 
  //   Run 19th instruction: to pass, addALUres = 70.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h70) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 19 Failed");
  end

  // Test Case 20: 
  //   Run 20th instruction: to pass, writeData = 2.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(writeData != 32'h2) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 20 Failed");
  end

  // Test Case 21: 
  //   Run 21st instruction: to pass, addALUres = 100d4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h100d4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 21 Failed");
  end

  // Test Case 22: 
  //   Run 22nd instruction: to pass, addALUres = 70.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h70) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 22 Failed");
  end

  // Test Case 23: 
  //   Run 23rd instruction: to pass, writeData = 1.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(writeData != 32'h1) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 23 Failed");
  end

  // Test Case 24: 
  //   Run 24th instruction: to pass, addALUres = 100d4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h100d4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 24 Failed");
  end

  // Test Case 25: 
  //   Run 25th instruction: to pass, reg_readData1 = 1c.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData1 != 32'h1c) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 25 Failed");
  end

  // Test Case 26: 
  //   Run 26th instruction: to pass, reg_readData2 = 1.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(reg_readData2 != 32'h1) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 26 Failed");
  end

  // Test Case 27: 
  //   Run 27th instruction: to pass, addALUres = 74.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'h74) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 27 Failed");
  end

  // Test Case 28: 
  //   Run 28th instruction: to pass, addALUres = a4.

  #clktime clk=1;  #clktime clk=0;  // Generate single clock pulse
  // Verify expectations and report test result
  if(addALUres != 32'ha4) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("CPU: Test Case 28 Failed");
  end

  // All done!  Wait a moment and signal test completion.

  #5
  endtest = 1;

end

endmodule