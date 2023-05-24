//创建时间: 2023年 02月 02日 星期四 
//最后修改时间: 2023年 02月 05日 星期日
//最后修改时间: 2023年 04月 08日 星期六
//最后修改时间: 2023年 04月 10日 星期一
//作用: 依据数据进行运算
//

`timescale 1ns/1ps

`include "defines.v"

module ex(
	input wire	rst,

	// 译码阶段送到执行阶段的信息
	input wire[`AluOpBus]	aluop_i,
	input wire[`AluSelBus]	alusel_i,
	input wire[`RegBus]	reg1_i,
	input wire[`RegBus]	reg2_i,
	input wire[`RegAddrBus]	wd_i,
	input wire		wreg_i,

	//执行的结果
	output reg[`RegAddrBus]	wd_o,
	output reg		wreg_o,
	output reg[`RegBus]	wdata_o,


	//HILO模块给出的HI,LO寄存器的值
	input wire[`RegBus]	hi_i,
	input wire[`RegBus]	lo_i,

	//回写阶段的指令是否要写入HI,LO
	input wire[`RegBus]	wb_hi_i,
	input wire[`RegBus]	wb_lo_i,
	input wire		wb_whilo_i,

	//访存阶段的指令是否要写入HI,LO
	input wire[`RegBus]	mem_hi_i,
	input wire[`RegBus]	mem_lo_i,
	input wire		mem_whilo_i,

	//处于执行阶段的指令对HI,LO寄存器的写操作请求
	output reg[`RegBus]	hi_o,
	output reg[`RegBus]	lo_o,
	output reg		whilo_o 

);


reg[`RegBus] logicout;//保存逻辑运算的结果
reg[`RegBus] shiftres;//保存移位运算的结果
reg[`RegBus] moveres;//保存转移运算的结果
reg[`RegBus] arithmeticres;//保存算术运算的结果
reg[`RegBus] HI;//保存HI寄存器的最新值
reg[`RegBus] LO;//保存LO寄存器的最新值

wire ov_sum;   		//保存溢出情况
wire reg1_eq_reg2;	//第一个操作数等于第二个操作数
wire reg1_lt_reg2;	//第一个操作数大于第二个操作数
wire[`RegBus] reg2_i_mux; //保存输入的第二个操作数reg2_i的补码
wire[`RegBus] reg1_i_not; //保存输入的第一个操作数reg1_i取反后的值
wire[`RegBus] result_sum; //保存加法结果
wire[`RegBus] opdata1_mult; //乘法中的乘数1
wire[`RegBus] opdata2_mult; //乘法中的乘数2
wire[`DoubleRegBus] hilo_temp; //临时保存乘法结果,64位宽度
reg[`DoubleRegBus] mulres;    //保存乘法结果,64位宽度



//如果有减法或者符号比较运算,则reg2_i_mux取补码
//有符号比较运算使用了减法来比较大小
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) ||
		 	(aluop_i == `EXE_SUBU_OP) ||
			(aluop_i == `EXE_SLT_OP)) ?
			(~reg2_i)+1 : reg2_i;
//加法,直接相加,
//减法,第二个数取补码
//有符号比较,第一个数减去第二个数,判断是否小于0
assign result_sum = reg1_i + reg2_i_mux;


//判断是否溢出(加法指令和减法指令):
//正数+正数=负数->溢出
//复数+复数=正数->溢出
assign ov_sum = (!reg1_i[31] && !reg2_i_mux[31] && result_sum[31]) ||
		(reg1_i[31] && reg2_i_mux[31] && !result_sum[31]);

//判断操作数1 是否小于操作数2
//aluop_i等于EXE_SLT_OP, 有符号比较
//	数1为负数,数2为正数,显然数1<数2;
//	数1和数2为同为正数负复数,则作差判断是否小于零
//无符号比较时,直接使用比较运算符
assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP)?
			((reg1_i[31] && !reg2_i[31]) ||
			(!reg1_i[31] && !reg2_i[31] && result_sum[31]) ||
			(reg1_i[31] && reg2_i[31] && result_sum[31]))
			:(reg1_i<reg2_i);

//取反
assign reg1_i_not = ~reg1_i;




