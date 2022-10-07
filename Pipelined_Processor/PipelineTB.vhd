LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Pipeline_tb IS
END Pipeline_tb;

ARCHITECTURE Behaviour of Pipeline_tb IS

component Pipeline is
    port(
			clk:				in std_logic;
			--- debug protocal
			--fetch--
			IF_branch_target_debug: 			out STD_logic_vector(31 downto 0);
			IF_branch_flag_debug:	 			out STD_logic;
			IF_branch_taken_debug:  			out STD_logic:='0';
			IF_load_flag_debug: 					out STD_logic;
			IF_predict_enable_debug:			out std_logic;
	      IF_branch_predict_debug:	      out std_logic_vector(31 downto 0);
			IF_next_pc_debug: 					out STD_logic_vector(31 downto 0);
			IF_fetch_debug: 						out STD_logic_vector(31 downto 0);
			--decode--
			ID_instruction_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_current_PC_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_wb_register_debug:  				out STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_wb_register_data_debug: 		out STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_read_data_1_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_read_data_2_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_ALU_debug:  						out STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_sign_extend_debug:  				out STD_LOGIC_VECTOR(31 downto 0); -- sign extend or zero extend
			ID_wb_flag_debug:  					out STD_LOGIC;
			ID_mem_access_flag_debug:  		out STD_LOGIC;
			ID_br_and_j_flag_debug:  			out STD_LOGIC;
			ID_load_flag_debug:  				out STD_LOGIC;
			ID_wb_register_out_debug:  		out STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_current_PC_out_debug:   		out STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_rs_out_debug:  					out STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_rt_out_debug:  					out STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_HI_data_debug: 					out STD_logic_vector(31 downto 0);
			ID_LO_data_debug: 					out STD_logic_vector(31 downto 0);
			--execution--
			EX_instruction_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_opcode_debug:  					out STD_LOGIC_VECTOR (4 DOWNTO 0);
			EX_current_PC_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_rs_data_debug:  					out STD_LOGIC_VECTOR (31 DOWNTO 0);  -- data1
			EX_rt_data_debug:  					out STD_LOGIC_VECTOR (31 DOWNTO 0);	-- data2
			EX_mux_select_1_debug:  			out STD_LOGIC_VECTOR (1 DOWNTO 0);
			EX_mux_select_2_debug:  			out STD_LOGIC_VECTOR (1 DOWNTO 0);
			EX_wb_flag_from_ID_debug:  		out STD_LOGIC;
			EX_mem_flag_from_ID_debug: 		out STD_LOGIC;
			EX_wb_register_from_ID_debug: 	out STD_LOGIC_VECTOR (4 downto 0);
			EX_rs_from_ID_debug:  				out STD_LOGIC_VECTOR (4 downto 0);
			EX_rt_from_ID_debug:  				out STD_LOGIC_VECTOR (4 downto 0);
			EX_WB_stage_data1_debug:  			out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_MEM_stage_data1_debug: 			out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_wb_flag_to_DM_debug:  			out STD_LOGIC;
			EX_mem_flag_to_DM_debug:  			out STD_LOGIC;
			EX_wb_register_to_DM_debug:  		out STD_LOGIC_VECTOR (4 downto 0);
			EX_alu_result_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_long_part_1_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_long_part_2_debug:  				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_branch_jump_debug: 				out STD_LOGIC:='0';
			EX_updated_PC_debug: 				out STD_LOGIC_VECTOR (31 DOWNTO 0);
			EX_opcode_to_mem_debug:  			out STD_LOGIC_VECTOR (4 DOWNTO 0);
			EX_data_to_mem_debug: 				out STD_LOGIC_VECTOR (31 DOWNTO 0);
				--MEM--
		   DM_clock_debug:					 	out STD_logic;		
		   DM_WB_flag_from_EX_debug:				 	out STD_logic;	-- write back flag, will be directly passed to WB_flag_from_DM
		   DM_Mem_flag_from_EX_debug:				 		out STD_logic;	-- data memory access flag,                                      -- '0' refers to access Data Mem, '1' refers to pass through
		   DM_opcode_debug:				 		out STD_logic_vector(4 downto 0); -- opcode of the instruction, sent by the execution stage
		   DM_writedata_debug:			 		out STD_logic_vector(31 downto 0); -- data to write to the data memory
		   DM_ALU_res_from_EX_debug:				 		out STD_logic_vector(31 downto 0); -- ALU output
		   DM_WB_reg_from_EX_debug:		 	out STD_logic_vector(4 downto 0);
		   DM_Mem_flag_to_WB_debug:				 		out STD_logic;	-- memory access flag
		   DM_WB_flag_to_WB_debug:				 	out STD_logic;	-- writeback flag
		   DM_DM_out_debug:				out STD_logic_vector(31 downto 0); -- data that is loaded from data memory
		   DM_ALU_out_to_WB_debug:				out STD_logic_vector(31 downto 0); -- actually it should be the data output from ALU, which is directly passed to the Writeback stage, wrong name
		   DM_WB_reg_to_WB_debug:			out STD_logic_vector(4 downto 0);
		   DM_ALU_out_to_EX_debug: 			out STD_logic_vector(31 downto 0);
		   --WB--
		   WB_Mem_flag_from_DM_debug:			 			out STD_logic; -- input of multiplexer, data memory access flag
		   WB_WB_flag_from_DM_debug:			 		out STD_logic; -- writeback flag;
		   WB_DM_out_debug:				out STD_logic_vector(31 downto 0); -- data loaded from data memory
		   WB_ALU_out_from_DM_debug:		 			out STD_logic_vector(31 downto 0); -- actually it should be the data from ALU, wrong name
		   WB_WB_register_from_DM_debug:		 	out STD_logic_vector(4 downto 0);
		   WB_writedata_debug:			 		out STD_logic_vector(31 downto 0);
		   WB_writeregister_debug:			 		out STD_logic_vector(4 downto 0);
		   --PredictTable
		   PreT_RegWrite_debug: 				out STD_LOGIC;        
		   PreT_IndexRead_debug:  				out STD_LOGIC_vector(5 downto 0);  
		   PreT_IndexWrite_debug: 				out STD_LOGIC_vector(5 downto 0); 
	 	   PreT_WriteData_debug:  				out STD_LOGIC_vector(58 downto 0);
	 	   PreT_ReadData_debug:   				out STD_LOGIC_vector(58 downto 0);
	 	   --PredictController
		   preC_ReadData_debug: 				out STD_LOGIC_vector(58 downto 0); --From BTB
		   preC_PC_current_debug: 				out STD_LOGIC_vector(31 downto 0);
		   preC_Index_debug: 			 		out STD_LOGIC_vector(5 downto 0);  -- index to look up BTB
		   preC_PC_target_debug: 				out STD_LOGIC_vector(31 downto 0); --Target address
		   preC_predirection_debug: 	 		out STD_LOGIC;  --predicted direction: taken(1) or not taken(0)
			PreC_enable_Pred_debug: 			out STD_LOGIC;
		   preC_Miss_debug: 			 			out STD_LOGIC;
		   --PredEvalu
		   PreE_Branch_debug:  					out STD_LOGIC;
		   PreE_IncrPC_debug:  					out STD_LOGIC_vector(31 downto 0);  -- write into updating table
		   PreE_PredInfo_IF_debug:  			out STD_LOGIC_vector(60 downto 0); --data form IF phase about prediction
		   PreE_BranchInfo_virtual_debug:  	out STD_LOGIC_vector(32 downto 0);
		   PreE_WriteData_debug:  				out STD_LOGIC_vector(58 downto 0); --write data used to update predict table
		   PreE_WriteEnable_debug:  			out STD_LOGIC;     --enable  to update predict table
		   PreE_Reset_debug:  					out STD_LOGIC;      -- to reset fetched instruction for faultly predicting
		   PreE_PredIndexWrite_debug:  		out STD_LOGIC_vector(5 downto 0);	
			-- register debug
		   reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
		   reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
		   reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
		   reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)
        );
