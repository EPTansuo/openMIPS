#!/bin/bash

iverilog -y ./ -o sim  openmips_min_sopc_tb.v
echo "iverlog finised!"

vvp -n sim -lxt2

echo "vvp finfished!"
