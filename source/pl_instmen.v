module pl_instmem (addr,inst,mem_clk,imem_clk);
   input  [31:0] addr;
   input         mem_clk;
   output [31:0] inst;
   output        imem_clk;
   
   wire          imem_clk;

   assign  imem_clk=mem_clk;      
   
   lpm_rom_irom irom (addr[7:2],imem_clk,inst); 
   

endmodule 