end component;

		signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
		--- debug protocal
		
		
		--fetch--
	 signal IF_branch_target: std_logic_vector(31 downto 0);
	 signal IF_branch_flag:	 std_logic;
	 signal IF_branch_taken:  std_logic:='0';
	 signal IF_load_flag: std_logic;
	 signal IF_predict_enable:			 std_logic;
	 signal IF_branch_predict:			std_logic_vector(31 downto 0);
	 signal IF_next_pc: std_logic_vector(31 downto 0);
	 signal IF_fetch: std_logic_vector(31 downto 0);
--decode--
	 signal  ID_instruction:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 signal  ID_current_PC:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 signal  ID_wb_register:  STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal  ID_wb_register_data:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 signal  ID_read_data_1:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 signal  ID_read_data_2:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 signal  ID_ALU :  STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal  ID_sign_extend:  STD_LOGIC_VECTOR(31 downto 0); -- sign extend or zero extend
	 signal  ID_wb_flag:  STD_LOGIC;
	 signal  ID_mem_access_flag:  STD_LOGIC;
	 signal  ID_br_and_j_flag:  STD_LOGIC;
	 signal  ID_load_flag:  STD_LOGIC;
	 signal  ID_wb_register_out:  STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal  ID_current_PC_out:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 signal  ID_rs_out:  STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal  ID_rt_out:  STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal  ID_HI_data: std_logic_vector(31 downto 0);
	 signal  ID_LO_data: std_logic_vector(31 downto 0);
