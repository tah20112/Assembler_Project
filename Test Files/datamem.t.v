//------------------------------------------------------------------------------
// Test harness validates datamemtestbench by connecting it to data memory, and verifying that it works
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

module datamemtestbenchharness
#(  parameter addresswidth  = 32,
    parameter depth = 10,
    parameter width         = 32);

  wire                    clk;      // Clock (Positive Edge Triggered)
  wire [width-1:0]	      readData;	// Data read from data memory
  wire [addresswidth-1:0] address;	// address
  wire                    MemWrite; // Data memory write enable
  wire                    MemRead;  // Data memory read enable
  wire [width-1:0]        writeData;// Data to write to data memory


  reg		  begintest;	// Set High to begin testing instMem
  wire		dutpassed;	// Indicates whether instMem passed tests

datamemory datamemtest
(
  .clk(clk),
  .readData(readData),
  .address(address),
  .MemWrite(MemWrite),
  .MemRead(MemRead),
  .writeData(writeData)
);

  // Instantiate test bench to test the DUT
  datamemtestbench tester
  (
    .begintest(begintest),
    .endtest(endtest), 
    .dutpassed(dutpassed),
    .clk(clk),
    .readData(readData),
    .address(address),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .writeData(writeData)
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
    $display("Data Mem passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// Data Memory test bench
//   Generates signals to drive data memory and passes them back up one
//   layer to the test harness.
//
//   Once 'begintest' is asserted, begin testing the data memory.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module datamemtestbench
(
// Test bench driver signal connections
input	   		  begintest,	// Triggers start of testing
output reg 		endtest,	  // Raise once test completes
output reg 		dutpassed,	// Signal test result

// ALU DUT connections
  output reg          clk,      // Clock (Positive Edge Triggered)
  input      [32-1:0] readData, // Data read from data memory
  output reg [32-1:0] address,  // address
  output reg          MemWrite, // Data memory write enable
  output reg          MemRead,  // Data memory read enable
  output reg [32-1:0] writeData // Data to write to data memory
  );


  // Initialize register driver signals
  initial begin
    clk=0;
    MemWrite = 0;
    MemRead = 0;
    writeData = 0;
    address = 0;
  end

  // Once 'begintest' is asserted, start running test cases
  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;
    #10

  // Test Case 1: 
    //   Write '16' to address '1', then read and check if readData == 16.
      address=32'd1; 
      MemWrite = 1;
      MemRead = 0;
      writeData = 32'd16;
    #5 clk=1; #5 clk=0;	// Generate single clock pulse
    #10
      address=32'd1; 
      MemWrite = 0;
      MemRead = 1;
      writeData = 32'd18;
    #5 clk=1; #5 clk=0; // Generate single clock pulse
    #10
       // Verify expectations and report test result
    if(readData != 16) begin
      dutpassed = 0;  // Set to 'false' on failure
      $display("Data Mem: Test Case 1 Failed");
  end

  // Test Case 2: 
    //   Write 32'hffff_ffff to register 2. Then read register 2. 
      address=32'd2; 
      MemWrite = 1;
      MemRead = 0;
      writeData = 32'd9999_9999;
    #5 clk=1; #5 clk=0; // Generate single clock pulse
    #10
    address=32'd2; 
      MemWrite = 0;
      MemRead = 1;
      writeData = 32'h0;
    #5 clk=1; #5 clk=0; // Generate single clock pulse
    #10
       // Verify expectations and report test result
    if((readData != 32'd9999_9999)) begin
      dutpassed = 0;  // Set to 'false' on failure
      $display("Data Mem: Test Case 2 Failed");
  end
    
  // Test Case 3: 
    //   Read address 1 and make sure readData is still 16.
      address=32'd1; 
      MemWrite = 0;
      MemRead = 1;
      writeData = 32'd0;
    #5 clk=1; #5 clk=0; // Generate single clock pulse
    #10
       // Verify expectations and report test result
    if(readData != 16) begin
      dutpassed = 0;  // Set to 'false' on failure
      $display("Data Mem: Test Case 3 Failed");
  end


  // All done!  Wait a moment and signal test completion.
  #5
  endtest = 1;
end

endmodule