module dff1 (d,clk,clrn,q);
   input  d;
   input  clk,clrn;
   output q;
   reg    q;
   always @ (negedge clrn or posedge clk)
      if (clrn == 0) begin
          q <=0;
      end else begin
          q <= d;
      end
endmodule