--EXE--
    signal EX_instruction:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_opcode:  STD_LOGIC_VECTOR (4 DOWNTO 0);
    signal EX_current_PC:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_rs_data:  STD_LOGIC_VECTOR (31 DOWNTO 0);  -- data1
    signal EX_rt_data:  STD_LOGIC_VECTOR (31 DOWNTO 0);	-- data2
    signal EX_mux_select_1:  STD_LOGIC_VECTOR (1 DOWNTO 0);
    signal EX_mux_select_2:  STD_LOGIC_VECTOR (1 DOWNTO 0);
    signal EX_wb_flag_from_ID:  STD_LOGIC;
    signal EX_mem_flag_from_ID:  STD_LOGIC;
    signal EX_wb_register_from_ID:  STD_LOGIC_VECTOR (4 downto 0);
    signal EX_rs_from_ID:  STD_LOGIC_VECTOR (4 downto 0);
    signal EX_rt_from_ID:  STD_LOGIC_VECTOR (4 downto 0);
    signal EX_WB_stage_data1:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_MEM_stage_data1:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_wb_flag_to_DM:  STD_LOGIC;
    signal EX_mem_flag_to_DM:  STD_LOGIC;
    signal EX_wb_register_to_DM:  STD_LOGIC_VECTOR (4 downto 0);
    signal EX_alu_result:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_long_part_1 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_long_part_2 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_branch_jump :  STD_LOGIC:='0';
    signal EX_updated_PC:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal EX_opcode_to_mem:  STD_LOGIC_VECTOR (4 DOWNTO 0);
    signal EX_data_to_mem: STD_LOGIC_VECTOR (31 DOWNTO 0);
--MEM--
	 signal DM_clock:					 std_logic;		
	 signal DM_WB_flag_from_EX:				 std_logic;	-- write back flag, will be directly passed to WB_flag_from_DM
	 signal DM_Mem_flag_from_EX:				 std_logic;	-- data memory access flag,                                      -- '0' refers to access Data Mem, '1' refers to pass through
	 signal DM_opcode:					 std_logic_vector(4 downto 0); -- opcode of the instruction, sent by the execution stage
	 signal DM_writedata:				 std_logic_vector(31 downto 0); -- data to write to the data memory
	 signal DM_ALU_res_from_EX:				 std_logic_vector(31 downto 0); -- ALU output
	 signal DM_WB_reg_from_EX:			 std_logic_vector(4 downto 0);
	 signal DM_Mem_flag_to_WB:				 std_logic;	-- memory access flag
	 signal DM_WB_flag_to_WB:				 std_logic;	-- writeback flag
	 signal DM_DM_out:			 std_logic_vector(31 downto 0); -- data that is loaded from data memory
	 signal DM_ALU_out_to_WB:			 std_logic_vector(31 downto 0); 
	 signal DM_WB_reg_to_WB:			 std_logic_vector(4 downto 0);
	 signal DM_ALU_out_to_EX: 			 std_logic_vector(31 downto 0);
