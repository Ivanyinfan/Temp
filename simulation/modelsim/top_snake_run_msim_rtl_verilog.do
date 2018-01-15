transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/VGA_Control.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/top_snake.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/Snake_Eatting_Apple.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/Snake.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/Seg_Display.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/Key.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/source {E:/altera/13.1/Project/tanchishe/source/Game_Ctrl_Unit.v}

vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/tanchishe/simulation {E:/altera/13.1/Project/tanchishe/simulation/snake_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  snake_sim

add wave *
add wave /snake_sim/snake_instance/U6/left_key_press
add wave /snake_sim/snake_instance/U6/right_key_press
add wave /snake_sim/snake_instance/U6/up_key_press
add wave /snake_sim/snake_instance/U6/down_key_press
add wave /snake_sim/snake_instance/U2/game_status
view structure
view signals
run 200ps -all
