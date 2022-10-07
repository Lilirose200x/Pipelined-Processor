proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
add wave 	sim:/pipeline_tb/clk 
add wave 	sim:/pipeline_tb/IF_load_flag
add wave 	sim:/pipeline_tb/IF_branch_flag
add wave 	sim:/pipeline_tb/IF_branch_taken
add wave 	sim:/pipeline_tb/IF_branch_target
add wave	sim:/pipeline_tb/IF_predict_enable 
add wave	sim:/pipeline_tb/IF_branch_predict 
add wave 	sim:/pipeline_tb/IF_fetch
add wave 	sim:/pipeline_tb/ID_ALU 
add wave 	sim:/pipeline_tb/ID_instruction 
add wave 	sim:/pipeline_tb/EX_current_PC
add wave 	sim:/pipeline_tb/EX_opcode 
add wave 	sim:/pipeline_tb/EX_alu_result 
add wave 	sim:/pipeline_tb/EX_instruction 
add wave 	sim:/pipeline_tb/EX_mux_select_1 
add wave 	sim:/pipeline_tb/EX_mux_select_2 
add wave 	sim:/pipeline_tb/EX_MEM_stage_data1 
add wave 	sim:/pipeline_tb/EX_WB_stage_data1 
add wave 	sim:/pipeline_tb/DM_ALU_out_to_WB 
add wave 	sim:/pipeline_tb/DM_ALU_out_to_ex 
add wave 	sim:/pipeline_tb/DM_DM_out 
add wave 	sim:/pipeline_tb/DM_Mem_flag_from_EX
add wave 	sim:/pipeline_tb/DM_writedata
add wave 	sim:/pipeline_tb/WB_ALU_out_from_DM
add wave 	sim:/pipeline_tb/WB_WB_register_from_DM
add wave 	sim:/pipeline_tb/WB_WB_flag_from_DM 
add wave 	sim:/pipeline_tb/WB_writedata
add wave 	sim:/pipeline_tb/WB_writeregister 
add wave 	sim:/pipeline_tb/preC_Index 
add wave 	sim:/pipeline_tb/preC_Miss 
add wave 	sim:/pipeline_tb/preC_PC_current 
add wave 	sim:/pipeline_tb/preC_PC_target 
add wave 	sim:/pipeline_tb/preC_predirection 
add wave 	sim:/pipeline_tb/preC_ReadData 
add wave 	sim:/pipeline_tb/PreE_Branch
add wave 	sim:/pipeline_tb/PreE_BranchInfo_virtual 
add wave 	sim:/pipeline_tb/PreE_IncrPC 
add wave 	sim:/pipeline_tb/PreE_PredIndexWrite 
add wave 	sim:/pipeline_tb/PreE_PredInfo_IF 
add wave 	sim:/pipeline_tb/PreE_Reset 
add wave 	sim:/pipeline_tb/PreE_WriteData
add wave 	sim:/pipeline_tb/PreE_WriteEnable
add wave 	sim:/pipeline_tb/PreT_IndexRead
add wave 	sim:/pipeline_tb/PreT_IndexWrite 
add wave 	sim:/pipeline_tb/PreT_ReadData 
add wave 	sim:/pipeline_tb/PreT_RegWrite 
add wave 	sim:/pipeline_tb/PreT_WriteData 
add wave    sim:/pipeline_tb/reg_1 
add wave    sim:/pipeline_tb/reg_2
add wave    sim:/pipeline_tb/reg_3 
add wave    sim:/pipeline_tb/reg_4 
add wave    sim:/pipeline_tb/reg_5 
add wave    sim:/pipeline_tb/reg_6 
add wave    sim:/pipeline_tb/reg_7 
add wave    sim:/pipeline_tb/reg_8
add wave    sim:/pipeline_tb/reg_9
add wave    sim:/pipeline_tb/reg_10
add wave    sim:/pipeline_tb/reg_11 
add wave    sim:/pipeline_tb/reg_12
add wave    sim:/pipeline_tb/reg_13 
add wave    sim:/pipeline_tb/reg_14 
add wave    sim:/pipeline_tb/reg_15 
add wave    sim:/pipeline_tb/reg_16 
add wave    sim:/pipeline_tb/reg_17 
add wave    sim:/pipeline_tb/reg_18
add wave    sim:/pipeline_tb/reg_19
add wave    sim:/pipeline_tb/reg_20 
add wave    sim:/pipeline_tb/reg_21 
add wave    sim:/pipeline_tb/reg_22
add wave    sim:/pipeline_tb/reg_23 
add wave    sim:/pipeline_tb/reg_24 
add wave    sim:/pipeline_tb/reg_25 
add wave    sim:/pipeline_tb/reg_26 
add wave    sim:/pipeline_tb/reg_27 
add wave    sim:/pipeline_tb/reg_28
add wave    sim:/pipeline_tb/reg_29
add wave    sim:/pipeline_tb/reg_30
add wave    sim:/pipeline_tb/reg_31 


}

vlib work

;# Compile components if any
vcom WriteBack.vhd
vcom PipelineTB.vhd
vcom Execution.vhd
vcom decode.vhd
vcom pipeline.vhd
vcom Instruction_Memory.vhd
vcom fetch.vhd
vcom Data_Memory.vhd
vcom ALU.vhd
vcom PredController.vhd
vcom PredEvalu.vhd
vcom BranchTable.vhd

;# Start simulation
vsim -t ps Pipeline_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 10000ns
run 10000ns
