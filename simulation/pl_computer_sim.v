//=============================================
//
// 该 Verilog HDL 代码，是用于对设计模块进行仿真时，对输入信号的模拟输入值的设定。
// 否则，待仿真的对象模块，会因为缺少输入信号，而“不知所措”。
// 该文件可设定若干对目标设计功能进行各种情况下测试的输入用例，以判断自己的功能设计是否正确。
//
// 对于CPU设计来说，基本输入量只有：复位信号、时钟信号。
//
// 对于带I/O设计，则需要设定各输入信号值。
//
//
// =============================================


// `timescale 10ns/10ns            // 仿真时间单位/时间精度
`timescale 1ps/1ps            // 仿真时间单位/时间精度
//`timescale 1s/1s            // 仿真时间单位/时间精度

//
// （1）仿真时间单位/时间精度：数字必须为1、10、100
// （2）仿真时间单位：模块仿真时间和延时的基准单位
// （3）仿真时间精度：模块仿真时间和延时的精确程度，必须小于或等于仿真单位时间
//
// 

module pl_computer_sim;

	reg        resetn_sim;
    reg        clock_50M_sim;
	reg        mem_clock_sim;
	
	wire set0,set1,set2,set3;
	wire led0,led1,led2,led3,led4,led5,led6,led7,led8,led9;
	wire [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	pl_computer pl_computer_instance (resetn_sim,clock_50M_sim,mem_clock_sim,
										set0,set1,set2,set3,
										led0,led1,led2,led3,led4,led5,led6,led7,led8,led9,
										hex0,hex1,hex2,hex3,hex4,hex5);
					
	initial
        begin
            clock_50M_sim = 1;
            while (1)
                #2  clock_50M_sim = ~clock_50M_sim;
        end

	   
	initial
        begin
            mem_clock_sim = 0;
            while (1)
                #2  mem_clock_sim = ~ mem_clock_sim;
        end

	   	  
		  
		  
	initial
        begin
            resetn_sim = 0;
                #1 resetn_sim = 1;
        end
  
		  
    initial
        begin
		  
          $display($time,"resetn=%b clock_50M=%b  mem_clk =%b", resetn_sim, clock_50M_sim, mem_clock_sim);
			 
			//# 125000 $display($time,"out_port0 = %b  out_port1 = %b ", out_port0_sim,out_port1_sim );

        end

endmodule 

