LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.numeric_std.ALL;

ENTITY Memory IS
    GENERIC (
        ram_size : INTEGER := 8192 -- There're 8192 lines in the data memory, each 32 bits word.
    );
    PORT (
        clock : IN STD_LOGIC;
        WB_flag_from_EX : IN STD_LOGIC; 
        Mem_flag_from_EX : IN STD_LOGIC; 
        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --opcode for the memory from EX stage.
        writedata : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        ALU_res_from_EX : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU result from EX
        WB_reg_from_EX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

        Mem_flag_to_WB : OUT STD_LOGIC; 
        WB_flag_to_WB : OUT STD_LOGIC;
        DM_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data read from memory
        ALU_out_to_WB : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        WB_reg_to_WB : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        ALU_out_to_EX : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Memory;

ARCHITECTURE arch OF Memory IS

    TYPE MEM IS ARRAY(ram_size - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ramBlocks : MEM;

BEGIN

    ALU_out_to_EX <= ALU_res_from_EX;
    ALU_out_to_WB <= ALU_res_from_EX WHEN Mem_flag_from_EX = '0'; -- if DM stage is not required, pass the data from ALU directly to WB
    WB_flag_to_WB <= WB_flag_from_EX; 
    Mem_flag_to_WB <= Mem_flag_from_EX; 
    WB_reg_to_WB <= WB_reg_from_EX; -- Pass the register to writeback directly.

    init : PROCESS (clock)

        FILE memoryFile : text;
        VARIABLE buf : line;
        VARIABLE address : INTEGER RANGE 0 TO 32767;

    BEGIN
        -- Memory initialization
        IF (now < 1 ps) THEN
            FOR i IN 0 TO ram_size - 1 LOOP
                ramBlocks(i) <= "00000000000000000000000000000000";
            END LOOP;
        END IF;
        IF (clock'event AND clock = '1') THEN
            
            address := to_integer(unsigned(ALU_res_from_EX));

            IF (Mem_flag_from_EX = '1') THEN

                IF (opcode = "10100") THEN -- load word
                    DM_out <= ramBlocks(address/4);

                ELSIF (opcode = "10101") THEN --store word
                    REPORT "WRITING TO ADDRESS" & INTEGER'image(address) & "DATA" & INTEGER'image(to_integer(unsigned(writedata)));
                    ramBlocks(address/4) <= writedata;
                    DM_out <= writedata; 
                END IF;
            END IF;

            -- store ram blocks to the file after each cycle
            file_open(memoryFile, "memory.txt", WRITE_MODE);
            FOR i IN 0 TO ram_size - 1 LOOP
                write(buf, ramBlocks(i));
                writeline(memoryFile, buf);
            END LOOP;
            file_close(memoryFile);

        END IF;
    END PROCESS;

END arch;