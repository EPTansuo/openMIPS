
//创建时间: 2023年 02月 02日 星期四
//作用: 从指令存储器读取指令, 指令进入OpenMips进行执行
//

`timescale 1ns/1ps

`include "defines.v"

module openmips_min_sopc(
	input wire	clk,
	input wire	rst
);

wire[`InstAddrBus]	inst_addr;
wire[`InstBus]		inst;
wire			rom_ce;


//实例化openMIPS
openmips openmips0(
	.clk(clk),
	.rst(rst),
	.rom_addr_o(inst_addr),
	.rom_data_i(inst),
	.rom_ce_o(rom_ce)
);

//实例化指令存储器ROM
inst_rom inst_rom_0(
	.ce(rom_ce),
	.addr(inst_addr),
	.inst(inst)
);


endmodule
