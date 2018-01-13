module dffe32 (d,clk,clrn,e,q);
   input  [31:0] d;
   input  clk,clrn,e;
   output [31:0] q;
   reg    [31:0] q;
   always @ (negedge clrn or posedge clk)
      if (clrn==0) begin
        q <= 0;
      end else if(e==0) begin
        q <= d;
      end
endmodule

module DffER32 (d,clk,clrn,enable,reset,q);
	input  [31:0] d;
   input  clk,clrn,enable,reset;
   output [31:0] q;
   reg    [31:0] q;
   always @ (negedge clrn or posedge clk)
		if (clrn==0)begin
			q <= 0;
      end else if (reset==1) begin
			q<=0;
		end else if(enable==1) begin
			q <= d;
      end
endmodule