--WB--
    signal WB_Mem_flag_from_DM:			 std_logic; -- input of multiplexer, data memory access flag
    signal WB_WB_flag_from_DM:			 std_logic; -- writeback flag;
    signal WB_DM_out:		 std_logic_vector(31 downto 0); -- data loaded from data memory
    signal WB_ALU_out_from_DM:		 std_logic_vector(31 downto 0); -- actually it should be the data from ALU, wrong name
    signal WB_WB_register_from_DM:		 std_logic_vector(4 downto 0);
    signal WB_writedata:			 std_logic_vector(31 downto 0);
    signal WB_writeregister:			 std_logic_vector(4 downto 0);
	 
--PredictTable
	 signal PreT_RegWrite: 		STD_LOGIC;        
    signal PreT_IndexRead:  	STD_LOGIC_vector(5 downto 0);  
	 signal PreT_IndexWrite: 	STD_LOGIC_vector(5 downto 0); 
	 signal PreT_WriteData:  	STD_LOGIC_vector(58 downto 0);
	 signal PreT_ReadData:   	STD_LOGIC_vector(58 downto 0);
--PredictController
	 signal preC_ReadData: 		STD_LOGIC_vector(58 downto 0); --From BTB
	 signal preC_PC_current: 	STD_LOGIC_vector(31 downto 0);
	 signal preC_Index: 			 STD_LOGIC_vector(5 downto 0);  -- index to look up BTB
	 signal preC_PC_target: 		 STD_LOGIC_vector(31 downto 0); --Target address
	 signal preC_predirection: 	 STD_LOGIC;  --predicted direction: taken(1) or not taken(0)
	 signal PreC_enable_Pred: STD_LOGIC;
	 signal preC_Miss: 			 STD_LOGIC;