//*********得到最新的HI,LO寄存器的数据,此处要解决数据相关的问题***************
always@(*) begin
	if(rst == `RstEnable) begin
		{HI,LO} <= {`ZeroWord,`ZeroWord};
	end
	else if(mem_whilo_i == `WriteEnable) begin
		{HI,LO} <= {mem_hi_i,mem_lo_i};
	end
	else if(wb_whilo_i == `WriteEnable) begin
		{HI,LO} <= {wb_hi_i,wb_lo_i};
	end
	else begin
		{HI,LO} <= {hi_i,lo_i};
	end
end


//*****************************完成逻辑运算****************************
always@(*) begin
	if(rst == `RstEnable) begin
		logicout <= `ZeroWord;
	end
	else begin
		case(aluop_i)
			`EXE_OR_OP: begin		//判断为或运算
				logicout <= reg1_i | reg2_i;
			end 
			`EXE_AND_OP: begin		//and
				logicout <= reg1_i & reg2_i;
			end 
			`EXE_NOR_OP: begin		//nor
				logicout <= ~(reg1_i | reg2_i);
			end 
			`EXE_XOR_OP: begin		//xor
				logicout <= reg1_i ^ reg2_i;
			end 
			default: begin
				logicout <= `ZeroWord;
			end
		endcase
	end
end

//**********************完成移位运算*********************************
always@(*) begin
	if(rst == `RstEnable) begin
		shiftres = `ZeroWord;
	end
	else begin
		case(aluop_i)
			`EXE_SLL_OP: begin		//sll
				shiftres <= reg2_i << reg1_i[4:0];
			end 
			`EXE_SRL_OP: begin		//srl
				shiftres <= reg2_i >> reg1_i[4:0];
			end 
			`EXE_SRA_OP: begin		//sra
				shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]}))
					| (reg2_i >> reg1_i[4:0]);
			end
			default: begin
				shiftres <= `ZeroWord;
			end
		endcase

	end

end

//******************* MFHI MFLO MOVN MOVZ指令实现***********************
always@(*) begin
	if(rst == `RstEnable) begin
		moveres <= `ZeroWord;
	end
	else begin 
		moveres <= `ZeroWord;
		case(aluop_i)
			`EXE_MFHI_OP: begin
				moveres <= HI;
			end
			`EXE_MFLO_OP: begin
				moveres <= LO;
			end
		    	`EXE_MOVZ_OP: begin
				moveres <= reg1_i;
			end
			`EXE_MOVN_OP: begin
				moveres <= reg1_i;
			end
			default: begin
			end
		endcase
	end
end


//***********************实现算术运算****************************

always@(*) begin
	if(rst == `RstEnable) begin
		arithmeticres <= `ZeroWord;
	end 
	else begin
		case(aluop_i)
			`EXE_SLT_OP, `EXE_SLTU_OP: begin 
				arithmeticres <= reg1_lt_reg2; //比较运算
			end
			`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
				arithmeticres <= result_sum;	//加法运算
			end
			`EXE_SUB_OP, `EXE_SUBU_OP: begin
				arithmeticres <= result_sum;	//减法运算
			end
			`EXE_CLZ_OP: begin
				arithmeticres <= 
					reg1_i[31] ? 0 : reg1_i[30] ? 1 :
					reg1_i[29] ? 2 : reg1_i[28] ? 3 :
					reg1_i[27] ? 4 : reg1_i[26] ? 5 :
					reg1_i[25] ? 6 : reg1_i[24] ? 7 :
					reg1_i[23] ? 8 : reg1_i[22] ? 9 :
					reg1_i[21] ? 10 : reg1_i[20] ? 11 :
					reg1_i[19] ? 12 : reg1_i[18] ? 13 :
					reg1_i[17] ? 14 : reg1_i[16] ? 15 :
					reg1_i[15] ? 16 : reg1_i[14] ? 17 :
					reg1_i[13] ? 18 : reg1_i[12] ? 19 :
					reg1_i[11] ? 20 : reg1_i[10] ? 21 :
					reg1_i[9] ? 22 : reg1_i[8] ? 23 :
					reg1_i[7] ? 24 : reg1_i[6] ? 25 :
					reg1_i[5] ? 26 : reg1_i[4] ? 27 :
					reg1_i[3] ? 28 : reg1_i[2] ? 29 :
					reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32;
			end
			`EXE_CLO_OP: begin
				arithmeticres <= 
					reg1_i_not[31] ? 0 :reg1_i_not[30] ? 1 :
					reg1_i_not[29] ? 2 :reg1_i_not[28] ? 3 :
					reg1_i_not[27] ? 4 :reg1_i_not[26] ? 5 :
					reg1_i_not[25] ? 6 :reg1_i_not[24] ? 7 :
					reg1_i_not[23] ? 8 :reg1_i_not[22] ? 9 :
					reg1_i_not[21] ? 10 :reg1_i_not[20] ? 11 :
					reg1_i_not[19] ? 12 :reg1_i_not[18] ? 13 :
					reg1_i_not[17] ? 14 :reg1_i_not[16] ? 15 :
					reg1_i_not[15] ? 16 :reg1_i_not[14] ? 17 :
					reg1_i_not[13] ? 18 :reg1_i_not[12] ? 19 :
					reg1_i_not[11] ? 20 :reg1_i_not[10] ? 21 :
					reg1_i_not[9] ? 22 :reg1_i_not[8] ? 23 :
					reg1_i_not[7] ? 24 :reg1_i_not[6] ? 25 :
					reg1_i_not[5] ? 26 :reg1_i_not[4] ? 27 :
					reg1_i_not[3] ? 28 :reg1_i_not[2] ? 29 :
					reg1_i_not[1] ? 30 :reg1_i_not[0] ? 31 : 32;
			end
			default: begin
				 arithmeticres <= `ZeroWord;
				 
			end	
		endcase // case aluop_o
	end
end

				
//******************************进行乘法运算*****************************
//
//获得乘法运算的乘数, 如果是有符号乘法,且乘数是负数,则取补码
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
			&& (reg1_i[31]==1'b1)) ? (~reg1_i + 1) : reg1_i;
assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
			&& (reg2_i[31]==1'b1)) ? (~reg2_i + 1) : reg2_i;
//得到临时的乘法运算结果
assign hilo_temp = opdata1_mult * opdata2_mult;

always@(*) begin
	if(rst == `RstEnable) begin
		mulres <= {`ZeroWord,`ZeroWord};
	end 
	else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)) begin
		//对于有符号乘法, 若乘数一正一负,则需再次取补码
		if(reg1_i[31] ^ reg2_i[31]) begin
			mulres <= ~hilo_temp + 1;
		end
		else begin
			mulres <= hilo_temp;
		end
	end
	else begin
		mulres <= hilo_temp;
	end
