LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY Execution IS
    PORT (
        clock : IN STD_LOGIC;
        instruction : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        opcode : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        current_PC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        rs_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- data1
        rt_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- data2
        mux_select_1 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        mux_select_2 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

        wb_flag_from_ID : IN STD_LOGIC;
        mem_flag_from_ID : IN STD_LOGIC;

        wb_register_from_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        rs_from_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        rt_from_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        WB_stage_data1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        MEM_stage_data1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

        wb_flag_to_DM : OUT STD_LOGIC;
        mem_flag_to_DM : OUT STD_LOGIC;
        wb_register_to_DM : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);

        alu_result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        long_part_1 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        long_part_2 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        branch_jump : OUT STD_LOGIC;
        updated_PC : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        opcode_to_mem : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        data_to_mem : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END Execution;

ARCHITECTURE arch OF Execution IS

    COMPONENT ALU IS
        PORT (
            clock : IN STD_LOGIC;
            oprand_1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            oprand_2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            opcode : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

            long_part_1 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            long_part_2 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)

        );
    END COMPONENT;

    SIGNAL oprand_1 : STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 1 after forwarding
    SIGNAL oprand_2 : STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 2 after forwarding
    SIGNAL offset : STD_LOGIC_VECTOR (15 DOWNTO 0); -- input 2 after forwarding
    SIGNAL alu_out_internal : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN

    opcode_to_mem <= opcode;
    wb_flag_to_DM <= wb_flag_from_ID;
    mem_flag_to_DM <= mem_flag_from_ID;
    wb_register_to_DM <= wb_register_from_ID;
    alu_result <= alu_out_internal;
    offset <= instruction(15 DOWNTO 0);

    --updated_PC <= oprand_1 when(opcode = "11000" or opcode = "11001" or opcode = "11010"); -- go to Fetch oprand1 is target

    --updated_PC <= STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(offset))*4 + to_integer(unsigned(current_PC)), 32))-- not sure
    --when(opcode = "10110" or opcode = "10111"); -- beq, bne

    updated_PC <= STD_LOGIC_VECTOR(to_unsigned((to_integer(unsigned(instruction)) * 4 + to_integer(unsigned(current_PC))), updated_PC'length)) WHEN (opcode = "10111" OR opcode = "10110") ELSE
        oprand_1 WHEN (opcode = "11000" OR opcode = "11001" OR opcode = "11010");

    PROCESS (mux_select_1, mux_select_2, opcode, clock)
    BEGIN
        IF (mux_select_1 = "00") THEN --no forwarding for input 1
            oprand_1 <= rs_data;
        ELSIF (mux_select_1 = "01") THEN -- obtain data from WB
            oprand_1 <= WB_stage_data1;
        ELSIF (mux_select_1 = "10") THEN -- obtain data from MEM
            oprand_1 <= MEM_stage_data1;
        ELSE
            oprand_1 <= rs_data;
        END IF;

        IF (mux_select_2 = "00") THEN --no forwarding for input 2
            IF (opcode = "10101") THEN
                oprand_2 <= instruction;
                data_to_mem <= rt_data;
            ELSE
                oprand_2 <= rt_data;
            END IF;
        ELSIF (mux_select_2 = "01") THEN -- obtain data from WB
            oprand_2 <= WB_stage_data1;
        ELSIF (mux_select_2 = "10") THEN -- obtain data from MEM
            oprand_2 <= MEM_stage_data1;
        ELSE
            oprand_2 <= rt_data;
        END IF;
        IF (opcode = "10110") THEN --beq
            IF (oprand_1 = oprand_2) THEN
                branch_jump <= '1';
            ELSE

                branch_jump <= '0';
            END IF;
        ELSIF (opcode = "10111") THEN --bne
            IF (oprand_1 /= oprand_2) THEN
                branch_jump <= '1';
            ELSE
                branch_jump <= '0';
            END IF;
        ELSE
            branch_jump <= '0';
        END IF;

    END PROCESS;
    aluInstance : ALU PORT MAP(clock, oprand_1, oprand_2, opcode, long_part_1, long_part_2, alu_out_internal);
END arch;