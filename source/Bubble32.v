module Bubble32 (d,clk,clrn,e,q);
   input  [31:0] d;
   input  clk,clrn,e;
   output [31:0] q;
   reg    [31:0] q;
   always @ (negedge clrn or posedge clk)
      if (clrn==0|e==1) begin
        q <= 0;
      end else begin
        q <= d;
      end
endmodule