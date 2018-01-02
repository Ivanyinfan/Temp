module pipedereg ( dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,
	djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
	ea,eb,eimm,ern0,eshift,ejal,epc4 ); // ID/EXE流水线寄存器
	//ID/EXE流水线寄存器模块，起承接ID阶段和EXE阶段的流水任务。
	//在clock上升沿时，将ID阶段需传递给EXE阶段的信息，锁存在ID/EXE流水线
	//寄存器中，并呈现在EXE阶段。
	
	input  clock,resetn;
	input  dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	input  [3:0] daluc;
	input  [4:0] drn;
	input  [31:0] dpc4,da,db,dimm;
	output ewreg,em2reg,ewmem,ealuimm,eshift,ejal;
	output [3:0] ealuc;
	output [4:0] ern0;
	output [31:0] epc4,ea,eb,eimm;
	
	dff1  saveewreg(dwreg,clock,resetn,ewreg);
	dff1  saveem2reg(dm2reg,clock,resetn,em2reg);
	dff1  saveewmem(dwmem,clock,resetn,ewmem);
	dff1  saveealuimm(daluimm,clock,resetn,ealuimm);
	dff1  saveeshift(dshift,clock,resetn,eshift);
	dff1  saveejal(djal,clock,resetn,ejal);
	dff4  saveealuc(daluc,clock,resetn,ealuc);
	dff5  saveern0(drn,clock,resetn,ern0);
	dff32 saveepc4(dpc4,clock,resetn,epc4);
	dff32 saveea(da,clock,resetn,ea);
	dff32 saveeb(db,clock,resetn,eb);
	dff32 saveimm(dimm,clock,resetn,eimm);
endmodule