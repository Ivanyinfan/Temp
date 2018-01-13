module pipeir ( pc4,ins,wpcir,clock,resetn,dpc4,inst,dbubble);
	input [31:0] pc4,ins;
	input wpcir,clock,resetn,dbubble;
	output [31:0] dpc4,inst;
	DffER32 savepc(pc4,clock,resetn,~wpcir,dbubble,dpc4);
	DffER32 saveinst(ins,clock,resetn,~wpcir,dbubble,inst);
endmodule