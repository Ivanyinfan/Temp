module Bubble1 (d,clk,clrn,e,q);
   input  d;
   input  clk,clrn,e;
   output q;
   reg    q;
   always @ (negedge clrn or posedge clk)
      if (clrn==0) begin
        q <= 0;
      end else if(e==1)begin
		  q <= 0;
		end else begin
        q <= d;
      end
endmodule

module Bubble4 (d,clk,clrn,e,q);
   input  [3:0] d;
   input  clk,clrn,e;
   output [3:0] q;
   reg    [3:0] q;
   always @ (negedge clrn or posedge clk)
      if (clrn==0) begin
        q <= 0;
      end else if(e==1)begin
		  q <= 0;
		end else begin
        q <= d;
      end
endmodule

module Bubble5 (d,clk,clrn,e,q);
	input  [4:0] d;
	input  clk,clrn,e;
	output [4:0] q;
	reg    [4:0] q;
	always @ (negedge clrn or posedge clk)
	if (clrn==0) begin
		q <= 0;
    end else if(e==1)begin
		q <= 0;
	end else begin
		q <= d;
    end
endmodule

module Bubble32 (d,clk,clrn,e,q);
   input  [31:0] d;
   input  clk,clrn,e;
   output [31:0] q;
   reg    [31:0] q;
   always @ (negedge clrn or posedge clk)
      if (clrn==0) begin
        q <= 0;
      end else if(e==1)begin
		  q <= 0;
		end else begin
        q <= d;
      end
endmodule