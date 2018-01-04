module pipeir ( pc4,ins,wpcir,clock,resetn,dpc4,inst,dbubble);
	input [31:0] pc4,ins;
	input wpcir,clock,resetn,dbubble;
	output [31:0] dpc4,inst;
	Bubble32 savepc(pc4,clock,resetn,dbubble,dpc4);
	Bubble32 saveinst(ins,clock,resetn,dbubble,inst);
endmodule