library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Pipeline is

    port(
			clk:				in std_logic;
			--- debug protocal
			--fetch--
			IF_branch_target_debug: 			out STD_logic_vector(31 downto 0);
			IF_branch_flag_debug:	 			out STD_logic;
			IF_branch_taken_debug:  			out STD_logic:='0';
			IF_load_flag_debug: 					out STD_logic;
			IF_predict_enable_debug:			out std_logic:='0';
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
		   DM_WB_flag_from_EX_debug:				 	out STD_logic;	-- write back flag, will be directly passed to WB_flag_to_WB
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
end Pipeline;

architecture structure of Pipeline is 

--branch prediction purposes
	 signal Check_pred:	 std_logic;

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
	 signal DM_WB_flag_from_EX:				 std_logic;	-- write back flag, will be directly passed to WB_flag_to_WB
	 signal DM_Mem_flag_from_EX:				 std_logic;	-- data memory access flag,                                      -- '0' refers to access Data Mem, '1' refers to pass through
	 signal DM_opcode:					 std_logic_vector(4 downto 0); -- opcode of the instruction, sent by the execution stage
	 signal DM_writedata:				 std_logic_vector(31 downto 0); -- data to write to the data memory
	 signal DM_ALU_res_from_EX:				 std_logic_vector(31 downto 0); -- ALU output
	 signal DM_WB_reg_from_EX:			 std_logic_vector(4 downto 0);
	 signal DM_Mem_flag_to_WB:				 std_logic;	-- memory access flag
	 signal DM_WB_flag_to_WB:				 std_logic;	-- writeback flag
	 signal DM_DM_out:			 std_logic_vector(31 downto 0); -- data that is loaded from data memory
	 signal DM_ALU_out_to_WB:			 std_logic_vector(31 downto 0); -- actually it should be the data output from ALU, which is directly passed to the Writeback stage, wrong name
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
	 signal preC_Index: 			STD_LOGIC_vector(5 downto 0);  -- index to look up BTB
	 signal preC_PC_target: 	STD_LOGIC_vector(31 downto 0); --Target address
	 signal preC_predirection: STD_LOGIC;  --predicted direction: taken(1) or not taken(0)
	 signal PreC_enable_Pred: 	STD_LOGIC;
	 signal preC_Miss: 			STD_LOGIC;
--PredEvalu
	 signal PreE_Branch :  STD_LOGIC;
	 signal PreE_IncrPC :  STD_LOGIC_vector(31 downto 0);  -- write into updating table
	 signal PreE_PredInfo_IF :  STD_LOGIC_vector(60 downto 0); --data form IF phase about prediction
	 signal PreE_BranchInfo_virtual :  STD_LOGIC_vector(32 downto 0);
	 signal PreE_WriteData :  STD_LOGIC_vector(58 downto 0); --write data used to update predict table
	 signal PreE_WriteEnable :  STD_LOGIC;     --enable signal to update predict table
	 signal PreE_Reset :  STD_LOGIC;      -- to reset fetched instruction for faultly predicting
	 signal PreE_PredIndexWrite :  STD_LOGIC_vector(5 downto 0);
	 

component Fetch is 
port(
	clock:						in std_logic;
	branch_target:			in std_logic_vector(31 downto 0);
	branch_flag:					in std_logic;
	branch_taken:				in std_logic;
   load_flag: 					in std_logic;
	predict_enable:			in std_logic;
	branch_predict:			in std_logic_vector(31 downto 0);
	next_pc:					out std_logic_vector(31 downto 0);
	fetch:					out std_logic_vector(31 downto 0)
);
end component;

component Decode is 
port (
clock: IN STD_LOGIC;
    instruction: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    current_PC: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    wb_register: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    wb_register_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    HI_data, LO_data : in std_logic_vector(31 downto 0);
    read_data_1: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    read_data_2: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    ALU : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
    sign_extend: OUT STD_LOGIC_VECTOR(31 downto 0); -- sign extend or zero extend
    wb_flag: OUT STD_LOGIC;
    mem_access_flag: OUT STD_LOGIC;
    br_and_j_flag: OUT STD_LOGIC;
    load_flag: OUT STD_LOGIC;
    wb_register_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
    current_PC_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    rs_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
    rt_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);

    reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
	 reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
	 reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
	 reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)
);

