module pipeid ( mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
	wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
	bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
	daluimm,da,db,dimm,drn,dshift,djal ); // ID stage
	//ID指令译码模块。注意其中包含控制器CU、寄存器堆、及多个多路器等。
	//其中的寄存器堆，会在系统clock的下沿进行寄存器写入
	//给信号从WB阶段传输过来留有半个clock的延迟时间，亦即确保信号稳定。
	//该阶段CU产生的、要传播到流水线后级的信号较多。
	
	//wire [31:0] wdi;
	//模块间互联传递数据或控制信息的信号线,均为32位宽信号。WB回写寄存器阶段。
	//output [31:0] pc,inst,ealu,malu,walu;
	//模块用于仿真输出的观察信号。缺省为wire型。
	//wire [31:0] mmo;
	//模块间互联传递数据或控制信息的信号线,均为32位宽信号。MEM访问数据阶段。
	//wire [4:0] ern,mrn,wrn;
	//模块间互联，通过流水线寄存器传递结果寄存器号的信号线，寄存器号（32个）为5bit。
	input clock,resetn;
	input [31:0] dpc4,inst,wdi,ealu,malu,mmo;
	input [4:0] ern,mrn,wrn;
	input mwreg,ewreg,em2reg,mm2reg,wwreg;
	//可能产生暂停的地方
	//em2reg
	
	output [31:0] bpc,jpc,da,db,dimm;
	output [4:0] drn;
	output [3:0] daluc;
	output [1:0] pcsource;
	output wpcir,dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	
	wire [31:0]  sa = { 27'b0, inst[10:6] }; // extend to 32 bits from sa for shift instruction
	
	wire rsrtequ; //条件变量，即da,db是不是相等
	
	wire regrt,sext;
	wire [31:0] jpc = {dpc4[31:28],inst[25:0],1'b0,1'b0}; // j address
	pipe_cu cu(inst[31:26],inst[5:0],rsrtequ,dwmem,dwreg,regrt,dm2reg,
                        daluc,dshift,daluimm,pcsource,djal,sext);
	wire          e = sext & inst[15];          // positive or negative sign at sext signal
	wire [15:0]   imme = {16{e}};                // high 16 sign bit
	wire [31:0] imm = {imme,inst[15:0]}; // sign extend to high 16
	mux2x32 select_dimm(imm,sa,dshift,dimm);
	mux2x5 reg_wn (inst[15:11],inst[20:16],regrt,drn);//确定写回寄存器的地址
	
	wire [31:0] offset = {imm[13:0],inst[15:0],1'b0,1'b0};
	assign bpc = dpc4 + offset;
	
	//qa,qb是读出来的值，wn是写的地址，we是要不要写，d是要写的值
	wire [31:0] qa,qb;
	regfile rf(inst[25:21],inst[20:16],wdi,wrn,wwreg,clock,resetn,qa,qb);
	
	//da,db的选择
	wire [1:0] da_source,db_source;
	assign da_source[0]=(ewreg&(ern==inst[25:21]))|(mm2reg&(mrn==inst[25:21]));
	assign db_source[0]=(ewreg&(ern==inst[20:16]))|(mm2reg&(mrn==inst[20:16]));
	assign da_source[1]=(mwreg&(mrn==inst[25:21]))|(mm2reg&(mrn==inst[25:21]));
	assign db_source[1]=(mwreg&(mrn==inst[20:16]))|(mm2reg&(mrn==inst[20:16]));
	mux4x32 select_da(qa,ealu,malu,mmo,da_source,da);
	mux4x32 select_db(qb,ealu,malu,mmo,db_source,db);
	
	assign rsrtequ=(qa==qb);
	
	//em2reg暂停一个周期
	assign wpcir=em2reg;
endmodule