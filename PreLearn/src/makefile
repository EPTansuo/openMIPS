wavevcd:wave
	vvp -n wave -lxt2

wave:inst_fetch_tb.v inst_fetch.v pc_reg.v rom.v
	iverilog -o wave -y ./ inst_fetch_tb.v
clean:
	rm wave 