end component;

component Execution is 
port (
    clock: IN STD_LOGIC;
		instruction: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		opcode: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		current_PC: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rs_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);  -- data1
		rt_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);	-- data2
		mux_select_1: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_select_2: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      wb_flag_from_ID: IN STD_LOGIC;
      mem_flag_from_ID: IN STD_LOGIC;
      wb_register_from_ID: IN STD_LOGIC_VECTOR (4 downto 0);
      rs_from_ID: IN STD_LOGIC_VECTOR (4 downto 0);
      rt_from_ID: IN STD_LOGIC_VECTOR (4 downto 0);
		WB_stage_data1: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		MEM_stage_data1: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      wb_flag_to_DM: OUT STD_LOGIC;
      mem_flag_to_DM: OUT STD_LOGIC;
      wb_register_to_DM: OUT STD_LOGIC_VECTOR (4 downto 0);
		alu_result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		long_part_1 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		long_part_2 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		branch_jump : OUT STD_LOGIC;
		updated_PC: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		opcode_to_mem: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      data_to_mem: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
end component;

component Memory is 
port (
		clock:					in std_logic;		
		WB_flag_from_EX:				in std_logic;	-- write back flag, will be directly passed to WB_flag_to_WB
		Mem_flag_from_EX:				in std_logic;	-- data memory access flag, 									-- '0' refers to access Data Mem, '1' refers to pass through
		opcode:					in std_logic_vector(4 downto 0); -- opcode of the instruction, sent by the execution stage
		writedata:				in std_logic_vector(31 downto 0); -- data to write to the data memory
		ALU_res_from_EX:				in std_logic_vector(31 downto 0); -- ALU output
		WB_reg_from_EX:			in std_logic_vector(4 downto 0);
		Mem_flag_to_WB:				out std_logic;	-- memory access flag
		WB_flag_to_WB:				out std_logic;	-- writeback flag
		DM_out:			out std_logic_vector(31 downto 0); -- data that is loaded from data memory
		ALU_out_to_WB:			out std_logic_vector(31 downto 0); -- actually it should be the data output from ALU, which is directly passed to the Writeback stage, wrong name
		WB_reg_to_WB:			out std_logic_vector(4 downto 0);
		ALU_out_to_EX: 			out std_logic_vector(31 downto 0)
);
end component; 

component Writeback is 
port (
      clock:				in std_logic;
		Mem_flag_from_DM:			in std_logic; -- input of multiplexer, data memory access flag
		WB_flag_from_DM:			in std_logic; -- writeback flag;
		DM_out:		in std_logic_vector(31 downto 0); -- data loaded from data memory
		ALU_out_from_DM:		in std_logic_vector(31 downto 0); -- actually it should be the data from ALU, wrong name
		WB_register_from_DM:		in std_logic_vector(4 downto 0);
		writedata:			out std_logic_vector(31 downto 0);
		writeregister:			out std_logic_vector(4 downto 0)
);
end component;


component BranchTable is 
PORT (
		clock: 			IN STD_LOGIC;
		RegWrite: 		IN STD_LOGIC;        
		IndexRead:  	IN STD_LOGIC_vector(5 downto 0);  
		IndexWrite: 	IN STD_LOGIC_vector(5 downto 0); 
		WriteData:  	IN STD_LOGIC_vector(58 downto 0);
		ReadData:   	OUT STD_LOGIC_vector(58 downto 0)
); 
END component;

component PredController is 
PORT (
		clock: 			IN STD_LOGIC; --regrite, the port used to triger to update predictor
		ReadData: 		IN STD_LOGIC_vector(58 downto 0); --From BTB
		PC_current: 	IN STD_LOGIC_vector(31 downto 0);
		Index: 			OUT STD_LOGIC_vector(5 downto 0);  -- index to look up BTB
		PC_target: 		OUT STD_LOGIC_vector(31 downto 0); --Target address
		predirection: 	OUT STD_LOGIC;  --predicted direction: taken(1) or not taken(0)
		enable_Pred: 	OUT STD_LOGIC;
		Miss: 			OUT STD_LOGIC
);
end component;