--PredEvalu
	 signal PreE_Branch :  STD_LOGIC;
	 signal PreE_IncrPC :  STD_LOGIC_vector(31 downto 0);  -- write into updating table
	 signal PreE_PredInfo_IF :  STD_LOGIC_vector(60 downto 0); --data form IF phase about prediction
	 signal PreE_BranchInfo_virtual :  STD_LOGIC_vector(32 downto 0);
	 signal PreE_WriteData :  STD_LOGIC_vector(58 downto 0); --write data used to update predict table
	 signal PreE_WriteEnable :  STD_LOGIC;     --enable signal to update predict table
	 signal PreE_Reset :  STD_LOGIC;      -- to reset fetched instruction for faultly predicting
	 signal PreE_PredIndexWrite :  STD_LOGIC_vector(5 downto 0);
	 

	signal reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: std_logic_vector(31 downto 0);
    signal reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: std_logic_vector(31 downto 0);
    signal reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: std_logic_vector(31 downto 0);
    signal reg_27, reg_28, reg_29, reg_30, reg_31: std_logic_vector(31 downto 0);

    BEGIN

    	dut: Pipeline port MAP(
    		clk => clk,
			
			IF_branch_target_debug 		=> 		IF_branch_target,
			IF_branch_flag_debug 		=>			IF_branch_flag,
			IF_branch_taken_debug 		=>  		IF_branch_taken,
			IF_load_flag_debug 			=> 		IF_load_flag,	
			IF_predict_enable_debug		=>			IF_predict_enable,
			IF_branch_predict_debug		=>			IF_branch_predict,
			IF_next_pc_debug 				=> 		IF_next_pc,	 
			IF_fetch_debug 				=> 		IF_fetch,			 
			--decode--
			ID_instruction_debug 		=> 		ID_instruction, 		 
			ID_current_PC_debug 			=>  		ID_current_PC, 
			ID_wb_register_debug 		=>  		ID_wb_register, 
			ID_wb_register_data_debug 	=>  		ID_wb_register_data,
			ID_read_data_1_debug 		=>  		ID_read_data_1, 
			ID_read_data_2_debug 		=>  		ID_read_data_2,
			ID_ALU_debug 					=>  		ID_ALU,	 
			ID_sign_extend_debug 		=>  		ID_sign_extend,
			ID_wb_flag_debug 				=>  		ID_wb_flag,
			ID_mem_access_flag_debug 	=>  		ID_mem_access_flag,
			ID_br_and_j_flag_debug 		=>  		ID_br_and_j_flag,
			ID_load_flag_debug 			=>  		ID_load_flag,
			ID_wb_register_out_debug 	=>   		ID_wb_register_out,
			ID_current_PC_out_debug 	=>    	ID_current_PC_out,
			ID_rs_out_debug 				=>  		ID_rs_out, 
			ID_rt_out_debug 				=>  		ID_rt_out, 
			ID_HI_data_debug 				=> 		ID_HI_data,
			ID_LO_data_debug 				=> 		ID_LO_data, 
			--execution--
			EX_instruction_debug 		=>  		EX_instruction,			 
			EX_opcode_debug 				=>  		EX_opcode,		 
			EX_current_PC_debug 			=>  		EX_current_PC,	 
			EX_rs_data_debug 				=>  		EX_rs_data,		   
			EX_rt_data_debug 				=>  		EX_rt_data,		 	
			EX_mux_select_1_debug 		=>  		EX_mux_select_1, 
			EX_mux_select_2_debug 		=>  		EX_mux_select_2, 
			EX_wb_flag_from_ID_debug 	=>  		EX_wb_flag_from_ID,
			EX_mem_flag_from_ID_debug 	=> 		EX_mem_flag_from_ID,
			EX_wb_register_from_ID_debug =>  	EX_wb_register_from_ID,
			EX_rs_from_ID_debug 			=>  		EX_rs_from_ID,	 
			EX_rt_from_ID_debug 			=>  		EX_rt_from_ID,	 
			EX_WB_stage_data1_debug 	=>  		EX_WB_stage_data1, 
			EX_MEM_stage_data1_debug 	=> 		EX_MEM_stage_data1, 
			EX_wb_flag_to_DM_debug 		=>  		EX_wb_flag_to_DM,
			EX_mem_flag_to_DM_debug 	=>  		EX_mem_flag_to_DM,
			EX_wb_register_to_DM_debug =>    	EX_wb_register_to_DM,
			EX_alu_result_debug 			=>  		EX_alu_result,	 
			EX_long_part_1_debug 		=>  		EX_long_part_1,	 
			EX_long_part_2_debug 		=>  		EX_long_part_2,	 
			EX_branch_jump_debug 		=> 		EX_branch_jump,	
			EX_updated_PC_debug 			=> 		EX_updated_PC,	 
			EX_opcode_to_mem_debug 		=>  		EX_opcode_to_mem, 
			EX_data_to_mem_debug 		=> 		EX_data_to_mem,	 
				--MEM--
		  DM_clock_debug 					=>			DM_clock,		 				
		  DM_WB_flag_from_EX_debug 				=>			DM_WB_flag_from_EX,	 			
		  DM_Mem_flag_from_EX_debug 				=>			DM_Mem_flag_from_EX,	 		
		  DM_opcode_debug 				=>			DM_opcode,	 		
		  DM_writedata_debug 			=>			DM_writedata, 		  
		  DM_ALU_res_from_EX_debug 				=>			DM_ALU_res_from_EX,	 		 
		  DM_WB_reg_from_EX_debug 		=>		 	DM_WB_reg_from_EX,	
		  DM_Mem_flag_to_WB_debug 				=>			DM_Mem_flag_to_WB,	 			
		  DM_WB_flag_to_WB_debug 				=>			DM_WB_flag_to_WB	, 			
		  DM_DM_out_debug 		=>			DM_DM_out	, 
		  DM_ALU_out_to_WB_debug 		=>			DM_ALU_out_to_WB	,
		  DM_WB_reg_to_WB_debug 		=>			DM_WB_reg_to_WB	,

		  DM_ALU_out_to_EX_debug 			=> 	DM_ALU_out_to_EX	 ,	 
		  --WB--
		  WB_Mem_flag_from_DM_debug 				=>			WB_Mem_flag_from_DM, 		 
		  WB_WB_flag_from_DM_debug 				=>			WB_WB_flag_from_DM,		 
		  WB_DM_out_debug 		=>			WB_DM_out, 
		  WB_ALU_out_from_DM_debug 			=>			WB_ALU_out_from_DM,	  
		  WB_WB_register_from_DM_debug 		=>		 	WB_WB_register_from_DM,
		  WB_writedata_debug 			=>			WB_writedata, 	 
		  WB_writeregister_debug 			=>			WB_writeregister, 	
		 
		  --PredictTable
		  PreT_RegWrite_debug 			=> 		PreT_RegWrite,        
		  PreT_IndexRead_debug 			=>  		PreT_IndexRead,
		  PreT_IndexWrite_debug 		=> 		PreT_IndexWrite,
		  PreT_WriteData_debug 			=>  		PreT_WriteData,
		  PreT_ReadData_debug 			=>   		PreT_ReadData,
	     --PredictController,=
		  preC_ReadData_debug 			=> 		preC_ReadData,		
		  preC_PC_current_debug 		=> 		preC_PC_current,	 
		  preC_Index_debug 				=> 		preC_Index,	 		
		  preC_PC_target_debug			=> 		preC_PC_target,	
		  preC_predirection_debug 		=> 	 	preC_predirection, 
		  PreC_enable_Pred_debug		=>			PreC_enable_Pred,
		  preC_Miss_debug 				=> 		preC_Miss,	 		
	     --PredEvalu
		  PreE_Branch_debug 				=>  		PreE_Branch,			
		  PreE_IncrPC_debug 				=>  		PreE_IncrPC,			   
		  PreE_PredInfo_IF_debug 		=>  		PreE_PredInfo_IF,
		  PreE_BranchInfo_virtual_debug =>  	PreE_BranchInfo_virtual,
		  PreE_WriteData_debug 			=>  		PreE_WriteData,		
		  PreE_WriteEnable_debug 		=>  		PreE_WriteEnable,	     
		  PreE_Reset_debug				=>  		PreE_Reset,			    
		  PreE_PredIndexWrite_debug 	=>  		PreE_PredIndexWrite,
			
			
			 reg_1 => reg_1,
		    reg_2 => reg_2,
		    reg_3 => reg_3,
		    reg_4 => reg_4,
		    reg_5 => reg_5,
		    reg_6 => reg_6,
		    reg_7 => reg_7,
		    reg_8 => reg_8,
		    reg_9 => reg_9,
		    reg_10=> reg_10,
		    reg_11=> reg_11,
		    reg_12 => reg_12,
		    reg_13 => reg_13,
		    reg_14 => reg_14,
		    reg_15 => reg_15,
		    reg_16 => reg_16,
		    reg_17 => reg_17,
		    reg_18 => reg_18,
		    reg_19 => reg_19,
		    reg_20 => reg_20,
		    reg_21=> reg_21,
		    reg_22=> reg_22,
		    reg_23 => reg_23,
		    reg_24 => reg_24,
		    reg_25 => reg_25,
		    reg_26 => reg_26,
		    reg_27 => reg_27,
		    reg_28 => reg_28,
		    reg_29 => reg_29,
		    reg_30 => reg_30,
		    reg_31 => reg_31
    		);
      clk_process : process
    	BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    	END PROCESS;

    	test_process : process
    	begin
     --R--******+++++*****+++++*****++++++
        --00000000001000100001100000100000
        --00000000100001010011000000100010

    		wait;
    	END PROCESS;

    END;