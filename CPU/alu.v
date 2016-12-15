`timescale 1ns / 1ps

// ALU
// Takes as input the alucontrol signal to select the operation, 
// 		and two inputs to perform the operation on.
// Performs add, subtract, select-less-than, and xori on two inputs. 
// Outputs the result of the operation and 'zero', which is true if 
// 		the result is zero.

module alu(

  output [31:0] aluRes, 	// Result of ALU operation
  output 		zero,		// If aluRes == 0
  input [2:0] 	alucontrol,	// Control signal to select alu operation
  input [31:0] 	a, b 		// The two inputs of alu operation
);

	reg [31:0] aluRes_reg;  // Intermediate storing of ALU result

always @* begin 
	//add
	if (alucontrol == 3'b001) begin
		aluRes_reg <= a + b;
	end

	//sub
	else if (alucontrol == 3'b010) begin
		aluRes_reg <= a - b;
	end

	//slt
	else if (alucontrol == 3'b011) begin
		aluRes_reg <= (a < b) ? 32'b1 : 32'b0;
	end

	//xori
	else if (alucontrol == 3'b100) begin
		aluRes_reg <= a ^ b;
	end
	//otherwise, set output to zero
	else begin 
		aluRes_reg <= 32'b0;
	end

end
	assign zero = ~|aluRes_reg; // If aluRes = 32'b0, zero is true
	assign aluRes = aluRes_reg;	// Set aluRes for output

endmodule