component PredEvalu is 
	port (
		clk : in STD_LOGIC; 
		Branch : in STD_LOGIC;
		IncrPC : in STD_LOGIC_vector(31 downto 0);  -- write into updating table
		PredInfo_IF : in STD_LOGIC_vector(60 downto 0); --data form IF phase about prediction
		BranchInfo_virtual : in STD_LOGIC_vector(32 downto 0);
		WriteData : out STD_LOGIC_vector(58 downto 0); --write data used to update predict table
		WriteEnable : out STD_LOGIC;     --enable signal to update predict table
		Reset : out STD_LOGIC;      -- to reset fetched instruction for faultly predicting
		PredIndexWrite : out STD_LOGIC_vector(5 downto 0)
	);  
end component;

begin 
Stage_IF: Fetch port map(
    clock => clk, branch_target => IF_branch_target,
    branch_flag => IF_branch_flag,
    branch_taken => IF_branch_taken, 
    load_flag => IF_load_flag,
	 predict_enable => IF_predict_enable,
	 branch_predict => IF_branch_predict,
    next_pc => IF_next_pc,
    fetch => IF_fetch
);

Stage_ID: Decode port map(
    clk, ID_instruction, ID_current_PC, ID_wb_register, ID_wb_register_data,  ID_HI_data, ID_LO_data,ID_read_data_1, ID_read_data_2, ID_ALU, ID_sign_extend, ID_wb_flag,
    ID_mem_access_flag, ID_br_and_j_flag, ID_load_flag, ID_wb_register_out, ID_current_PC_out,
    ID_rs_out, ID_rt_out, reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8,
    reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17,
    reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26,
    reg_27, reg_28, reg_29, reg_30, reg_31

);

Stage_EX: Execution port map(
    clk, EX_instruction, EX_opcode, EX_current_PC, EX_rs_data, EX_rt_data, EX_mux_select_1, EX_mux_select_2,
    EX_wb_flag_from_ID, EX_mem_flag_from_ID, EX_wb_register_from_ID, EX_rs_from_ID, EX_rt_from_ID,
    EX_WB_stage_data1, EX_MEM_stage_data1, EX_wb_flag_to_DM, EX_mem_flag_to_DM, EX_wb_register_to_DM,
    EX_alu_result, EX_long_part_1, EX_long_part_2, EX_branch_jump, EX_updated_PC, EX_opcode_to_mem, EX_data_to_mem

);

Stage_DM: Memory port map(
    clock => clk,
	 WB_flag_from_EX => DM_WB_flag_from_EX,
	 Mem_flag_from_EX => DM_Mem_flag_from_EX,
	 opcode => DM_opcode,
	 writedata => DM_writedata,
	 ALU_res_from_EX => DM_ALU_res_from_EX,
	 WB_reg_from_EX => DM_WB_reg_from_EX,
	 Mem_flag_to_WB => DM_Mem_flag_to_WB,
	 WB_flag_to_WB => DM_WB_flag_to_WB,
	 DM_out => DM_DM_out,
	 ALU_out_to_WB => DM_ALU_out_to_WB,
	 WB_reg_to_WB => DM_WB_reg_to_WB

);

Stage_WB: Writeback port map(
    clk, WB_Mem_flag_from_DM, WB_WB_flag_from_DM, WB_DM_out, WB_ALU_out_from_DM, WB_WB_register_from_DM,WB_writedata, WB_writeregister

);

Predict_TB: BranchTable port map(
		clock => clk,
		RegWrite => PreT_RegWrite,  
		IndexRead => PreT_IndexRead,
		IndexWrite => PreT_IndexWrite,
		WriteData => PreT_WriteData,
		ReadData  => PreT_ReadData
);

