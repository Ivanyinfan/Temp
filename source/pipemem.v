module pipemem ( mwmem,malu,mb,clock,mem_clock,mmo,in_port0,in_port1,out_port0,out_port1,out_port2); // MEM stage
//MEM数据存取模块。其中包含对数据同步RAM的读写访问。// 注意mem_clock。
//输入给该同步RAM的mem_clock信号，模块内定义为ram_clk。
//实验中可采用系统clock的反相信号作为mem_clock信号（亦即ram_clk）,
//即留给信号半个节拍的传输时间，然后在mem_clock上沿时，读输出、或写输入
	
	input clock,mem_clock,mwmem;
	input [31:0] malu;
	input [31:0] mb;
	input [31:0] in_port0,in_port1;
	output [31:0] mmo;
	output [31:0] out_port0,out_port1,out_port2;
	
	//地址，写入的值，读出的值，是否写，时钟，内存时钟
	pl_datamem  dmem(malu,mb,mmo,mwmem,clock,mem_clock,in_port0,in_port1,out_port0,out_port1,out_port2);
endmodule