transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/resetClock.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/io_out.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/io_in.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/io_output_reg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/io_input_reg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/dff32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/mux2x5.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/regfile.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pl_instmen.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pl_datamem.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipe_cu.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/mux4x32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/mux2x32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/lpm_rom_irom.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/lpm_ram_dq_dram.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/dffe32.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/alu.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer {E:/altera/13.1/Project/pl_computer/pl_computer.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipeif.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipepc.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipeir.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipeid.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipedereg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/dff1.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/diff4.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/diff5.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipeexe.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipeemreg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipemem.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/pipemwreg.v}
vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/source {E:/altera/13.1/Project/pl_computer/source/Bubble32.v}

vlog -vlog01compat -work work +incdir+E:/altera/13.1/Project/pl_computer/simulation {E:/altera/13.1/Project/pl_computer/simulation/pl_computer_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  pl_computer_sim

	add wave /pl_computer_sim/resetn_sim
	add wave /pl_computer_sim/clock_50M_sim
	add wave /pl_computer_sim/mem_clock_sim
	############################# IF ############################
	add wave /pl_computer_sim/pl_computer_instance/if_stage/pc
	add wave /pl_computer_sim/pl_computer_instance/if_stage/ins
	############################# IR ############################
	#add wave /pl_computer_sim/pl_computer_instance/inst_reg/dbubble
	add wave /pl_computer_sim/pl_computer_instance/inst_reg/inst
	############################# ID ############################
	add wave /pl_computer_sim/pl_computer_instance/id_stage/wpcir
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/em2reg
	add wave /pl_computer_sim/pl_computer_instance/id_stage/wdi
	add wave /pl_computer_sim/pl_computer_instance/id_stage/wrn
	add wave /pl_computer_sim/pl_computer_instance/id_stage/wwreg
	add wave /pl_computer_sim/pl_computer_instance/id_stage/inst
	add wave /pl_computer_sim/pl_computer_instance/id_stage/rf/rnb
	add wave /pl_computer_sim/pl_computer_instance/id_stage/rf/qb
	add wave /pl_computer_sim/pl_computer_instance/id_stage/rf/wn
	add wave /pl_computer_sim/pl_computer_instance/id_stage/rf/d
	add wave /pl_computer_sim/pl_computer_instance/id_stage/rf/we
	add wave /pl_computer_sim/pl_computer_instance/id_stage/rf/register
	add wave /pl_computer_sim/pl_computer_instance/id_stage/qa
	add wave /pl_computer_sim/pl_computer_instance/id_stage/qb
	add wave /pl_computer_sim/pl_computer_instance/id_stage/da_source
	add wave /pl_computer_sim/pl_computer_instance/id_stage/db_source
	add wave /pl_computer_sim/pl_computer_instance/id_stage/db
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/rsrtequ
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/jpc
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/dbubble
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/pcsource
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/dimm
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/dpc4
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/offset
	#add wave /pl_computer_sim/pl_computer_instance/id_stage/bpc
	############################# EXE ############################
	add wave /pl_computer_sim/pl_computer_instance/exe_stage/alua
	add wave /pl_computer_sim/pl_computer_instance/exe_stage/alub
	add wave /pl_computer_sim/pl_computer_instance/exe_stage/ern
	############################# MEM ############################
	add wave /pl_computer_sim/pl_computer_instance/mem_stage/malu
	add wave /pl_computer_sim/pl_computer_instance/mem_stage/in_port0
	add wave /pl_computer_sim/pl_computer_instance/mem_stage/in_port1
	add wave /pl_computer_sim/pl_computer_instance/mem_stage/dmem/io_read_data
	add wave /pl_computer_sim/pl_computer_instance/mem_stage/mmo
	############################# WB #############################
	add wave /pl_computer_sim/pl_computer_instance/wdi
	##############################################################
	#add wave /pl_computer_sim/pl_computer_instance/hex0
	#add wave /pl_computer_sim/pl_computer_instance/hex2
	#add wave /pl_computer_sim/pl_computer_instance/hex4
	
view structure
view signals
run 200ps -all
