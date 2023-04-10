#!/bin/bash

iverilog -Wall -y ./ -o sim.vvp  -s openmips_min_sopc_tb  *.v
echo "iverlog finised!"

vvp -n sim.vvp -lxt2

echo "vvp finfished!"
