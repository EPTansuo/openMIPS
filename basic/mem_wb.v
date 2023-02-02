
//创建时间: 2023年 02月 02日 星期四 
//作用: 将访存阶段的运算结果, 在下一个时钟传递到回写阶段
//
module mem_wb(
	input wire	clk,
	input wire	rst,

	//访存阶段的结果
	input wire[`RegAddrBus]	mem_wd,
	input wire		mem_wreg,
	input wire[`RegBus]	mem_wdata,

	//送到回写阶段的信息
	output reg[`RegAddrBus]	wb_wd,
	output reg		wb_wreg,
	output reg[`RegBus]	wb_wdata
);


always@(posedge clk) begin
	if(rst == `RstEnable) begin
		wb_wd <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wdata <= `ZeroWord;
	end
	else begin
		wb_wd <= mem_wd;
		wb_wreg <= mem_wreg;
		wv_Wdata <= mem_wdata;
	end
end


endmodule
