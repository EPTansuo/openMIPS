
//创建时间: 2023年 02月 01日 星期三 
//最后修改时间: 2023年 02月 05日 星期日 
//作用:实现了32个32为通用寄存器,可以同时进行两个寄存器的读操作和一个寄存器
//的写操作



`include "defines.v"

module regfile(
	input wire	clk,
	input wire	rst,

	//写端口
	input wire	we,		//使能信号
	input wire[`RegAddrBus]	waddr,	//要写入的寄存器地址
	input wire[`RegBus]	wdata,	//要写入的数据     

	//读端口1
	input wire	re1,		//使能信号
	input wire[`RegAddrBus]	raddr1, //要读取的寄存器地址
	output reg[`RegBus]	rdata1, //要读取的数据     

	//读端口2
	input wire	re2,		//使能信号
	input wire[`RegAddrBus]	raddr2, //要读取的寄存器地址
	output reg[`RegBus]	rdata2  //要读取的数据     
);

//定义32个32位寄存器
reg[`RegBus] regs[0:`RegNum-1];


//写操作
always@(posedge clk) begin
	if(rst == `RstDisable) begin
		if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
			regs[waddr] <= wdata;
		end
	end
end

//读操作
always@(*) begin
	if(rst == `RstEnable) begin
		rdata1 <= `ZeroWord;
	end 
	else if(rdata1 == `RegNumLog2'h0) begin
		rdata1 <= `ZeroWord;
	end
	else if((raddr1 == waddr) && (we == `WriteEnable) // 解决相隔两条指令数据相关的问题 
		&& (re1 == `ReadEnable)) begin
		rdata1 <= wdata;
	end else if(re1 == `ReadEnable) begin
		rdata1 <= regs[raddr1];
	end
	else begin
		rdata1 <= `ZeroWord;
	end
end

always@(*) begin
	if(rst == `RstEnable) begin
		rdata2 <= `ZeroWord;
	end 
	else if(rdata2 == `RegNumLog2'h0) begin
		rdata2 <= `ZeroWord;
	end
	else if((raddr2 == waddr) && (we == `WriteEnable) // 解决相隔两条指令数据相关的问题 
		&& (re2 == `ReadEnable)) begin
		rdata2 <= wdata;
	end else if(re2 == `ReadEnable) begin
		rdata2 <= regs[raddr2];
	end
	else begin
		rdata2 <= `ZeroWord;
	end
end

endmodule

