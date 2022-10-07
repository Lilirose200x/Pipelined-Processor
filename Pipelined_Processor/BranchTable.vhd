LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BranchTable is 
	PORT (
		clock: 			IN STD_LOGIC;
		RegWrite: 		IN STD_LOGIC;        
		IndexRead:  	IN STD_LOGIC_vector(5 downto 0);  
		IndexWrite: 	IN STD_LOGIC_vector(5 downto 0); 
		WriteData:  	IN STD_LOGIC_vector(58 downto 0); 
		ReadData:   	OUT STD_LOGIC_vector(58 downto 0)); 
END BranchTable;

architecture arch of BranchTable is
    signal 	intRR,intWR: integer;           
    type 	rowType is array (0 to 63) of STD_LOGIC_vector(58 downto 0);
    signal 	table : rowType;
begin  
    intRR <= to_integer(signed(IndexRead));   
    intWR <= to_integer(signed(IndexWrite));
    ReadData <= table(to_integer(unsigned(IndexRead)));   
    process (clock)
    begin
	 if clock = '0' and RegWrite = '1' then
	    table(intWR) <= WriteData;
	 end if;
    end process;
end arch;