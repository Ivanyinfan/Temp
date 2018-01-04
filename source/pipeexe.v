module pipeexe ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu ); // EXE stage
//EXE运算模块。其中包含ALU及多个多路器等。
	input         ealuimm,eshift,ejal;
	input  [31:0] ea,eb,eimm,epc4;
    input  [4:0]  ern0;
    input  [3:0]  ealuc;
    output [31:0] ealu;
    output [4:0]  ern;
	
	wire zero;
	wire [31:0] alua,alub,alu;
	//运算数a,b，运算类型，运算结果，结果是否是0
	mux2x32 alu_a (ea,eimm,eshift,alua);
	mux2x32 alu_b (eb,eimm,ealuimm,alub);
	alu al_unit (alua,alub,ealuc,alu,zero);
	wire [31:0] epc44=epc4+32'h4;
	mux2x32 alu_ealu (alu,epc44,ejal,ealu);
	mux2x5 select_ern(ern0,5'd31,ejal,ern);
endmodule