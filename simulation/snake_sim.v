`timescale 1ps/1ps

module snake_sim;
	reg clk,enable;
	reg left,right,up,down;
	wire hsync,vsync,clk_25M;
	wire [2:0]color_out;
	wire [7:0]seg_out;
	wire [3:0]sel;
	top_snake snake_instance(clk,enable,left,right,up,down,hsync,vsync,clk_25M,color_out,seg_out,sel);
	
	initial
	begin
		enable<=1;
		left<=1;
		right<=1;
		up<=1;
		down<=1;
		clk<=0;
		while(1)
			#5 clk<=~clk;
	end
endmodule