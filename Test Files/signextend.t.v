//------------------------------------------------------------------------------
// Test harness validates signExtend
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

module setestbenchharness();

  wire [15:0] seIn;    // Clock (Positive Edge Triggered)
  wire [31:0] seOut; 

  reg   begintest;  // Set High to begin testing instMem
  wire    dutpassed;  // Indicates whether instMem passed tests

signExtend se
(
  .seIn(seIn),
  .seOut(seOut)
);

  // Instantiate test bench to test the DUT
  setestbench tester
  (
    .begintest(begintest),
    .endtest(endtest), 
    .dutpassed(dutpassed),
    .seIn(seIn),
    .seOut(seOut)
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
    $display("SE passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// Sign Extend test bench
//   Generates signals to drive sign extend and passes them back up one
//   layer to the test harness.
//
//   Once 'begintest' is asserted, begin testing the sign extend.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module setestbench
(
// Test bench driver signal connections
input       begintest,  // Triggers start of testing
output reg    endtest,  // Raise once test completes
output reg    dutpassed,  // Signal test result

// ALU DUT connections
  output reg [15:0] seIn,    // Clock (Positive Edge Triggered)
  input [31:0]  seOut
  );


  // Initialize register driver signals
  initial begin
    seIn = 16'h0;
  end

  // Once 'begintest' is asserted, start running test cases
  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;
    #10

  // Test Case 1: 
  //   Sign extend seIn= 16'hffff. To pass, output 32'hffff_ffff
    seIn = 16'hffff;
  #10
     // Verify expectations and report test result
  if(seOut != 32'hffff_ffff) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("SE: Test Case 1 Failed");
  end

  // Test Case 2: 
  //   Sign extend seIn= 16'h7fff. To pass, output 32'h7fff
    seIn = 16'h7fff;
  #10
     // Verify expectations and report test result
  if(seOut != 32'h7fff) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("SE: Test Case 2 Failed");
  end

  // Test Case 3: 
  //   Sign extend seIn= 16'h8000. To pass, output 32'hffff_8000
    seIn = 16'h8000;
  #10
     // Verify expectations and report test result
  if(seOut != 32'hffff_8000) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("SE: Test Case 3 Failed");
  end

  // Test Case 4: 
  //   Sign extend seIn= 16'h4000. To pass, output 32'4000
    seIn = 16'h4000;
  #10
     // Verify expectations and report test result
  if(seOut != 32'h4000) begin
    dutpassed = 0;  // Set to 'false' on failure
    $display("SE: Test Case 4 Failed");
  end


  // All done!  Wait a moment and signal test completion.
  #5
  endtest = 1;
end

endmodule