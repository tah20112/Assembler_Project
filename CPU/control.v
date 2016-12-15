`timescale 1ns / 1ps

module control
(
	input			 clk,
	input [5:0] 	 instruction, 		//instruction[31:26]
	input [5:0]  	 instruction_funct, //instruction[5:0]

	output reg [1:0] RegDst, 	//Mux for Register_WriteRegister_in
	output reg 		 Branch, 	//AND with ALU_Zero_out to get PCSrc
	output reg 		 MemRead, 	//read data from data memory
	output reg [1:0] MemtoReg, 	//Mux for selecting between DataMemory_ReadData_out
	output reg [2:0] ALUOp, 	//for ALU control
	output reg 		 MemWrite, 	//write data to data memory
	output reg 		 ALUSrc, 	//goes to ALU control
	output reg 		 RegWrite,	//Register Write enable
	output reg [1:0] Jump		//Jump MUX signal
);

initial begin //set all signals to zero
	RegDst <= 2'b00;
	RegWrite <= 0;
	ALUSrc <= 0;
	MemWrite <= 0;
	MemRead <= 0;
	MemtoReg <= 2'b00;
	Branch <= 0;
	Jump <= 2'b00;
	ALUOp <= 3'b000;
end

always @* begin

	case(instruction)

		6'b000000: begin //add, sub, slt, jr
			RegDst <= 2'b00;
			RegWrite <= 1; 
			ALUSrc <= 0;
			MemWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 2'b00;
			Branch <= 0;
			if (instruction_funct == 6'b001000) begin //jr
				Jump <= 2'b10;
				ALUOp <= 3'b000;
			end 
			else if (instruction_funct == 6'b100000) begin //add
				ALUOp <= 3'b001;
				Jump <= 2'b00;
			end 
			else if (instruction_funct == 6'b100010) begin //sub
				ALUOp <= 3'b010;
				Jump <= 2'b00;
			end
			else if (instruction_funct == 6'b101010) begin //slt
				ALUOp <= 3'b011;
				Jump <= 2'b00;
			end
		end

		6'b001110: begin //xori
			RegDst <= 2'b01;
			RegWrite <= 1;
			ALUSrc <= 1;
			MemWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 2'b00;
			Branch <= 0;
			Jump <= 2'b00;
			ALUOp <= 3'b100;
		end

		6'b000101: begin //bne
			RegDst <= 2'b00;
			RegWrite <= 0;
			ALUSrc <= 0;
			MemWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 2'b00;
			Branch <= 1;
			Jump <= 2'b00;
			ALUOp <= 3'b010;
		end

		6'b000010: begin //j
			RegDst <= 2'b00;
			RegWrite <= 0;
			ALUSrc <= 0;
			MemWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 2'b00;
			Branch <= 0;
			Jump <= 2'b01;
			ALUOp <= 3'b000;
		end

		6'b000011: begin //jal
			RegDst <= 2'b10;
			RegWrite <= 1;
			ALUSrc <= 0;
			MemWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 2'b10;
			Branch <= 0;
			Jump <= 2'b01;
			ALUOp <= 3'b000;
		end

		6'b100011: begin //lw
			RegDst <= 2'b00;
			RegWrite <= 1;
			ALUSrc <= 1;
			MemWrite <= 0;
			MemRead <= 1;
			MemtoReg <= 2'b01;
			Branch <= 0;
			Jump <= 2'b00;
			ALUOp <= 3'b001;
		end

		6'b101011: begin //sw
			RegDst <= 2'b00;
			RegWrite <= 0;
			ALUSrc <= 1;
			MemWrite <= 1;
			MemRead <= 0;
			MemtoReg <= 2'b00;
			Branch <= 0;
			Jump <= 2'b00;
			ALUOp <= 3'b001;
		end

		default: begin //revert signals to zero if none of the above cases are triggered
			RegDst <= 2'b00;
			RegWrite <= 0;
			ALUSrc <= 0;
			MemWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 2'b00;
			Branch <= 0;
			Jump <= 2'b00;
			ALUOp <= 3'b000;
		end

	endcase
end
endmodule