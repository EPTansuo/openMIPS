`timescale 1ns/1ps

module inst_fetch_tb;

reg	CLOCK;		//时钟信号
reg	rst;		//复位信号
wire[31:0]	inst;	//表示取出的指令



initial begin 
	$dumpfile("wave.vcd");
	$dumpvars(0,inst_fetch_tb);
end

//生成时钟信号
//每10ns翻转, 生成50MHz的时钟
initial begin
	CLOCK = 1'b0;
	forever #10 CLOCK = !CLOCK;
end

//生成复位信号
initial begin
	rst = 1'b1;
	#195 rst = 1'b0;
	#1000 $stop;
end

//实例化模块
inst_fetch inst_fetch0(
	.clk(CLOCK),
	.rst(rst),
	.inst_o(inst)
);

endmodule
