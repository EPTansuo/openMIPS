
//创建时间: 2023年 02月 02日 星期四 
//作用: 依据数据进行运算
//
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

);

//保留逻辑运算的结果
reg[`RegBus] logicout;



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
		default: begin
			wdata_o <= `ZeroWord;
		end
	endcase
end

endmodule
