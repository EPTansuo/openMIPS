
//创建时间: 2023年 02月 02日 星期四 
//最后修改时间: 2023年 02月 05日 星期日
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
	output reg[`RegBus]	wdata_o

);

//保存逻辑运算的结果
reg[`RegBus] logicout;

//保存移位运算的结果
reg[`RegBus] shiftres;


//*****************************根据运算子类型进行运算****************************
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
				logicout <= `ZeroWord;
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
		default: begin
			wdata_o <= `ZeroWord;
		end
	endcase
end

endmodule
