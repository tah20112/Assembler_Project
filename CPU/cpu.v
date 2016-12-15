`include "control.v"
`include "alu.v"
`include "register.v"
`include "pc.v"
`include "datamemory.v"
`include "signExtend.v"
`include "instMem.v"

`timescale 1ns / 1ps

// Two-input MUX for branching
module mux2 #(parameter W = 32)
    (
        input[W-1:0]    in0,
        input[W-1:0]    in1,
        input           sel,
        output[W-1:0]   out
    );
        assign out = (sel) ? in1 : in0;
endmodule

// Three-input MUX for jumping
module mux3 #(parameter W = 32)
    (
        input[W-1:0]    in0,
        input[W-1:0]    in1,
        input[W-1:0]	in2,
        input [1:0]     sel,
        output reg [W-1:0]   out
    );
        always @ (sel or in0 or in1 or in2)
    	begin : MUX
    	 case(sel) 
    	    2'b00 : out = in0;
    	    2'b01 : out = in1;
    	    2'b10 : out = in2;
    	    default: out = 0;
    	 endcase 
    	end
endmodule

// Adds 4 to PC
module add_pc
    (
        input [31:0]   in,
        output [31:0]  out
    );
        assign out = in + 4;
endmodule

// ALU adder for PC: adds (PC + 4) and sign extended instruction
module add_alu
    (
        input [31:0]    in0,
        input [31:0]    in1,
        output [31:0]   out
    );
        assign out = in0 + (in1<<2);
endmodule



// Main CPU module: runs all of the other modules and connects their inputs and outputs
module cpu
(
	input         clk,				// Clock (Positive Edge Triggered)
    output [31:0] datamem_readData, // Data read from data memory
    output [31:0] writeData,        // Data to be written to data memory
    output [31:0] addALUres,        // Result of PC + 4
    output [31:0] reg_readData1,    // Data from first register port
    output [31:0] reg_readData2,    // Data from second register port
    output [31:0] ALUresult         // Result from main ALU
);

	wire [31:0] pc_in;      // PC input
	wire [31:0] branch_out; // Branch mux output
	wire [31:0] pc_out;     // PC output
	wire [31:0] inst;       // 32-bit instruction from instruction memory

	wire [1:0]  RegDst;     // Mux for Register_WriteRegister_in
	wire        Branch;     // AND with ALU_Zero_out to get PCSrc
	wire        MemRead;    // Read data from data memory
	wire [1:0]  MemtoReg;   // Mux for selecting between DataMemory_ReadData_out
	wire [2:0]  ALUop;      // For ALU control
	wire        MemWrite;   // Write data to data memory
	wire        ALUsrc;     // Goes to ALU control
	wire        RegWrite;   // Register write enable
	wire [1:0]  Jump;       // Jump Mux control signal

	wire [4:0]  writeRegister; // Write data address for register

	wire [31:0] SEinst;  	//Output of sign extender
	wire [31:0] ALU_in;  	//Input for ALU (output of ALUsrc mux)
	wire        ALUzero; 	// Output of ALU: if result is zero, ALUzero = 1

	wire [31:0] pc4_out; 	// Output of PC + 4

    // Run PC
	pc cpuPC(.clk(clk), 
			 .pc_in(pc_in), 
			 .pc_out(pc_out));

    // Use PC output as input to instruction memory, recieve instruction
	instMem cpuIM(.read_address(pc_out), 
				  .instruction(inst));

    // Select correct control signals based on instruction
	control cpuControl(.instruction(inst[31:26]), //op code
					   .instruction_funct(inst[5:0]), //funct code
					   .RegDst(RegDst), 
					   .Branch(Branch),
					   .Jump(Jump),
					   .MemRead(MemRead), 
					   .MemtoReg(MemtoReg), 
					   .ALUOp(ALUop), 
					   .MemWrite(MemWrite), 
					   .ALUSrc(ALUsrc), 
					   .RegWrite(RegWrite));

    // Select between three addresses for the data to be written in register
	mux3 #(5) mux5_inst_reg(.in1(inst[20:16]), //rt
		                    .in0(inst[15:11]), //rd
		                    .in2(5'd31), //reg[$31]
		                    .sel(RegDst), 
		                    .out(writeRegister));

    // Register, reads and writes to appropriate addresses
	register cpuRegister(.clk(clk), 
						 .ra_addr(inst[25:21]), //rs
						 .rb_addr(inst[20:16]), //rt
						 .wrEn(RegWrite), 
						 .wd_addr(writeRegister), 
						 .wd(writeData), 
						 .ra(reg_readData1), 
						 .rb(reg_readData2));

    // Sign extends instruction
	signExtend cpuSE(.seIn(inst[15:0]), 
		             .seOut(SEinst));

    // Selects between reg_readData2 and the sign-extended instruction
    //      for input into the ALU
	mux2 mux_reg_alu(.in0(reg_readData2), 
		             .in1(SEinst), 
		             .sel(ALUsrc), 
		             .out(ALU_in));

    // Main ALU, performs approptiate operation on data
	alu cpuALU(.alucontrol(ALUop), 
		       .a(reg_readData1), 
		       .b(ALU_in), 
		       .aluRes(ALUresult), 
		       .zero(ALUzero));

    // Data memory, written to and read from as instructed
	datamemory cpu_dm(.clk(clk), 
		              .readData(datamem_readData), 
		              .address(ALUresult), 
		              .MemWrite(MemWrite), 
		              .MemRead(MemRead), 
		              .writeData(reg_readData2));

    // Adds 4 to PC
	add_pc cpu_add_pc(.in(pc_out), 
		              .out(pc4_out));

    // Data memory mux for register write data
	mux3 mux_datamem(.in0(ALUresult), 
		             .in1(datamem_readData), 
		             .in2(pc4_out),
		             .sel(MemtoReg), 
		             .out(writeData));

    // ALU adder for PC: adds (PC + 4) and sign extended instruction
	add_alu cpu_add_alu(.in0(pc4_out),
		                .in1(SEinst), 
		                .out(addALUres));

    // Mux for branching
	mux2 mux_branch(.in0(pc4_out), 
		            .in1(addALUres), 
		            .sel(Branch & !ALUzero), 
		            .out(branch_out));

    // Mux for jumping
	mux3 mux_jump(.in0(branch_out), 
		          .in1({pc4_out[31:28], inst[25:0], 2'b00}), //jump address
		          .in2(reg_readData1),
		          .sel(Jump), 
		          .out(pc_in));

endmodule