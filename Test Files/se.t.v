
// Decoder testbench
`timescale 1 ns / 1 ps
`include "signExtend.v"

module testsignextend ();

    reg [15:0] seIn;
    wire [31:0] seOut;
    

    //behavioralDecoder decoder (out0,out1,out2,out3,addr0,addr1,enable);
    signExtend dut (seIn,seOut); // Swap after testing

    initial begin
    $dumpfile("instruction.vcd");
    $dumpvars(0,testsignextend);
    $display("  SE  ");
    seIn = 16'hffff; #1000 
    $display("%b", seOut);
    end

endmodule