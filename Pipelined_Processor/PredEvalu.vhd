library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity PredEvalu is 
	port (
		clk : in STD_LOGIC; 
		Branch : in STD_LOGIC;
		IncrPC : in STD_LOGIC_vector(31 downto 0);  
		PredInfo_IF : in STD_LOGIC_vector(60 downto 0); 
		BranchInfo_virtual : in STD_LOGIC_vector(32 downto 0);
		WriteData : out STD_LOGIC_vector(58 downto 0); 
		WriteEnable : out STD_LOGIC;     
		Reset : out STD_LOGIC;     
		PredIndexWrite : out STD_LOGIC_vector(5 downto 0)
	);  
end PredEvalu;

architecture behave of PredEvalu is
  signal PC_current : STD_LOGIC_vector(31 downto 0);
  signal Four : STD_LOGIC_vector(31 downto 0) := X"00000004"; 
  signal Predirection : STD_LOGIC;
	signal ReadTableData : STD_LOGIC_vector(58 downto 0); 
	signal Miss : STD_LOGIC;
	signal Direction_virtual : STD_LOGIC;
	signal Target_virtual : STD_LOGIC_vector(31 downto 0);
	
begin  -- behave
    
	 Direction_virtual <= BranchInfo_virtual(32);
    Miss <= PredInfo_IF(60);
    Predirection <= PredInfo_IF(59);
    ReadTableData <= PredInfo_IF(58 downto 0);
    WriteData(55 downto 24) <= Target_virtual;
    WriteData(23 downto 0) <= PC_current(31 downto 8);
    PC_current <= std_logic_vector(unsigned(IncrPC) - 4);
    PredIndexWrite <= PC_current(7 downto 2);
    
	 Target_virtual <= BranchInfo_virtual(31 downto 0);
    
    process (Predirection, PC_current)  
    begin  -- process 
      -- Hit
		--report"branch is " & STD_LOGIC'image(Branch) &", miss is " & STD_LOGIC'image(Miss) & ", prediction is " & STD_LOGIC'image(Predirection) & ", actual is " & STD_LOGIC'image(BranchInfo_virtual(32));
      if Branch = '1' and Miss = '0' then  --did predict --hit                 
        if Predirection /= BranchInfo_virtual(32) and Predirection = '0' then  -- faultly predict as not taken
			 --report " 1 - 1";
           Reset <= '1'; 
           WriteEnable <= '1';
           WriteData(57 downto 56) <= std_logic_vector(to_unsigned(to_integer(unsigned(ReadTableData(57 downto 56))) + 1, 2));
        elsif Predirection /= BranchInfo_virtual(32) and Predirection = '1' then -- faultly predict as taken
		 -- report " 1 - 2";
           Reset <= '1'; 
           WriteEnable <= '1';
           WriteData(57 downto 56) <= std_logic_vector(to_unsigned(to_integer(unsigned(ReadTableData(57 downto 56))) - 1, 2));
        elsif Predirection = BranchInfo_virtual(32) and Predirection = '1' then -- correctly predict
		  --report " 1 - 3";
           WriteEnable <= '1';
           Reset <= '0';
           WriteData(57 downto 56) <= "11";
        elsif Predirection = BranchInfo_virtual(32) and Predirection = '0' then -- correctly predict
		  --report " 1 - 4" & ", actual1 is " & STD_LOGIC'image(BranchInfo_virtual(32)) & ", Direction_virtual is " & STD_LOGIC'image(Direction_virtual);
           Reset <= '0';
           WriteEnable <= '1';
           WriteData(57 downto 56) <= "00";   
        end if;
      end if;

      --Miss
      if Branch = '1' and Miss = '1' then  -- not do predict  --miss
			--report "In second branch. ";
        if Predirection /= BranchInfo_virtual(32) and BranchInfo_virtual(32) = '1' then  -- faultly predict as notaken, in fact taken 
           Reset <= '1'; 
           WriteEnable <= '1';
           WriteData(58) <= '1';
           WriteData(57 downto 56) <= "10";  -- initial as taken
         elsif Predirection /= BranchInfo_virtual(32) and BranchInfo_virtual(32) = '0' then    -- faultly predict as taken, in fact notaken
           Reset <= '1'; 
           WriteEnable <= '1';
           WriteData(58) <= '1';
           WriteData(57 downto 56) <= "01";  -- initial as not taken
         elsif Predirection = BranchInfo_virtual(32) and BranchInfo_virtual(32) = '0' then --correctly predict as notaken
           Reset <= '0'; 
           WriteEnable <= '1';
           WriteData(58) <= '1';
           WriteData(57 downto 56) <= "01";  -- initial as not taken
         elsif Predirection = BranchInfo_virtual(32) and BranchInfo_virtual(32) = '1' then --correctly predict as notaken
           Reset <= '0'; 
           WriteEnable <= '1';
           WriteData(58) <= '1';  -- initial as taken
           WriteData(57 downto 56) <= "10";  
        end if;
      end if;
      
      if Branch = '0' then
			--report "In third branch. ";
			Reset <= '0';
			WriteEnable <= '0';
      end if;
    end process;
end behave;
