
//创建时间: 2023年 02月 01日 星期三
//最后修改时间: 2023年 02月 05日 星期日
//最后修改时间: 2023年 04月 08日 星期六
//作用:对指令进行译码


`include "defines.v"

module id(
	input wire	rst,			//复位信号
	input wire[`InstAddrBus]	pc_i,	//译码阶段的指令对应的地址
	input wire[`InstBus]	inst_i,		//译码阶段的指令
	
	//处于执行阶段大的指令的运算结果
	input wire		ex_wreg_i,	//处于执行阶段的指令是否要写入目的寄存器
	input wire[`RegBus]	ex_wdata_i,	//处于执行阶段的指令要写入目的寄存器的数据
	input wire[`RegAddrBus]	ex_wd_i,	//处于执行阶段的指令要写的目的寄存器的地址

	//处于访存阶段的指令的运算结果
	input wire		mem_wreg_i,	//处于访存阶段的指令是否要写入目的寄存器
	input wire[`RegBus]	mem_wdata_i,	//处于访存阶段的指令要写入目的寄存器的数据
	input wire[`RegAddrBus] mem_wd_i,	//处于访存阶段的指令要写入目的寄存器的地址

	//读取的Regfile的值
	input wire[`RegBus]	reg1_data_i,	//输入数据1
	input wire[`RegBus]	reg2_data_i,	//输入数据2

	//输出到Regfile的值
	output reg		reg1_read_o,	//Regfile的读使能信号
	output reg		reg2_read_o,	//Regfile的读使能信号
	output reg[`RegAddrBus]	reg1_addr_o,	//Regfile的读地址
	output reg[`RegAddrBus]	reg2_addr_o,	//Regfile的读地址 

	//送到执行阶段的信息
	output reg[`AluOpBus]	aluop_o,	//译码阶段的指令要进行运算的子类型
	output reg[`AluSelBus]	alusel_o,	//译码阶段的指令要进行运算的类型
	output reg[`RegBus]	reg1_o,		//进行运算的源操作数1
	output reg[`RegBus]	reg2_o,		//进行运算的源操作数2
	output reg[`RegAddrBus]	wd_o,		//译码阶段的指令要写入的目的寄存器地址
	output reg		wreg_o		//译码阶段的指令是否要写入目的寄存器


);


//取的指令的指令码,功能码
wire[5:0] op = inst_i[31:26]; //指令码
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];  //功能码
wire[4:0] op4 = inst_i[20:16];

