LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY WriteBack IS
    PORT (
        clock : IN STD_LOGIC;
        Mem_flag_from_DM : IN STD_LOGIC; -- input of multiplexer, data memory access flag
        WB_flag_from_DM : IN STD_LOGIC; -- writeback flag;
        DM_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- data loaded from data memory
        ALU_out_from_DM : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- actually it should be the data from ALU, wrong name
        WB_register_from_DM : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

        writedata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        writeregister : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END WriteBack;

ARCHITECTURE arch OF WriteBack IS
BEGIN
    WITH WB_flag_from_DM SELECT
        writeregister <= WB_register_from_DM WHEN '1',
        "00000" WHEN OTHERS;
    -- We pick the register to writeback according to the WB flag. If it is '0' then we pass "00000" to ID so that it don't write any register.

    writedata <= DM_out WHEN (WB_flag_from_DM = '1' AND Mem_flag_from_DM = '1')
        ELSE
        ALU_out_from_DM WHEN (WB_flag_from_DM = '1' AND Mem_flag_from_DM = '0') ELSE
        "00000000000000000000000000000000"; -- If WB flag is '1' and memory is accessed, the write back data is the data read from memory. If the memory is not read, then writeback the 
    --data from ALU result. Otherwise if the Writeback flag is '0' then send "00000000000000000000000000000000" 

END arch;