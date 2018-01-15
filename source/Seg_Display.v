//�����ܼƷ�ģ��
module Seg_Display
(
	input CLK_50M,
	input RSTn,
	
	input add_cube,
	
	output reg[6:0]seg_out,
	output reg[3:0]sel
);
/***************************************************************************/
	reg[15:0]point;
	reg[31:0]clk_cnt;
	
	always@(posedge CLK_50M or negedge RSTn)
	begin
		if(!RSTn)
			begin
				seg_out<=0;
				clk_cnt<=0;
				sel<=0;
				
			end
		else
			begin
				if(clk_cnt<=20_0000)	
				begin
					clk_cnt<=clk_cnt+1;
					
					if(clk_cnt==5_0000)
						begin
							sel<=4'b1110;
							case(point[3:0])
								4'b0000:seg_out<=7'b100_0000;
								4'b0001:seg_out<=7'b111_1001;
								4'b0010:seg_out<=7'b010_0100;
								
								4'b0011:seg_out<=7'b011_0000;
								4'b0100:seg_out<=7'b001_1001;
								4'b0101:seg_out<=7'b001_0010;
								
								4'b0110:seg_out<=7'b000_0010;
								4'b0111:seg_out<=7'b111_1000;
								4'b1000:seg_out<=7'b000_0000;
								4'b1001:seg_out<=7'b001_0000;
								default;
							endcase
						
						end
					
					else if(clk_cnt==10_0000)
						begin
							sel<=4'b1101;
							
							case(point[7:4])
								4'b0000:seg_out<=7'b100_0000;
								4'b0001:seg_out<=7'b111_1001;
								4'b0010:seg_out<=7'b010_0100;
								
								4'b0011:seg_out<=7'b011_0000;
								4'b0100:seg_out<=7'b001_1001;
								4'b0101:seg_out<=7'b001_0010;
								
								4'b0110:seg_out<=7'b000_0010;
								4'b0111:seg_out<=7'b111_1000;
								4'b1000:seg_out<=7'b000_0000;
								4'b1001:seg_out<=7'b001_0000;
								default;							
							endcase
							
						end
					
					else if(clk_cnt==15_0000)
							begin
								sel<=4'b1011;
							case(point[11:8])
								4'b0000:seg_out<=7'b100_0000;
								4'b0001:seg_out<=7'b111_1001;
								4'b0010:seg_out<=7'b010_0100;
								
								4'b0011:seg_out<=7'b011_0000;
								4'b0100:seg_out<=7'b001_1001;
								4'b0101:seg_out<=7'b001_0010;
								
								4'b0110:seg_out<=7'b000_0010;
								4'b0111:seg_out<=7'b111_1000;
								4'b1000:seg_out<=7'b000_0000;
								4'b1001:seg_out<=7'b001_0000;
								default;					
							endcase
							end
					
					else if(clk_cnt==20_0000)
						begin
								case(point[15:12])
								4'b0000:seg_out<=7'b100_0000;
								4'b0001:seg_out<=7'b111_1001;
								4'b0010:seg_out<=7'b010_0100;
								
								4'b0011:seg_out<=7'b011_0000;
								4'b0100:seg_out<=7'b001_1001;
								4'b0101:seg_out<=7'b001_0010;
								
								4'b0110:seg_out<=7'b000_0010;
								4'b0111:seg_out<=7'b111_1000;
								4'b1000:seg_out<=7'b000_0000;
								4'b1001:seg_out<=7'b001_0000;
								default;					
							endcase
						end				
				end
				
				else
					clk_cnt<=0;
			
			end	
		
	
	end
	
	reg addcube_state;
	
	always@(posedge CLK_50M or negedge RSTn)
		begin
			if(!RSTn)
				begin
					point<=0;
					addcube_state<=0;
					
					
				end
			else begin
				case(addcube_state)
				
				0:
				begin
				
					if(add_cube)
						begin
							if(point[3:0]<9)
							point[3:0]<=point[3:0]+1;
							else
							begin
							point[3:0]<=0;
							if(point[7:4]<9)
								point[7:4]<=point[7:4]+1;
							else
							begin
								point[7:4]<=0;
								if(point[11:8]<9)
									point[11:8]<=point[11:8]+1;
								else 
								begin
									point[11:8]<=0;
									point[15:12]<=point[15:12]+1;
								end
							end
						end								//BCD��ת��
						
						addcube_state<=1;
					end
				end
				
				1:
				begin
						if(!add_cube)
								addcube_state<=0;
				end
				
				endcase
			
			end
										
	end						
							
	
	
/***************************************************************************/
/***************************************************************************/
	
	endmodule
	
	
	
	
	
	
	
	
/***************************************************************************/
/***************************************************************************/
	
	
	
	
	
	
	
	
	
	
/***************************************************************************/
/***************************************************************************/
	
	
	
	
	
	
	
	
	
	
/***************************************************************************/
/***************************************************************************/
	
	
	
	
	
	
	
	
	
	
/***************************************************************************/
/***************************************************************************/
	
	
	
	
	
	
	
	
	
	
/***************************************************************************/
