
// 创建时间: 2023年 02月 02日 星期四
// 作用:实现openmips顶层模块, 建立各模块间的连接
//


`include "defines.v"

module openmips(
	input wire	clk,
	input wire	rst,

	input wire[`RegBus]	rom_data_i,
	

	output wire[`RegBus]	rom_addr_o,
	output wire		rom_ce_o
);


//连接IF/ID模块与译码阶段ID模块的变量
wire[`InstAddrBus]	pc;
wire[`InstAddrBus]	id_pc_i;
wire[`InstBus]		id_inst_i;

//连接译码阶段ID模块输出与ID/EX模块输入的变量
wire[`AluOpBus]		id_aluop_o;
wire[`AluSelBus]	id_alusel_o;
wire[`RegBus]		id_reg1_o;
wire[`RegBus]		id_reg2_o;
wire			id_wreg_o;
wire[`RegAddrBus]	id_wd_o;

//连接ID/EX输出与EX输入的变量
wire[`AluOpBus]		ex_aluop_i;
wire[`AluSelBus]	ex_alusel_i;
wire[`RegBus]		ex_reg1_i;
wire[`RegBus]		ex_reg2_i;
wire			ex_wreg_i;
wire[`RegAddrBus]	ex_wd_i;

//连接EX输出与EX/MEM输入的变量
wire[`RegAddrBus]	ex_wd_o;
wire[`RegBus]		ex_wdata_o;
wire			ex_wreg_o;
wire[`RegBus]		ex_hi_o;
wire[`RegBus]		ex_lo_o;
wire			ex_whilo_o;



//连接EX/MEM输出与MEM输入的变量
wire[`RegBus]		mem_wdata_i;
wire[`RegAddrBus]	mem_wd_i;
wire			mem_wreg_i;
wire[`RegBus]		mem_hi_i;
wire[`RegBus]		mem_lo_i;
wire			mem_whilo_i;

//连接MEM输出与MEM/WB输入的变量
wire			mem_wreg_o;
wire[`RegAddrBus]	mem_wd_o;
wire[`RegBus]		mem_wdata_o;
wire[`RegBus]		mem_hi_o;   //也要去连接EX
wire[`RegBus]		mem_lo_o;   //也要去连接EX
wire			mem_whilo_o;//也要去连接EX

//连接MEM/WB输出与回写阶段输入的变量
wire			wb_wreg_i;
wire[`RegAddrBus]	wb_wd_i;
wire[`RegBus]		wb_wdata_i;
wire[`RegBus]		wb_hi;
wire[`RegBus]		wb_lo;
wire			wb_whilo;

//连接HILO和EX阶段的变量
wire[`RegBus]		hilo_hi_o;
wire[`RegBus]		hilo_lo_o;

//连接译码阶段ID模块与Regfile模块的变量
wire			reg1_read;
wire			reg2_read;
wire[`RegBus]		reg1_data;
wire[`RegBus]		reg2_data;
wire[`RegAddrBus]	reg1_addr;
wire[`RegAddrBus]	reg2_addr;


//pc_reg实例化
pc_reg pc_reg0(
	.clk(clk),
	.rst(rst),
	.pc(pc),
	.ce(rom_ce_o)
);

assign rom_addr_o = pc; //指令存储器的输入地址就是pc的值

//IF/ID模块实例化
if_id id_id0(
	.clk(clk),
	.rst(rst),
	.if_pc(pc),
	.if_inst(rom_data_i),
	.id_pc(id_pc_i),
	.id_inst(id_inst_i)
);

// ID模块实例化
id id0(
	.rst(rst),
	.pc_i(id_pc_i),
	.inst_i(id_inst_i),

	//来自regfile的输入
	.reg1_data_i(reg1_data),
	.reg2_data_i(reg2_data),
	
	//输出到regfile的信息
	.reg1_read_o(reg1_read),
	.reg1_addr_o(reg1_addr),
	.reg2_read_o(reg1_read),
	.reg2_addr_o(reg2_addr),
	
	//输出到ID/EX的信息
	.aluop_o(id_aluop_o),
	.alusel_o(id_alusel_o),
	.reg1_o(id_reg1_o),
	.reg2_o(id_reg2_o),
	.wd_o(id_wd_o),
	.wreg_o(id_wreg_o)
);

//通用寄存器regfile实例化
regfile regfile1(
	.clk(clk),
	.rst(rst),

	// MEM/WB输出到regfile
	.we(wb_wreg_i),
	.waddr(wb_wd_i),
	.wdata(wb_wdata_i),

	// ID输出到regfile
	.re1(reg1_read),
	.rdata1(reg1_data),
	.re2(reg2_read),
	.raddr2(reg2_addr),
	
	// regfile输出到ID
	.raddr1(reg1_addr),
	.rdata2(reg2_data)
);


