
//创建时间: 2023年 02月 02日 星期四
//最后修改时间: 2023年 04月 08日 星期六.
//作用: 将执行阶段去得的运算结果, 在下一个时钟周期传递到访存阶段
//

`timescale 1ns/1ps

`include "defines.v"

module ex_mem(
	input wire	clk,
	input wire	rst,

	//来自执行阶段的信息
	input wire[`RegAddrBus]	ex_wd,
	input wire		ex_wreg,
	input wire[`RegBus]	ex_wdata,
	input wire[`RegBus]	ex_hi,
	input wire[`RegBus]	ex_lo,
	input wire		ex_whilo,

	//送到访存阶段的信息
	output reg[`RegAddrBus]	mem_wd,
	output reg		mem_wreg,
	output reg[`RegBus]	mem_wdata,
	output reg[`RegBus]	mem_hi,
	output reg[`RegBus]	mem_lo,
	output reg		mem_whilo

	
);

always@(posedge clk) begin
	if(rst == `RstEnable) begin
		mem_wd <= `NOPRegAddr;
		mem_wreg <= `WriteDisable;
		mem_wdata <= `ZeroWord;
		mem_hi <= `ZeroWord;
		mem_lo <= `ZeroWord;
		mem_whilo <= `WriteDisable;
	end
	else begin
		mem_wd <= ex_wd; 
                mem_wreg <= ex_wreg;
                mem_wdata <= ex_wdata;
		mem_hi <= ex_hi;
		mem_lo <= ex_lo;
		mem_whilo <= ex_whilo;
	end
end

endmodule
