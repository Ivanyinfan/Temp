module pipepc ( npc,wpcir,clock,resetn,pc );
//程序计数器模块，是最前面一级IF流水段的输入。
	input [31:0] npc;
	input wpcir,clock,resetn;
	output [31:0] pc;
	dffe32 ip (npc,clock,resetn,wpcir,pc);  // define a D-register for PC
endmodule