Predict_Control: PredController port map(
		clock => clk,
		ReadData => PreC_ReadData,
		PC_current => PreC_PC_current,
		Index => PreC_Index,	
		PC_target => PreC_PC_target, 		 
		predirection => PreC_predirection,	
		enable_Pred => PreC_enable_Pred,
		Miss => PreC_Miss	
);

Predict_Evalue: PredEvalu port map(
		clk => clk,
		Branch => preE_Branch,
		IncrPC  => preE_IncrPC,
		PredInfo_IF => preE_PredInfo_IF, 
		BranchInfo_virtual  => preE_BranchInfo_virtual,
		WriteData  => preE_WriteData,
		WriteEnable => preE_WriteEnable,
		Reset  => PreE_Reset,
		PredIndexWrite => preE_PredIndexWrite	
);

--actual pipeline--
process(clk)
begin
	if (rising_edge(clk)) then
		  WB_Mem_flag_from_DM <= DM_Mem_flag_to_WB;
		  WB_WB_flag_from_DM <= DM_WB_flag_to_WB;
		  WB_DM_out <= DM_DM_out;
		  WB_ALU_out_from_DM <= DM_ALU_out_to_WB;
		  WB_WB_register_from_DM <= DM_WB_reg_to_WB;


		  DM_WB_flag_from_EX <= EX_wb_flag_to_DM;
		  DM_Mem_flag_from_EX <= EX_mem_flag_to_DM;
		  DM_opcode <= EX_opcode_to_mem; 
		  DM_writedata <= EX_data_to_mem;
		  DM_ALU_res_from_EX <= EX_alu_result;
		  DM_WB_reg_from_EX <= EX_wb_register_to_DM;

		  EX_current_PC <= ID_current_PC_out;
		  EX_opcode <= ID_ALU;
		  EX_instruction <= ID_sign_extend;
		  EX_rs_data <= ID_read_data_1;
		  EX_rt_data <= ID_read_data_2;
		  EX_wb_register_from_ID <= ID_wb_register_out;
		  EX_rs_from_ID <= ID_rs_out;
		  EX_rt_from_ID <= ID_rt_out;
		  EX_mem_flag_from_ID <= ID_mem_access_flag;
		  EX_wb_flag_from_ID <= ID_wb_flag;

		  ID_instruction <= IF_fetch;
		  ID_current_PC <= IF_next_pc;
		  
    end if;
	
