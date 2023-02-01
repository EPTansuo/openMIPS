`timescale 1ns/100ps

module pc_reg_tb;

parameter clk_period = 10;
reg clk;
reg pc;
reg ce;


initial begin
	$dumpfile("wave.vcd");
	$dumpfile(0,pc_reg_tb);
end




initial begin
	clk = 0;
	forever 
		#(clk_period/2) clk = ~clk;
end

always@(posedge clk) begin
	ce <= 1;
	rst <= 0;
	pc_reg pc_reg_inst(
		.clk(clk),
		.pc(pc),
		.ce(ce),
		.rst(rst)
	);
end

endmodule
