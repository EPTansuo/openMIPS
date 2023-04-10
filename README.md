# 《自己动手写CPU》学习记录

## 设计目标

- 五级整数流水线，分别是：取指、译码、执行、访存、回写。
- 哈佛结构，分开的指令、数据接口。
- 32 个 32 位整数寄存器。
- 大端模式。
- 向量化异常处理，支持精确异常处理。
- 支持 6 个外部中断。
- 具有 32bit 数据、地址总线宽度。
- 能实现单周期乘法。
- 支持延迟转移。
- 兼容 MIPS32 指令集架构，支持 MIPS32 指令集中的所有整数指令。
- 大多数指令可以在一个时钟周期内完成。

<img src="README.assets/image-20230201184542992.png" alt="image-20230201184542992" style="zoom:50%;" />

## 阶段一. 预学习[已完成]

实现: 使用iverilog和gtkwave工具, 实现对verilog的编译和仿真.

## 阶段二. 实现ori(或)指令[已完成]

### ori指令:

![ori指令格式](README.assets/image-20230201185000060.png)

## 阶段三. 实现其它逻辑指令和移位指令[已完成]

对数据相关问题进行了修改.

增加了逻辑操作, 移位操作和空指令

指令格式:

![Screenshot_20230410_141222](README.assets/Screenshot_20230410_141222.png)

![Screenshot_20230410_140727](README.assets/Screenshot_20230410_140727.png)

## 阶段四. 实现移动操作指令[已完成]

`movn`,`movz`,`mfhi`,`mthi`,`mflo`,`mtlo`

指令格式:

![Screenshot_20230410_140802](README.assets/Screenshot_20230410_140802.png)

## 阶段五. 实现算术操作指令

`add`,`addi`,`addiu`,`addu`,`sub`,`subu`,`clo`,`clz`,`slt`,`slti`,`sltiu`,`sltu`,`mul`,`mult`,`multu`.

add、addu、sub、subu、slt、sltu 指令格式:

![image-20230410141058566](README.assets/image-20230410141058566.png)

addi、addiu、slti、sltiu 指令格式:

![image-20230410141118207](README.assets/image-20230410141118207.png)

clo、clz 指令格式:

![image-20230410141151549](README.assets/image-20230410141151549.png)

multu、mult、mul 指令格式:

![image-20230410141304577](README.assets/image-20230410141304577.png)
