LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY ALU IS
    PORT (
		clock: IN STD_LOGIC;
		oprand_1: IN STD_LOGIC_VECTOR (31 DOWNTO 0);--target
		oprand_2: IN STD_LOGIC_VECTOR (31 DOWNTO 0);--source
		opcode: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		
		long_part_1 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		long_part_2 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)


	);
END ALU;

architecture alu_behavior of ALU is

	signal hi_s, lo_s:		std_logic_vector(31 downto 0);
	signal int_64:			std_logic_vector(63 downto 0):= "0000000000000000000000000000000000000000000000000000000000000000"; 

begin

long_part_1 <= int_64(63 downto 32);--high
long_part_2 <= int_64(31 downto 0); --low

process(oprand_1,oprand_2,opcode,clock)
variable shiftN: integer;
begin
case(opcode) is 
	when"00000" => --add
		result <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) + to_integer(signed(oprand_2)), 32));
	when"00001" => --sub
		result <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) - to_integer(signed(oprand_2)), 32));
	when"00010" => --addi
		result <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) + to_integer(signed(oprand_2)), 32));
	when"00011" => --mul
		result <= "00000000000000000000000000000000";
		int_64 <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) * to_integer(signed(oprand_2)), 64));
	when"00100" => --div
		result <= "00000000000000000000000000000000";
		long_part_1<= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) / to_integer(signed(oprand_2)), 32));
		long_part_1<= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) mod to_integer(signed(oprand_2)), 32));
	when"00101" => --slt 
		if(signed(oprand_1) < signed(oprand_2)) then
			result <= "00000000000000000000000000000001";
		else
			result <= "00000000000000000000000000000000";
		end if;
	when"00110" => --slti note: rt=rs<imm
		if(signed(oprand_1) < signed(oprand_2)) then
			result <= "00000000000000000000000000000001";
		else
			result <= "00000000000000000000000000000000";
		end if;
	when"00111" => --and
		result <= oprand_1 and oprand_2;
	when"01000" => --or
		result <= oprand_1 or oprand_2;
	when"01001" => --nor
		result <= oprand_1 nor oprand_2;
	when"01010" => --xor
		result <= oprand_1 xor oprand_2;
	when"01011" => --andi
		result <= oprand_1 and oprand_2;
	when"01100" => --ori
		result <= oprand_1 or oprand_2;
	when"01101" => --xori
		result <= oprand_1 xor oprand_2;
		
	when"01110" => --mfhi
		result <= int_64(63 DOWNTO 32);
	when"01111" => --mflo
		result <= int_64(31 DOWNTO 0);
	when"10000" => --lui note:	rt=imm<<16
		result <= oprand_2(15 downto 0) & "0000000000000000";	
	when"10001" => --sll
		shiftN := to_integer(unsigned(oprand_2));
		result <= oprand_1((31-shiftN) downto 0) & STD_LOGIC_VECTOR(to_unsigned(0, shiftN));	
	when"10010" => --srl
		shiftN := to_integer(unsigned(oprand_2));
		result <= STD_LOGIC_VECTOR(to_unsigned(0, shiftN)) & oprand_1(31 downto shiftN);	
	when"10011" => --sra
		shiftN := to_integer(unsigned(oprand_2));
		if(oprand_1(31) = '1') then --negative
			result <= STD_LOGIC_VECTOR(to_unsigned(1, shiftN)) & oprand_1(31 downto shiftN);	
		else
			result <= STD_LOGIC_VECTOR(to_unsigned(0, shiftN)) & oprand_1(31 downto shiftN);	
		end if;
	when"10100" => --lw
		result <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) + to_integer(signed(oprand_2)), 32));  -- offset + Rs
	when"10101" => --sw
		result <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(oprand_1)) + to_integer(signed(oprand_2)), 32));	-- offset + Rs
	when"10110" => --beq
		result <= "00000000000000000000000000000000";
	when"10111" => --ben
		result <= "00000000000000000000000000000000";
	when"11000" => --jump
		result <= STD_LOGIC_VECTOR(oprand_1);
	when"11001" => --jump register
		result <= STD_LOGIC_VECTOR(oprand_1);
	when"11010" => --jump and link
		result <= STD_LOGIC_VECTOR(oprand_1);
	when others =>
		result <= x"00000000";
		

end case;
end process;

end alu_behavior ; -- alu_behavior
