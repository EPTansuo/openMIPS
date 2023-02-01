

module id_ex(
	input wire	clk,
	input wire	rst,

	//从译码阶段传递过来的信息
	input wire[`AluOpBus]	id_aluop,
	input wire[`AluSelBus]	id_alusel,
	input wire[`RegBus]	id_reg1,
	input wire[`RegBus]	id_reg2,
	input wire[`RegAddrBus]	id_wd,
	input wire		id_wreg,

	//传递到执行阶段的信息
	output reg[`AluOpBus]	ex_aluop,
	output reg[`AluSelBus]	ex_alusel,
	output reg[`RegBus
);
