module pipemwreg ( mwreg,mm2reg,mmo,malu,mrn,clock,resetn,
	wwreg,wm2reg,wmo,walu,wrn); // MEM/WB流水线寄存器
	//MEM/WB流水线寄存器模块，起承接MEM阶段和WB阶段的流水任务。
	//在clock上升沿时，将MEM阶段需传递给WB阶段的信息，锁存在MEM/WB
	//流水线寄存器中，并呈现在WB阶段。
	
	input clock,resetn;
	input mwreg,mm2reg;
	input [4:0] mrn;
	input [31:0] malu,mmo;
	output wwreg,wm2reg;
	output [4:0] wrn;
	output [31:0] walu,wmo;
	
	dff1  savewwreg(mwreg,clock,resetn,wwreg);
	dff1  savewm2reg(mm2reg,clock,resetn,wm2reg);
	dff5  savewrn(mrn,clock,resetn,wrn);
	dff32 savewalu(malu,clock,resetn,walu);
	dff32 savewmo(mmo,clock,resetn,wmo);
endmodule