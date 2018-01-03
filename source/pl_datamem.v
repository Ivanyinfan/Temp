module pl_datamem (addr,datain,dataout,we,clock,mem_clk,dmem_clk);
 
   input  [31:0]  addr;
   input  [31:0]  datain;
   
   input          we, clock,mem_clk;
   output [31:0]  dataout;
   output         dmem_clk;
   
   wire           dmem_clk;    
   wire           write_enable; 
   assign         write_enable = we & ~clock; 
   
   //本实验中最终时钟信号与输入一致
   assign         dmem_clk = mem_clk; 
   
   lpm_ram_dq_dram  dram(addr[6:2],dmem_clk,datain,write_enable,dataout );

endmodule 