
//创建时间: 2023年 02月 02日 星期四
//作用: 测试openmips_min_sopc
//

`timescale 1ns/1ps

`include "defines.v"


module openmips_min_sopc_tb();

reg CLOCK_50;
reg rst;


//生成50Mhz时钟信号
initial begin
	CLOCK_50 = 1'b0;
	forever #10 CLOCK_50 = ~ CLOCK_50;
end

//生成复位信号和设置仿真时长
initial begin
	rst = `RstEnable;
	#195 rst = `RstDisable;
	#1000 $stop;
end

//生成仿真波形文件
initial begin
	$dumpfile("sim.vcd");
	$dumpvars(0,openmips_min_sopc_tb);
end

//实例化最小SOPC
openmips_min_sopc openmips_min_sopc0(
	.clk(CLOCK_50),
	.rst(rst)
);



endmodule
