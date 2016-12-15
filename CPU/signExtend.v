`timescale 1ns / 1ps

//sign Extend
//	Takes as input 16-bit instruction, and sign extends it to 32 bits
// 		Example: seIn  = 1000_0101_0100_1100
//				 seOut = 1111_1111_1111_1111_1000_0101_0100_1100

module signExtend(seIn, seOut);

	input [15:0] seIn;
	output [31:0] seOut;

	assign seOut[15:0] = seIn;

	genvar i;
	generate
		for(i = 16; i < 32; i = i+1) 
    begin: gen1
			assign seOut[i] = seIn[15];	
		end
	endgenerate
endmodule