//保存指令执行需要的立即数
reg[`RegBus] imm;

//标记指令是否有效
reg instvalid;


//********************************对指令进行译码******************************

always@(*)begin
	if(rst == `RstEnable) begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o <= `NOPRegAddr;
		wreg_o <= `WriteDisable;
		instvalid <= `InstValid;
		reg1_read_o <= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o <= `NOPRegAddr;
		reg2_addr_o <= `NOPRegAddr;
		imm <= `ZeroWord;
	end
	else begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o <= inst_i[15:11];
		wreg_o <= `WriteDisable;
		instvalid <= `InstInvalid;
		reg1_read_o <= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o <= inst_i[25:21];
		reg2_addr_o <= inst_i[20:16];
		imm <= `ZeroWord;
		
		case(op)
			`EXE_SPECIAL_INST: begin
				case(op2)
					5'b00000: begin
						case(op3)
							`EXE_OR: begin	//or
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_OR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end
							`EXE_AND: begin //and
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_AND_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end
							`EXE_XOR: begin //xor
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_XOR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end
							`EXE_XOR: begin //xor
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_XOR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end
							`EXE_NOR: begin //nor
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_NOR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end 
							`EXE_SLLV: begin //sllv
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SLL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end 
							`EXE_SRLV: begin //srlv
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end 
							`EXE_SRAV: begin //srav
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end 
							`EXE_SYNC: begin //sync
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_NOP_OP;  
								alusel_o <= `EXE_RES_NOP;
								reg1_read_o <= 1'b0;
								reg2_read_o <= 1'b1;
								instvalid = `InstValid;
							end 
							`EXE_MFHI: begin
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_MFHI_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= 1'b0;
								reg2_read_o <= 1'b0;
								instvalid <= `InstValid;
							end 
							`EXE_MFLO: begin
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_MFLO_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= 1'b0;
								reg2_read_o <= 1'b0;
								instvalid <= `InstValid;
							end 
							`EXE_MTHI: begin
								wreg_o <= `WriteDisable;
								aluop_o <= `EXE_MTHI_OP;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b0;
								instvalid <= `InstValid;
							end 
							`EXE_MTLO: begin
								wreg_o <= `WriteDisable;
								aluop_o <= `EXE_MTLO_OP;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b0;
								instvalid <= `InstValid;
							end 
							`EXE_MOVN: begin
								aluop_o <= `EXE_MOVN_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid <= `InstValid;
								if(reg2_o != `ZeroWord) begin
									wreg_o <= `WriteEnable;
								end
								else begin
									wreg_o <= `WriteDisable;
								end
							end 
							`EXE_MOVZ: begin
								aluop_o <= `EXE_MOVZ_OP;
								alusel_o <= `EXE_RES_MOVE;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
								instvalid <= `InstValid;
								if(reg2_o == `ZeroWord) begin
									wreg_o <= `WriteEnable;
								end
								else begin
									wreg_o <= `WriteDisable;
								end
							end

							default: begin
							end
						endcase //case op3
					end
				endcase //case op2
			end 
			`EXE_ORI: begin				//判断是否为ori指令
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_OR_OP;		//运算子类型为或
				alusel_o <= `EXE_RES_LOGIC;	//类算类型为逻辑运算
				reg1_read_o <= 1'b1;		//需要端口1的数据
				reg2_read_o <= 1'b0;		//不需要端口2的数据
				imm <= {16'h0, inst_i[15:0]};	//合并得到立即数
				wd_o <= inst_i[20:16];		//要写入目的寄存器的地址
				instvalid <= `InstValid;	//指令有效
			end 
			`EXE_ANDI: begin			//andi
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_AND_OP;		
				alusel_o <= `EXE_RES_LOGIC;	
				reg1_read_o <= 1'b1;		
				reg2_read_o <= 1'b0;		
				imm <= {16'h0, inst_i[15:0]};	
				wd_o <= inst_i[20:16];		
				instvalid <= `InstValid;	
			end 
			`EXE_XORI: begin			//xori
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_XOR_OP;		
				alusel_o <= `EXE_RES_LOGIC;	
				reg1_read_o <= 1'b1;		
				reg2_read_o <= 1'b0;		
				imm <= {16'h0, inst_i[15:0]};	
				wd_o <= inst_i[20:16];		
				instvalid <= `InstValid;	
			end 
			`EXE_LUI: begin				//lui 将立即数写入到寄存器
								//可以用OR指令来实现
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_OR_OP;		
				alusel_o <= `EXE_RES_LOGIC;	
				reg1_read_o <= 1'b1;		
				reg2_read_o <= 1'b0;		
				imm <= {inst_i[15:0],16'h0};
				wd_o <= inst_i[20:16];		
				instvalid <= `InstValid;	
			end 
			`EXE_PREF: begin			//pref openMIPS未用到
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_NOP_OP;		
				alusel_o <= `EXE_RES_NOP;
				reg1_read_o <= 1'b0;		
				reg2_read_o <= 1'b0;		
				instvalid <= `InstValid;	
			end

			default: begin
			end
		endcase //case op

		if(inst_i[31:21] == 11'b00000000000) begin
			case(op3)
				`EXE_SLL: begin		//sll
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_SLL_OP;		
					alusel_o <= `EXE_RES_SHIFT;	
					reg1_read_o <= 1'b0;		
					reg2_read_o <= 1'b1;		
					imm[4:0] <= inst_i[10:6];
					wd_o <= inst_i[15:11];		
					instvalid <= `InstValid;	
				end
				`EXE_SRL: begin		//srl
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_SRL_OP;		
					alusel_o <= `EXE_RES_SHIFT;	
					reg1_read_o <= 1'b0;		
					reg2_read_o <= 1'b1;		
					imm[4:0] <= inst_i[10:6];
					wd_o <= inst_i[15:11];		
					instvalid <= `InstValid;	
				end
				`EXE_SRA: begin		//sra
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_SRA_OP;		
					alusel_o <= `EXE_RES_SHIFT;	
					reg1_read_o <= 1'b0;		
					reg2_read_o <= 1'b1;		
					imm[4:0] <= inst_i[10:6];
					wd_o <= inst_i[15:11];		
					instvalid <= `InstValid;	
				end
			endcase // case op3
		end // if

	end
end


//*****************************确定进行运算的源操作数1***********************

always@(*)begin
	if(rst == `RstEnable) begin
		reg1_o <= `ZeroWord;
	end
	else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) //将执行阶段的数据作为reg1_o的输出
			&& (ex_wd_i == reg1_addr_o)) begin
		reg1_o <= ex_wdata_i;
	end 
	else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) //将访存阶段的数据作为reg1_o的输出
			&& (mem_wd_i == reg1_addr_o)) begin
		reg1_o <= mem_wdata_i;
	end
	else if(reg1_read_o == 1'b1) begin
		reg1_o <= reg1_data_i; 	//从Regfile读端口1的数据
	end
	else if(reg1_read_o == 1'b0) begin
		reg1_o <= imm;
	end
	else begin
		reg1_o <= `ZeroWord;
	end
end


//*****************************确定进行运算的源操作数2***********************

always@(*)begin
	if(rst == `RstEnable) begin
		reg2_o <= `ZeroWord;
	end
	else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) //将执行阶段的数据作为reg2_o的输出
			&& (ex_wd_i == reg2_addr_o)) begin
		reg2_o <= ex_wdata_i;
	end 
	else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) //将访存阶段的数据作为reg2_o的输出
			&& (mem_wd_i == reg2_addr_o)) begin
		reg2_o <= mem_wdata_i;
	end
	else if(reg2_read_o == 1'b1) begin
		reg2_o <= reg2_data_i; 	//从Regfile读端口2的数据
	end
	else if(reg2_read_o == 1'b0) begin
		reg2_o <= imm;
	end
	else begin
		reg2_o <= `ZeroWord;
	end
end






endmodule