end process;

    IF_branch_flag <= ID_br_and_j_flag;
    IF_load_flag <= ID_load_flag;
    IF_branch_taken <= EX_branch_jump;
	 IF_branch_target <= EX_updated_PC;
	 IF_predict_enable <= 	PreC_enable_Pred;
	 IF_branch_predict <= PreC_PC_target;
	 
    ID_wb_register_data <= WB_writedata;
    ID_wb_register <= WB_writeregister;
    ID_HI_data <= EX_long_part_1;
    ID_LO_data <= EX_long_part_2;
    
    EX_WB_stage_data1 <= WB_writedata;
    EX_MEM_stage_data1 <= DM_ALU_res_from_EX;
    
	 
	 --below is for prediction
	 PreT_RegWrite <= preE_WriteEnable;
	 PreT_IndexRead <= IF_next_pc(7 downto 2);
	 PreT_IndexWrite <= preE_PredIndexWrite;
	 PreT_WriteData <= preE_WriteData;
	 
	 
	 PreC_ReadData <= PreT_ReadData;
	 PreC_PC_current <= IF_next_pc;
	 
	 preE_Branch <= IF_branch_taken;
	 preE_IncrPC <= IF_next_pc;
	 preE_BranchInfo_virtual <= IF_branch_taken & EX_updated_PC;
	 
	 preE_PredInfo_IF(60 downto 59) <= prec_Miss & preC_predirection;
	 preE_PredInfo_IF(58 downto 0) <= PreT_ReadData when (PreT_ReadData(55) = '0');
	 
	 
	 --above is for prediction

    -- MUXs for forwarding to EX--
    EX_mux_select_1 <= "10" when (DM_WB_flag_from_EX = '1' and DM_WB_reg_from_EX /= "00000" and DM_WB_reg_from_EX = EX_rs_from_ID) 
    else "01" when (WB_WB_flag_from_DM = '1' and WB_WB_register_from_DM /= "00000" and DM_WB_reg_from_EX /= EX_rs_from_ID and WB_WB_register_from_DM = EX_rs_from_ID)
    else "00";

    EX_mux_select_2 <= "10" when (DM_WB_flag_from_EX = '1' and DM_WB_reg_from_EX /= "00000" and DM_WB_reg_from_EX = EX_rt_from_ID) 
    else "01" when (WB_WB_flag_from_DM = '1' and WB_WB_register_from_DM /= "00000" and DM_WB_reg_from_EX /= EX_rt_from_ID and WB_WB_register_from_DM = EX_rt_from_ID)
    else "00";


	 
	 
	-- signals for debug --
	 		IF_branch_target_debug 		<= 		IF_branch_target;
			IF_branch_flag_debug 		<=			IF_branch_flag;
			IF_branch_taken_debug 		<=  		IF_branch_taken;
			IF_load_flag_debug 			<= 		IF_load_flag;
			IF_predict_enable_debug 	<= 		IF_predict_enable;
	      IF_branch_predict_debug		<= 		IF_branch_predict;
			IF_next_pc_debug 				<= 		IF_next_pc;	 
			IF_fetch_debug 				<= 		IF_fetch;			 
			--decode--
			ID_instruction_debug 		<= 		ID_instruction; 		 
			ID_current_PC_debug 			<=  		ID_current_PC; 
			ID_wb_register_debug 		<=  		ID_wb_register; 
			ID_wb_register_data_debug 	<=  		ID_wb_register_data;
			ID_read_data_1_debug 		<=  		ID_read_data_1; 
			ID_read_data_2_debug 		<=  		ID_read_data_2;
			ID_ALU_debug 					<=  		ID_ALU;	 
			ID_sign_extend_debug 		<=  		ID_sign_extend;
			ID_wb_flag_debug 				<=  		ID_wb_flag;
			ID_mem_access_flag_debug 	<=  		ID_mem_access_flag;
			ID_br_and_j_flag_debug 		<=  		ID_br_and_j_flag;
			ID_load_flag_debug 			<=  		ID_load_flag;
			ID_wb_register_out_debug 	<=   		ID_wb_register_out;
			ID_current_PC_out_debug 	<=    	ID_current_PC_out;
			ID_rs_out_debug 				<=  		ID_rs_out; 
			ID_rt_out_debug 				<=  		ID_rt_out; 
			ID_HI_data_debug 				<= 		ID_HI_data;
			ID_LO_data_debug 				<= 		ID_LO_data; 
			--execution--
			EX_instruction_debug 		<=  		EX_instruction;			 
			EX_opcode_debug 				<=  		EX_opcode;		 
			EX_current_PC_debug 			<=  		EX_current_PC;	 
			EX_rs_data_debug 				<=  		EX_rs_data;		   
			EX_rt_data_debug 				<=  		EX_rt_data;		 	
			EX_mux_select_1_debug 		<=  		EX_mux_select_1; 
			EX_mux_select_2_debug 		<=  		EX_mux_select_2; 
			EX_wb_flag_from_ID_debug 	<=  		EX_wb_flag_from_ID;
			EX_mem_flag_from_ID_debug 	<= 		EX_mem_flag_from_ID;
			EX_wb_register_from_ID_debug <=  	EX_wb_register_from_ID;
			EX_rs_from_ID_debug 			<=  		EX_rs_from_ID;	 
			EX_rt_from_ID_debug 			<=  		EX_rt_from_ID;	 
			EX_WB_stage_data1_debug 	<=  		EX_WB_stage_data1; 
			EX_MEM_stage_data1_debug 	<= 		EX_MEM_stage_data1; 
			EX_wb_flag_to_DM_debug 		<=  		EX_wb_flag_to_DM;
			EX_mem_flag_to_DM_debug 	<=  		EX_mem_flag_to_DM;
			EX_wb_register_to_DM_debug <=    	EX_wb_register_to_DM;
			EX_alu_result_debug 			<=  		EX_alu_result;	 
			EX_long_part_1_debug 		<=  		EX_long_part_1;	 
			EX_long_part_2_debug 		<=  		EX_long_part_2;	 
			EX_branch_jump_debug 		<= 		EX_branch_jump;	
			EX_updated_PC_debug 			<= 		EX_updated_PC;	 
			EX_opcode_to_mem_debug 		<=  		EX_opcode_to_mem; 
			EX_data_to_mem_debug 		<= 		EX_data_to_mem;	 
				--MEM--
		  DM_clock_debug 					<=			DM_clock;		 				
		  DM_WB_flag_from_EX_debug 				<=			DM_WB_flag_from_EX;	 			
		  DM_Mem_flag_from_EX_debug 				<=			DM_Mem_flag_from_EX;	 		
		  DM_opcode_debug 				<=			DM_opcode;	 		
		  DM_writedata_debug 			<=			DM_writedata; 		  
		  DM_ALU_res_from_EX_debug 				<=			DM_ALU_res_from_EX;	 		 
		  DM_WB_reg_from_EX_debug 		<=		 	DM_WB_reg_from_EX;	
		  DM_Mem_flag_to_WB_debug 				<=			DM_Mem_flag_to_WB;	 			
		  DM_WB_flag_to_WB_debug 				<=			DM_WB_flag_to_WB	; 			
		  DM_DM_out_debug 		<=			DM_DM_out	; 
		  DM_ALU_out_to_WB_debug 		<=			DM_ALU_out_to_WB	;
		  DM_WB_reg_to_WB_debug 		<=			DM_WB_reg_to_WB	;
		  DM_ALU_out_to_EX_debug 			<= 	DM_ALU_out_to_EX	 ;	 
		  --WB--
		  WB_Mem_flag_from_DM_debug 				<=			WB_Mem_flag_from_DM; 		 
		  WB_WB_flag_from_DM_debug 				<=			WB_WB_flag_from_DM;		 
		  WB_DM_out_debug 		<=			WB_DM_out; 
		  WB_ALU_out_from_DM_debug 			<=			WB_ALU_out_from_DM;	  
		  WB_WB_register_from_DM_debug 		<=		 	WB_WB_register_from_DM;
		  WB_writedata_debug 			<=			WB_writedata; 	 
		  WB_writeregister_debug 			<=			WB_writeregister; 	
		 
		  --PredictTable
		  PreT_RegWrite_debug 			<= 		PreT_RegWrite;        
		  PreT_IndexRead_debug 			<=  		PreT_IndexRead;
		  PreT_IndexWrite_debug 		<= 		PreT_IndexWrite;
		  PreT_WriteData_debug 			<=  		PreT_WriteData;
		  PreT_ReadData_debug 			<=   		PreT_ReadData;
	     --PredictController;=
		  preC_ReadData_debug 			<= 		preC_ReadData;		
		  preC_PC_current_debug 		<= 		preC_PC_current;	 
		  preC_Index_debug 				<= 		preC_Index;	 		
		  preC_PC_target_debug			<= 		preC_PC_target;	
		  preC_predirection_debug 		<= 	 	preC_predirection; 
		  PreC_enable_Pred_debug		<= 		PreC_enable_Pred;
		  preC_Miss_debug 				<= 		preC_Miss;	 		
	     --PredEvalu
		  PreE_Branch_debug 				<=  		PreE_Branch;			
		  PreE_IncrPC_debug 				<=  		PreE_IncrPC;			   
		  PreE_PredInfo_IF_debug 		<=  		PreE_PredInfo_IF;
		  PreE_BranchInfo_virtual_debug <=  	PreE_BranchInfo_virtual;
		  PreE_WriteData_debug 			<=  		PreE_WriteData;		
		  PreE_WriteEnable_debug 		<=  		PreE_WriteEnable;	     
		  PreE_Reset_debug				<=  		PreE_Reset;			    
		  PreE_PredIndexWrite_debug 	<=  		PreE_PredIndexWrite;
	 
	 
	 
	 
	 
	 
	 
	 
	 
end structure;