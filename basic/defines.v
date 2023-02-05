
//创建时间: 2023年 02月 01日 星期三 
//最后修改时间: 2023年 02月 05日 星期日
//********************全局宏定义*********************



`define RstEnable	1'b1		//复位使能
`define RstDisable	1'b0		//复位失能
`define ZeroWord	32'h00000000	//32位的0
`define WriteEnable	1'b1		//写使能
`define WriteDisable	1'b0		//写失能
`define ReadEnable	1'b1		//读使能
`define ReadDisable	1'b0		//读失能
`define AluOpBus	7:0		//译码阶段的aluop_o的位宽
`define AluSelBus	2:0		//译码阶段的alusel_sel的位宽
`define InstValid	1'b0		//指令有效
`define InstInvalid	1'b1		//指令无效
`define True_v		1'b1		//逻辑真
`define False_v		1'b0		//逻辑假
`define ChipEnable	1'b1		//芯片使能
`define ChipDisable	1'b0		//芯片失能

//******************与具体指令有关的宏***************

`define EXE_AND		6'b100100	//and的功能码
`define EXE_OR		6'b100101	//or的功能码
`define EXE_XOR		6'b100110	//xor的功能码
`define EXE_NOR		6'b100111	//nor的功能码
`define EXE_ANDI	6'b001100	//andi的指令码
`define EXE_ORI		6'b001101	//ori的指令码
`define EXE_XORI	6'b001110	//xori的指令码
`define EXE_LUI		6'b001111	//lui的指令码

`define EXE_SLL		6'b000000	//sll的功能码
`define EXE_SLLV	6'b000100	//sllv的功能码
`define EXE_SRL		6'b000010	//srl的功能码
`define EXE_SRLV	6'b000110	//srlv的功能码
`define EXE_SRA		6'b000011	//sra的功能码
`define EXE_SRAV	6'b000111	//srav的功能码

`define EXE_SYNC	6'b001111	//sync的功能码
`define EXE_PREF	6'b110011	//pref的指令码
`define EXE_SPECIAL_INST 6'b000000	//SPECIAL类指令的指令码

`define EXE_NOP		6'b000000




//Aluop
`define EXE_OR_OP	8'b00100101
`define EXE_AND_OP	8'b00100100
`define EXE_OR_OP	8'b00100101
`define EXE_XOR_OP	8'b00100110
`define EXE_NOR_OP	8'b00100111
`define EXE_ANDI_OP	8'b01011001
`define EXE_ORI_OP	8'b01011010
`define EXE_XORI_OP	8'b01011011
`define EXE_LUI_OP	8'b01011100

`define EXE_SLL_OP	8'b01111100
`define EXE_SLLV_OP	8'b00000100
`define EXE_SRL_OP	8'b00000010
`define EXE_SRLV_OP	8'b00000110
`define EXE_SRA_OP	8'b00000011
`define EXE_SRAV_OP	8'b00000111

`define EXE_NOP_OP	8'b00000000

//AluSel
`define EXE_RES_LOGIC	3'b001
`define EXE_RES_SHIFT	3'b010
`define EXE_RES_NOP	3'b000


//*****************与指令存储器ROM有关的宏定义********

`define InstAddrBus	31:0		//ROM的地址总线宽度
`define InstBus		31:0		//ROM的数据总线宽度
`define InstMemNum	131071		//ROM的实际大小为128kB
`define InstMemNumLog2	17		//ROM实际使用的地址线宽度

//**************与通用寄存器regfile有关的宏定义*******

`define RegAddrBus	4:0		//Regfile模块的地址线位宽
`define RegBus		31:0		//Regfile模块的数据线位宽
`define RegWidth	32		//通用寄存器的位宽
`define DoubleRegWidth	64		//两倍通用寄存器的位宽
`define DoubleRegBus	63:0		//两倍通用寄存器的数据线位宽	
`define RegNum		32		//通用寄存器的数量
`define RegNumLog2	5		//寻址通用寄存器使用的地址位数
`define NOPRegAddr	5'b00000	
