//for checking with gtkwave for hexcode from asm
`include "cpu.v"

module cputest();

	reg clk;

	cpu test(.clk(clk));

	initial clk=0;
    always #100 clk=!clk; 

	initial begin
		$dumpfile("cpu.vcd");
	    $dumpvars();
	    #8000
	    $finish;
    end

endmodule
