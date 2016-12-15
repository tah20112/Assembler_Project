//------------------------------------------------------------------------------
// This test bench simply runs all the test benches for the individual modules. 
//------------------------------------------------------------------------------
//`include "register.v"
//`include "alu.v"
//`include "cpu.v"
//`include "instMem.v"
//`include "pc.v"
//`include "register.v"
//`include "signExtend.v"
//`include "control.v"
//`include "datamemory.v"
`include "alu.t.v"
`include "datamem.t.v"
`include "instructionmem.t.v"
`include "signextend.t.v"
`include "cpu.t.v"

`timescale 1ns / 1ps

module fulltestbenchharness();
  alutestbenchharness alu();              // Tests alu and control
  datamemtestbenchharness datamem();      // Tests data memory
  instructionmemtestbenchharness inst();  // Tests instruction memory
  setestbenchharness se();                // Tests signextend
  cputestbenchharness cpu();              // Tests cpu

endmodule
