transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/sc_instmen.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/sc_datamem.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/sc_cu.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/sc_cpu.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/sc_computer.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/regfile.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/mux4x32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/mux2x32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/mux2x5.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/lpm_rom_irom.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/lpm_ram_dq_dram.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/io_output_reg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/io_input_reg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/io_in.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/io_out.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/dff32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/source {E:/altera/13.1/Project/sc_computer/source/alu.v}

vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/sc_computer/simulation {E:/altera/13.1/Project/sc_computer/simulation/sc_computer_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiv_hssi_ver -L cycloneiv_pcie_hip_ver -L cycloneiv_ver -L rtl_work -L work -voptargs="+acc"  sc_computer_sim

add wave /sc_computer_sim/resetn_sim
add wave /sc_computer_sim/clock_50M_sim
add wave /sc_computer_sim/mem_clk_sim
#add wave /sc_computer_sim/imem_clk_sim
#add wave /sc_computer_sim/dmem_clk_sim
add wave /sc_computer_sim/pc_sim
add wave /sc_computer_sim/inst_sim
add wave /sc_computer_sim/aluout_sim
add wave /sc_computer_sim/sc_computer_instance/led3
add wave /sc_computer_sim/sc_computer_instance/in_port0
add wave /sc_computer_sim/sc_computer_instance/in_port1
add wave /sc_computer_sim/sc_computer_instance/dmem/io_read_data
add wave /sc_computer_sim/memout_sim

view structure
view signals
run -all