// ID/EX模块实例化
id_ex id_ex_0(
	.clk(clk),
	.rst(rst),

	// 从译码阶段ID模块传递的信息
	.id_aluop(id_aluop_o),
	.id_alusel(id_alusel_o),
	.id_reg1(id_reg1_o),
	.id_reg2(id_reg2_o),
	.id_wd(id_wd_o),
	.id_wreg(id_wreg_o),

	// 传递到执行阶段EX模块的信息
	.ex_aluop(ex_aluop_i),
	.ex_alusel(ex_alusel_i),
	.ex_reg1(ex_reg1_i),
	.ex_reg2(ex_reg2_i),
	.ex_wd(ex_wd_i),
	.ex_wreg(ex_wreg_i)	
);


// EX模块实例化
ex ex0(
	.rst(rst),

	//从ID/EX传递来的信息
	.aluop_i(ex_aluop_i),
	.alusel_i(ex_alusel_i),
	.reg1_i(ex_reg1_i),
	.reg2_i(ex_reg2_i),
	.wd_i(ex_wd_i),
	.wreg_i(ex_wreg_i),

	//从访存阶段传递来的信息
	.mem_whilo_i(mem_whilo_o),
	.mem_hi_i(mem_hi_o),
	.mem_lo_i(mem_lo_o),

	//从回写阶段传递来的信息
	.wb_whilo_i(wb_whilo),
	.wb_hi_i(wb_hi),
	.wb_lo_i(wb_lo),
	
	//从HILO阶段传递来的信息
	.hi_i(hilo_hi_o),
	.lo_i(hilo_lo_o),

	//输出到EX/MEM的信息
	.wd_o(ex_wd_o),
	.wreg_o(ex_wreg_o),
	.wdata_o(ex_wdata_o),
	.whilo_o(ex_whilo_o),
	.hi_o(ex_hi_o),
	.lo_o(ex_lo_o)
);

//实例化EX/MEM模块
ex_mem ex_mem0(
	.clk(clk),
	.rst(rst),

	//来自执行阶段EX模块的信息
	.ex_wd(ex_wd_o),
	.ex_wreg(ex_wreg_o),
	.ex_wdata(ex_wdata_o),
	.ex_whilo(ex_whilo_o),
	.ex_hi(ex_hi_o),
	.ex_lo(ex_lo_o),

	//传递到访存阶段MEM模块的信息
	.mem_wd(mem_wd_i),
	.mem_wdata(mem_wdata_i),
	.mem_wreg(mem_wreg_i),
	.mem_whilo(mem_whilo_i),
	.mem_hi(mem_hi_i),
	.mem_lo(mem_hi_i)
);


mem mem0(
	.rst(rst),
	
	// 来自EX/MEM模块的信息
	.wd_i(mem_wd_i),
	.wreg_i(mem_wreg_i),
	.wdata_i(mem_wdata_i),
	.whilo_i(mem_hi_i),
	.hi_i(mem_hi_i),
	.lo_i(mem_lo_i),

	//传递到MEM/WB模块的信息
	.wd_o(mem_wd_o),
	.wreg_o(mem_wreg_o),
	.wdata_o(mem_wdata_o),
	.whilo_o(mem_whilo_o),
	.hi_o(mem_hi_o),
	.lo_o(mem_lo_o)
);



// MEM/WB模块实例化
mem_wb mem_wb0(
	.clk(clk),
	.rst(rst),

	// 来自访存阶段MEM模块的信息
	.mem_wd(mem_wd_o),
	.mem_wreg(mem_wreg_o),
	.mem_wdata(mem_wdata_o),
	.mem_whilo(mem_whilo_o),
	.mem_hi(mem_hi_o),
	.mem_lo(mem_lo_0),

	//送到回写阶段的信息
	.wb_wd(wb_wd_i),
	.wb_wreg(wb_wreg_i),
	.wb_wdata(wb_wdata_i)
);

// HILO模块实例化
hilo_reg hilo_reg0(
	.clk(clk),
	.rst(rst),

	//来自MEM/WB的信息
	.we(wb_whilo),
	.hi_i(wb_hi),
	.lo_i(wb_lo),
	
	//输出到EX阶段的信息
	.hi_o(hilo_hi_o),
	.hi_o(hilo_lo_o)

);


endmodule
