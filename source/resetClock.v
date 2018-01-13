`timescale 1s/1s
module ResetClock(clk,clk1,clk2,reset,clrn);
	input clk;
	output clk1,clk2,reset,clrn;
	reg clk1,clk2,reset;
	reg [31:0] times;
	assign clrn=1;
	initial
	begin 
		clk1<=0;
		clk2<=0;
		times<=0;
		reset<=0;
		#0.5 reset<=1;
	end
	always@(posedge clk)
	begin
		times=times+1;
		if(times==50000000/4)
		begin clk2=~clk2;end
		if(times==50000000/2)
		begin
			clk1<=~clk1;
			times<=0;
		end
	end
endmodule
	