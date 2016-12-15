`timescale 1ns / 1ps

// Register
// 		Takes as input clk, ra_addr, rb_addr, wrEn, wd_addr, and wd. 
// 		Outputs ra and rb appropriately (the wd data written to ra_addr and rb_addr)

module register

#(parameter n = 32, parameter naddr = 5)

(
	input 			  clk,		//Clk 

	input [naddr-1:0] ra_addr,
	input [naddr-1:0] rb_addr,

	output [n-1:0] 	  ra,
	output [n-1:0] 	  rb,

	input 			  wrEn,    //RegWrite
	input [naddr-1:0] wd_addr, //WriteRegister
	input [n-1:0] 	  wd 	   //WriteData

);

// Register file storage
reg [n-1:0] registers [1000:0];

//setting $zero to be 0
initial begin
	registers[0] = 32'b0;
end

//write to register at the (next) posedge of clk in parallel
always @(posedge clk) begin
    if (wrEn) begin
    	// $display("%b", wd);
    	// $display("%b", wd_addr);
        registers[wd_addr] = wd;
        // $display("%b", registers[wd_addr]);
    end
end

//always output R[rs] and R[rt]
assign ra = registers[ra_addr];
assign rb = registers[rb_addr];

endmodule