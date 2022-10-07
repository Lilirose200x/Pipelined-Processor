library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Instruction_Memory is

        -- copy from memory.vhd
        generic(
            ram_size :      INTEGER := 8192 --8192 lines of 32 bit lines
        );

        port(
            clock:          IN STD_LOGIC;
		    address:        IN INTEGER RANGE 0 TO ram_size-1; --We don't need a read/write flag cuz the instruction memory can only always load instructions. 
		    readdata:       OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
end Instruction_Memory;


architecture arch of Instruction_Memory is

    --Memory has 32768 entries of 32 bit lines (word)
    TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL actualaddress: INTEGER RANGE 0 to ram_size-1; 

begin

    mem_process: process(clock)

	file program_file: 		text;
	variable row:			line; --buffer
	variable row_data:		std_logic_vector(31 downto 0); --actual 32bits to be read
	variable row_counter:	integer := 0; --use to keep track where we are at in the program.txt

    begin 

    	if(now < 1 ps) then  --initialize the instruction memory by reading from program.txt
		    file_open(program_file,"program.txt",READ_MODE);

			while(not endfile(program_file)) loop
				readline(program_file, row);  
				read(row,row_data);           
				ram_block(row_counter) <= row_data;
                row_counter := row_counter + 1;
			end loop;
		end if;
		file_close(program_file);
    end process;
    
    actualaddress <= address/4; -- The address is in bits, so we need to divide 4 to get the line address.
    readdata <= ram_block(actualaddress);  


end arch;