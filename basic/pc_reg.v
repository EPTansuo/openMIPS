//创建时间: 2023年 02月 01日 星期三 
//作用: 给出指令的地址


`include "defines.v"

module pc_reg(
	input	wire	clk,	//时钟信号
	input	wire	rst,	//复位信号

	output	reg[`InstAddrBus]	pc,	//要读取的指令地址
	output	reg	ce	//指令存储器使能信号
);

always@(posedge clk) begin
	if(rst == `RstEnable) begin
		ce <= `ChipDisable;	//复位时禁用指令存储器
	end
	else begin
		ce <= `ChipEnable;	//否则使用指令存储器
	end
end

always@(posedge clk) begin
	if(ce == `ChipDisable) begin
		pc <= `ZeroWord;		//禁用指令存储器时, 让要读取的地址为0
	end
	else begin
		pc <= pc + 4'h4;	//使能指令存储器时, 要读取的指令地址自增4
	end
end


endmodule
