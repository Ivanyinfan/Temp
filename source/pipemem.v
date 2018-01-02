module pipemem ( mwmem,malu,mb,clock,mem_clock,mmo ); // MEM stage
//MEM数据存取模块。其中包含对数据同步RAM的读写访问。// 注意mem_clock。
//输入给该同步RAM的mem_clock信号，模块内定义为ram_clk。
//实验中可采用系统clock的反相信号作为mem_clock信号（亦即ram_clk）,
//即留给信号半个节拍的传输时间，然后在mem_clock上沿时，读输出、或写输入。
	//wire [31:0] mb,mmo;
	//模块间互联传递数据或控制信息的信号线,均为32位宽信号。MEM访问数据阶段。
	input clock,mwmem;
	input [3:0] malu;
	input [32:0] mb;
	output mem_clock;
	output [31:0] mmo;
	pl_datamem  dmem(malu,data,mmo,wmem,clock,mem_clk,dmem_clk )
endmodule