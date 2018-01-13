module SetLed(set,led);
	input set;
	output led;
	reg led;
	always@(negedge set)
	begin
		led=~led;
	end
endmodule

module GetLed(led0,led1,led2,led3,led4,data);
	input led0,led1,led2,led3,led4;
	output [31:0] data;
	reg [31:0] data;
	initial begin data<=0;end
	always@(*)
	begin
		data[0]<=led0;
		data[1]<=led1;
		data[2]<=led2;
		data[3]<=led3;
		data[4]<=led4;
	end
endmodule