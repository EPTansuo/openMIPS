
//创建时间: 2023年 02月 02日 星期四 
//作用: 将执行阶段的数据传递到访存阶段
//

`include "defines.v"

module mem(
	input wire	rst,

	//来自执行阶段的信息
	input wire[`RegAddrBus]	wd_i,
	input wire		wreg_i,
	input wire[`RegBus]	wdata_i,

	//访存阶段的结果
	output reg[`RegAddrBus]	wd_o,
	output reg		wreg_o,
	output reg[`RegBus]	wdata_o
);

always@(*) begin
	if(rst == `RstEnable) begin
		wd_o <= `NOPRegAddr;
		wreg_o <= `WriteDisable;
		wdata_o <= `ZeroWord;
	end
	else begin
		wd_o <= wd_i;
		wreg_o <= wreg_o;
		wdata_o <= wdata_i;
	end
end

endmodule
