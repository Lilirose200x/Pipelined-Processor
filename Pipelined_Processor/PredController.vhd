LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY PredController is 
	PORT (
		clock: 			IN STD_LOGIC; 
		ReadData: 		IN STD_LOGIC_vector(58 downto 0); 
		PC_current: 	IN STD_LOGIC_vector(31 downto 0);
		Index: 			OUT STD_LOGIC_vector(5 downto 0);  
		PC_target: 		OUT STD_LOGIC_vector(31 downto 0); 
		predirection: 	OUT STD_LOGIC;  
		enable_Pred: 	OUT STD_LOGIC;
		Miss: 			OUT STD_LOGIC
		);  
end PredController;


architecture arch of PredController is
begin  
    Index <= PC_current(7 downto 2); 
    process (clock)  
    begin    
	 IF (clock'event AND rising_edge(clock)) THEN
        if ReadData(23 downto 0) = PC_current(31 downto 8) and ReadData(58) >= '1'  then  
				enable_Pred <= '1';
            miss <= '0';
				if ReadData(57 downto 56) >= "10" then
					predirection <= '1';  
					PC_target <= ReadData(55 downto 24);
				else
					predirection <= '0';  
				end if;
        else  --miss
				enable_Pred <= '0';
				miss <= '1' after 3000 ps;  
				predirection <= '0' after 3000 ps; 
        end if;
	 end if;
    end process;  
end arch;
