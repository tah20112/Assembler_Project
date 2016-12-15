//------------------------------------------------------------------------
// Data Memory
//   Positive edge triggered
//   readData always has the value mem[address]
//   If MemWrite is true, writes writeData to mem[address]
//------------------------------------------------------------------------

`timescale 1ns / 1ps

module datamemory
#(
    parameter addresswidth  = 32,
    parameter depth = 10,
    parameter width = 32
)
(
    input 		                clk,      // Clock (Positive Edge Triggered)
    output [width-1:0]          readData, // Data read from data memory
    input  [addresswidth-1:0]   address,  // address
    input                       MemWrite, // Data memory write enable
    input                       MemRead,  // Data memory read enable
    input  [width-1:0]          writeData // Data to write to data memory
);


    reg [width-1:0] memory [16'h3fff:16'h3000]; //data memory allocation
    reg [width-1:0] readData_reg;

    always @(posedge clk) begin
        if(MemWrite)
            memory[address] <= writeData; //write data in parallel at next posedge
    end

    always @* begin
    if(MemRead)
        readData_reg <= memory[address];
    end

    assign readData = readData_reg;

endmodule

