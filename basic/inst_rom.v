
//创建时间: 2023年 02月 02日 星期四
//作用: 实现指令的存储与读出

`timescale 1ns/1ps

`include "defines.v"


module inst_rom(
	input wire			ce,	//使能信号
	input wire[`InstAddrBus]	addr,	//要读取的指令的地址
	
	output reg[`InstBus]		inst	//读出的指令
);

reg[`InstBus] inst_mem[0:`InstMemNum-1];

//使用文件inst_rom.data初始化指令存储器
initial $readmemh("inst_rom.data", inst_mem);


always@(*) begin
	if(ce == `ChipDisable) begin
		inst <= `ZeroWord;
	end
	else begin
		inst <= inst_mem[addr[`InstMemNumLog2+1:2]]; //??不解
	end
end




endmodule
