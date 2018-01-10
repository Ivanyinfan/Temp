`timescale 1s/1s
module ResetClock(clk,reset,clk1,clk2);
	input clk;
	output clk1,clk2,reset;
	reg clk1,clk2,reset;
	reg [31:0] times;
	initial
	begin 
		clk1<=0;
		clk2<=1;
		times<=0;
		reset<=0;
		#0.5 reset<=1;
	end
	always@(posedge clk)
	begin
		times<=times+1;
		if(times==50000000/2)
		begin
			clk1<=~clk1;
			clk2<=~clk2;
			times<=0;
		end
	end
endmodule
	