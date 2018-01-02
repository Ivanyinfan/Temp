module pipeid id_stage ( mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
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
	input [31:0] dpc4,inst,wdi,ealu,malu,mmo;
	input [4:0] ern,mrn,wrn;
	input mwreg,ewreg,em2reg,mm2reg,wwreg;
	
	output [31:0] bpc,jpc,da,db,dimm;
	output [4:0] drn;//与regrt有关，暂时不知
	output [3:0] daluc;
	output [1:0] pcsource;
	output wpcir,dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	
	wire zero,regrt,aluc,sext;
	//zero 条件变量，暂时不知，未处理
	//regrt是不是写rt，暂时未用到
	//暂时不用条件判断
	wire [31:0] jpc = {p4[31:28],inst[25:0],1'b0,1'b0}; // j address
	pipe_cu cu(inst[31:26],inst[5:0],zero,dwmem,dwreg,regrt,dm2reg,
                        daluc,dshift,daluimm,pcsource,djal,sext);
	wire          e = sext & inst[15];          // positive or negative sign at sext signal
	wire [15:0]   imm = {16{e}};                // high 16 sign bit
	assign dimm = {imm,inst[15:0]}; // sign extend to high 16
	
	//wn!=0&&we==1时是写操作
	wire wn,we,qa,qb;
	regfile rf(inst[25:21],inst[20:16],d,wn,we,clock,resetn,qa,qb);
	
	//暂时da,db=qa,qb
	//wire [1:0] da_source,db_source
	mux4x32 select_da(qa,32'b0,32'b0,32'b0,4'b0,da);
	mux4x32 select_db(qb,32'b0,32'b02,32'b0,4'b0,db);
	