module pipeexe ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu ); // EXE stage
//EXE运算模块。其中包含ALU及多个多路器等。
	input  [31:0] ea,eb,eimm,epc4;
    input  [4:0]  ern0;
    input  [3:0]  ealuc;
    input        ealuimm,eshift,ejal;
    output [31:0] ealu;
    output [4:0] ern;
	
	wire zero;//运算结果是不是0
	alu al_unit (ea,eb,ealuc,ealu,zero);
endmodule