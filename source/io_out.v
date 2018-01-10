module io_out(in,out0,out1);
	input [31:0] in;
	output [6:0] out0,out1;
	reg [6:0] out0=7'b100_0000;
	reg [6:0] out1;
	always @ (*)
	begin
		case(in)
			0: out1 = 7'b100_0000;
			1: out1 = 7'b111_1001;
			2: out1 = 7'b010_0100;
			3: out1 = 7'b011_0000;
			4: out1 = 7'b001_1001;
			5: out1 = 7'b001_0010;
			6: out1 = 7'b000_0010;
			7: out1 = 7'b111_1000;
			8: out1 = 7'b000_0000;
			9: out1 = 7'b001_0000;
			default: out1 = 7'b111_1111;
		endcase
	end
endmodule