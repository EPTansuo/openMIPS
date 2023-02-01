
//作用:对指令进行译码

module id(
	input wire	rst,			//复位信号
	input wire[`InstAddrBus]	pc_i,	//译码阶段的指令对应的地址
	input wire[`InstBus]	inst_i,		//译码阶段的指令

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
wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
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
			`EXE_ORI: begin				//判断是否为ori指令
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_OR_OP;		//运算子类型为或
				alusel_o <= `EXE_RES_LOGIC;	//类算类型为逻辑运算
				reg1_read_o <= 1'b1;		//需要端口1的数据
				reg2_read_o <= 1'b0;		//不需要端口2的数据
				imm <= {16'h0, inst_i[15:0]}	//合并得到立即数
				wd_o <= inst_i[20:16];		//要写入目的寄存器的地址
				instvalid <= `InstValid;	//指令有效
			end
			default: begin
			end
		end
		endcase
	end
end


//*****************************确定进行运算的源操作数1***********************

always@(*)begin
	if(rst == `RstEnable) begin
		reg1_o <= `ZeroWord;
	end
	else if(reg1_read_o == 1'b1) begin
		reg1_o <= reg1_data_i; 	//从Regfile读端口1的数据
	end
	else if(reg1_data_o == 1'b0) begin
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
	else if(reg2_read_o == 1'b1) begin
		reg2_o <= reg2_data_i; 	//从Regfile读端口2的数据
	end
	else if(reg2_data_o == 1'b0) begin
		reg2_o <= imm;
	end
	else begin
		reg2_o <= `ZeroWord;
	end
end






endmodule
