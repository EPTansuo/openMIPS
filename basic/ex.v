//创建时间: 2023年 02月 02日 星期四 
//最后修改时间: 2023年 02月 05日 星期日
//最后修改时间: 2023年 04月 08日 星期六
//作用: 依据数据进行运算
//


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
reg[`RegBus] HI;//保存HI寄存器的最新值
reg[`RegBus] LO;//保存LO寄存器的最新值



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


//*****************************完成算术运算****************************
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



//***********************根据运算类型,选择运算结果进行输出*****************
always@(*) begin
	wd_o <= wd_i;
	wreg_o <= wreg_i;
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
		default: begin
			wdata_o <= `ZeroWord;
		end
	endcase
end



//*************如果是MTHI MTLO指令,则需要给出whilo_o,hi_o,lo_i*********
always@(*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end
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
	else begin 
		whilo_o <= `WriteEnable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end
end

endmodule
