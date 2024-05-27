quit -sim

vlib ./lib/ 
vlib ./lib/work/ 

vmap work ./lib/work/

vlog -work work ./../design/*.v
vlog -work work ./../sim/multiplier_tb.v

vsim -voptargs=+acc work.multiplier_tb 

add wave -divider multiplier_tb 

add wave multiplier_tb/*

add wave -divider {multiplier}
add wave multiplier_tb/multiplier_inst/*

run 500ns
