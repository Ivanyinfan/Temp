module pipeif ( pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock );
	input [1:0] pcsource;
	input [31:0] pc,bpc,rpc,jpc;
	input rom_clk;
	output [31:0] npc,pc4,ins;
	mux4x32 newpc(pc,bpc,rpc,bpc,pcsource,npc);
	assign pc4=pc+32'h4;
	wire imem_clk;
	pl_instmem imem(pc,inst,mem_clock,imem_clk);
endmodule