end



//***********************根据运算类型,选择运算结果进行输出*****************
always@(*) begin
	wd_o <= wd_i;

	//如果add,addi,sub,subi指令,且发生溢出,设置wreg_o 为disable,不写入寄存
	//器.
	if((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP)||
	   (aluop_i == `EXE_SUB_OP) && (ov_sum == 1'b1)) begin
	   wreg_o <= `WriteDisable;
	end 
	else begin 
		wreg_o <= wreg_i;
	end
	case(alusel_i)
		`EXE_RES_LOGIC:	begin
			wdata_o <= logicout;
		end
		`EXE_RES_SHIFT: begin
			wdata_o <= shiftres;
		end
		`EXE_RES_MOVE: begin
			wdata_o <= moveres;
		end
		`EXE_RES_ARITHMETIC : begin
			wdata_o <= arithmeticres;
		end
		`EXE_RES_MUL: begin
			wdata_o <= mulres[31:0];
		end
		default: begin
			wdata_o <= `ZeroWord;
		end
	endcase
end




//**************确定对HI, LO寄存器的操作信息***************************
always@(*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end
	//如果是MTHI MTLO指令,则需要给出whilo_o,hi_o,lo_i
	else if(aluop_i == `EXE_MTHI_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= reg1_i;
		lo_o <= LO; //LO保持不变
	end
	else if(aluop_i == `EXE_MTLO_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= HI;
		lo_o <= reg1_i;
	end 
	else if((aluop_i == `EXE_MULT_OP)||
		(aluop_i == `EXE_MULTU_OP)) begin
		whilo_o <= `WriteEnable;
		hi_o <= mulres[63:32];
		lo_o <= mulres[31:0];
	end
	else begin 
		whilo_o <= `WriteEnable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end
end

endmodule
