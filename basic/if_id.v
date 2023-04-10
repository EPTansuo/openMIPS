
//创建时间: 2023年 02月 01日 星期三 
//作用:暂时存放取指令阶段所取到的指令,以及对应的指令地址,并在下一个时钟
//传递到译码阶段

`timescale 1ns/1ps

`include "defines.v"

module if_id(
	input wire	clk,
	input wire	rst,

	input wire[`InstAddrBus]	if_pc,		//取指令取得的指令对应的地址
	input wire[`InstBus]		if_inst,	//取指令取得的指令

	output reg[`InstAddrBus]	id_pc,		//译码阶段的指令对应的地址
	output reg[`InstBus]		id_inst		//译码阶段的指令
);

always@(posedge clk) begin
	if(rst == `RstEnable) begin
		id_pc	<= `ZeroWord;
		id_inst <= `ZeroWord;
	end
	else begin
		id_pc	<= if_pc;
		id_inst <= if_inst;
	end
end

endmodule
