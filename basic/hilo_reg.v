
//创建时间：2023年 04月 08日 星期
//最后修改时间: 2023年 04月 08日 星期六
//作用:HI寄存器保存乘法高32位和除法的余数
//     LO寄存器保存乘法低32为和除法的商

`timescale 1ns/1ps

`include "defines.v"

module hilo_reg(
	input wire clk,
	input wire rst,

	//写端口
	input wire		we,	//使能信号
	input wire[`RegBus]	hi_i,	//写入HI寄存器的值
	input wire[`RegBus]	lo_i,	//写入LO寄存器的值

	//读端口
	output reg[`RegBus]	hi_o,	//HI寄存器的值
	output reg[`RegBus]	lo_o	//LO寄存器的值
);

	always@(posedge clk) begin
		if(rst == `RstEnable) begin
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end 
		else if (we == `WriteEnable) begin
			hi_o <= hi_i;
			lo_o <= lo_i;
		end
	end

endmodule
