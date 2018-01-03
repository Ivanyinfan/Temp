module pipeemreg ( ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,
	mwreg,mm2reg,mwmem,malu,mb,mrn); // EXE/MEM流水线寄存器
	//EXE/MEM流水线寄存器模块，起承接EXE阶段和MEM阶段的流水任务。
	//在clock上升沿时，将EXE阶段需传递给MEM阶段的信息，锁存在EXE/MEM
	//流水线寄存器中，并呈现在MEM阶段。
	input clock,resetn;
	input ewreg,em2reg,ewmem;
	input [4:0] ern;
	input [31:0] ealu,eb;
	
	output mwreg,mm2reg,mwmem;
	output [4:0] mrn;
	output [31:0] malu,mb;
	
	dff1  savemwreg(ewreg,clock,resetn,mwreg);
	dff1  savemm2reg(em2reg,clock,resetn,mm2reg);
	dff1  savemwmem(ewmem,clock,resetn,mwmem);
	dff5  savemrn(ern,clock,resetn,mrn);
	dff32 savemalu(ealu,clock,resetn,malu);
	dff32 savemb(eb,clock,resetn,mb);
endmodule