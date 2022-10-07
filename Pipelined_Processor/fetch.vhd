library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY Fetch IS

    PORT (
        clock : IN STD_LOGIC;
        branch_target : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_flag : IN STD_LOGIC;
        branch_taken : IN STD_LOGIC;
        load_flag : IN STD_LOGIC;
		  	predict_enable:			in std_logic;
			branch_predict:			in std_logic_vector(31 downto 0);
        next_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        fetch : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

END Fetch;

ARCHITECTURE arch OF Fetch IS

    COMPONENT Instruction_Memory IS
        GENERIC (
            ram_size : INTEGER := 32768
        );
        PORT (
            clock : IN STD_LOGIC;
            address : IN INTEGER RANGE 0 TO ram_size - 1;
            readdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL address : INTEGER RANGE 0 TO 32768 - 1; -- address to load the instruction from instr mem.
    SIGNAL readdata : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- initialize PC to 0
    SIGNAL pc_value : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";

    -- need to initialize the instruction to avoid the "UUUU" issue, this is to be mapped to the output port of instruction memory
    SIGNAL read_out : STD_LOGIC_VECTOR(31 DOWNTO 0) := "11111111111111111111111111111111";

    SIGNAL fetch_result : STD_LOGIC_VECTOR(31 DOWNTO 0); --use this to store fetched from instruction memory/

BEGIN
    next_pc <= pc_value;
    address <= to_integer(unsigned(pc_value)) WHEN (branch_taken = '0') ELSE
        to_integer(unsigned(branch_target)); -- if receive from EX stage saying branch is taken, update the address to the target PC.

    PC : PROCESS (clock)
        VARIABLE stall_counter : INTEGER := 0; --use this to count bubble instructions inserted.
    BEGIN
        IF (clock'event AND rising_edge(clock)) THEN

            IF ((branch_flag = '0') AND (load_flag = '0') AND (stall_counter = 0)) THEN --no branch, no load or branch stall.

                fetch_result <= read_out; -- sending the instruction fetched from the instr_mem here

                IF (branch_taken = '0') THEN
                    pc_value <= STD_LOGIC_VECTOR(unsigned(pc_value) + 4); --update the PC if branch taken, or not.
                ELSE
                    pc_value <= STD_LOGIC_VECTOR(unsigned(branch_target) + 4);
                END IF;
            ELSE --a stall or load is detected.
                IF (stall_counter = 0) THEN
                    IF (load_flag = '1') THEN --If the command is to load, stall 3 cycles N.B: here we tested using 3 and 2 will cause to stall actually 4 and 3 cycles, probably due to latency issue.
                        stall_counter := 2;
                    ELSIF (branch_flag = '1') THEN --If it is a branch jump, stall 2 cycles.
                        stall_counter := 1;
                    END IF;

                END IF;
                fetch_result <= "00000000000000000000000000100000"; -- when stalling, load bubble instruction.
                stall_counter := stall_counter - 1; --decrement the stall counter
                IF (stall_counter = 0) THEN
                    pc_value <= STD_LOGIC_VECTOR(unsigned(pc_value) - 4); -- when counter reaches 0 we need to subtract 4 to balance off the increased 4 in the previous if statement block.
                END IF;
            END IF;
        END IF;
    END PROCESS;

    fetch <= fetch_result WHEN ((branch_flag = '0') AND (load_flag = '0')) ELSE
        "00000000000000000000000000100000";

    InstrMem : Instruction_Memory
    PORT MAP(
        clock => clock,
        address => address,
        readdata => read_out
    );
END arch;