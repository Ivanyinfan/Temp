module pipedereg ( dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,
	djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
	ea,eb,eimm,ern0,eshift,ejal,epc4,wpcir); // ID/EXE流水线寄存器
	//ID/EXE流水线寄存器模块，起承接ID阶段和EXE阶段的流水任务。
	//在clock上升沿时，将ID阶段需传递给EXE阶段的信息，锁存在ID/EXE流水线
	//寄存器中，并呈现在EXE阶段。
	
	input  clock,resetn,wpcir;
	input  dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	input  [3:0] daluc;
	input  [4:0] drn;
	input  [31:0] dpc4,da,db,dimm;
	output ewreg,em2reg,ewmem,ealuimm,eshift,ejal;
	output [3:0] ealuc;
	output [4:0] ern0;
	output [31:0] epc4,ea,eb,eimm;
	
	Bubble1  saveewreg(dwreg,clock,resetn,wpcir,ewreg);
	Bubble1  saveem2reg(dm2reg,clock,resetn,wpcir,em2reg);
	Bubble1  saveewmem(dwmem,clock,resetn,wpcir,ewmem);
	Bubble1  saveealuimm(daluimm,clock,resetn,wpcir,ealuimm);
	Bubble1  saveeshift(dshift,clock,resetn,wpcir,eshift);
	Bubble1  saveejal(djal,clock,resetn,wpcir,ejal);
	Bubble4  saveealuc(daluc,clock,resetn,wpcir,ealuc);
	Bubble5  saveern0(drn,clock,resetn,wpcir,ern0);
	Bubble32 saveepc4(dpc4,clock,resetn,wpcir,epc4);
	Bubble32 saveea(da,clock,resetn,wpcir,ea);
	Bubble32 saveeb(db,clock,resetn,wpcir,eb);
	Bubble32 saveimm(dimm,clock,resetn,wpcir,eimm);
endmodule