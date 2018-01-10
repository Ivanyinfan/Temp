//地址，写入的数据，输出的数据，是否写，时钟，内存时钟
module pl_datamem (addr,datain,dataout,we,clock,mem_clk,in_port0,in_port1,out_port0,out_port1,out_port2);
 
	input  [31:0]  addr;
	input  [31:0]  datain;
	
	input          we, clock,mem_clk;
	input [31:0] in_port0,in_port1;
	
	output [31:0]  dataout;
	output [31:0] out_port0,out_port1,out_port2;
	
	wire           dmem_clk;    
	wire           write_enable; 
	wire write_datamem_enable;
	wire write_io_output_reg_enable;
	wire [31:0] mem_dataout;
	wire [31:0] io_read_data;
	wire clrn=1;
	
	assign write_enable = we & mem_clk; 
	assign write_datamem_enable = write_enable & ( ~ addr[7]);
	assign write_io_output_reg_enable = write_enable & (addr[7]);
	
   //本实验中最终时钟信号与输入一致
   lpm_ram_dq_dram  dram(addr[6:2],mem_clk,datain,write_datamem_enable,mem_dataout);
   
   //addr[7]==1输出数据为I/O数据
   mux2x32 mem_io_dataout_mux(mem_dataout,io_read_data,addr[7],dataout);
   
   //地址，写入的数据，是否写I/O，内存时钟，重置，输出端1，输出端2
   io_output_reg io_output_regx2 (addr,datain,write_io_output_reg_enable,mem_clk,clrn,out_port0,out_port1,out_port2);

   //地址，内存时钟，I/O读出的值，输入端口1，输入端口2
   io_input_reg io_input_regx2(addr,mem_clk,io_read_data,in_port0,in_port1);
   
endmodule 