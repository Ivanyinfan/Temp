module pipemwreg ( mwreg,mm2reg,mmo,malu,mrn,clock,resetn,
	wwreg,wm2reg,wmo,walu,wrn); // MEM/WB流水线寄存器
	//MEM/WB流水线寄存器模块，起承接MEM阶段和WB阶段的流水任务。
	//在clock上升沿时，将MEM阶段需传递给WB阶段的信息，锁存在MEM/WB
	//流水线寄存器中，并呈现在WB阶段。
	
	input clock.resetn;
	input mwreg,mm2reg;
	input [3:0] malu;
	input [4:0] mrn;
	input [31:0] mmo;
	output wwreg,wm2reg;
	output [3:0] walu;
	output [4:0] wrn;
	output [31:0] wmo;
	
	diff1  savewwreg(mwreg,clock,resetn,wwreg);
	diff1  savewm2reg(mm2reg,clock,resetn,wm2reg);
	diff4  savewalu(malu,clock,resetn,walu);
	diff5  savewrn(mrn,clock,resetn,wrn);
	diff32 savewmo(mmo,clock,resetn,wmo);
endmodule