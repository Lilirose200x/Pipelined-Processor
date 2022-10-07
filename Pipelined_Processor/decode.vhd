LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY decode IS
    PORT (
        clock : IN STD_LOGIC;
        instruction : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        current_PC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        wb_register : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        wb_register_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        HI_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        LO_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

        read_data_1 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        read_data_2 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        ALU : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        sign_extend : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- sign extend or zero extend
        wb_flag : OUT STD_LOGIC;
        mem_access_flag : OUT STD_LOGIC;
        br_and_j_flag : OUT STD_LOGIC;
        load_flag : OUT STD_LOGIC;
        wb_register_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        current_PC_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        rs_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        ex_flag : OUT STD_LOGIC;
        reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_27, reg_28, reg_29, reg_30, reg_31 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END decode;

ARCHITECTURE arch OF decode IS

    TYPE rss IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL registerArray : rss := (OTHERS => "00000000000000000000000000000000");

    --https://www.cs.tufts.edu/~nr/toolkit/specs/mips.html
    --word 0:31 op 26:31 rs 21:25 rt 16:20 immed 0:15 offset 0:15 base 21:25 
    --target 0:25 rd 11:15 shamt 6:10 funct 0:5 cond 16:20 breakcode 6:25

    SIGNAL op : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL shamt : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL funct : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL rs, rd, rt : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL immed : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL num_four : unsigned(31 DOWNTO 0) := "00000000000000000000000000000100";

BEGIN
    op <= instruction(31 DOWNTO 26);
    rs <= instruction(25 DOWNTO 21);
    rt <= instruction(20 DOWNTO 16);
    rd <= instruction(15 DOWNTO 11);
    shamt <= instruction(10 DOWNTO 6);
    funct <= instruction(5 DOWNTO 0);
    immed <= instruction(15 DOWNTO 0);

    read_data_1 <= registerArray(to_integer(unsigned(rt))) WHEN ((op = "000000" AND funct = "000000") OR (op = "000000" AND funct = "000010") OR (op = "000000" AND funct = "000011"))
        ELSE -- for sll, srl, sra use, here rt is the first operant.
        current_PC(31 DOWNTO 28) & instruction(25 DOWNTO 0) & "00" WHEN (op = "000010" OR op = "000011") ELSE
        registerArray(to_integer(unsigned(rs)));

    read_data_2 <= registerArray(to_integer(unsigned(shamt))) WHEN ((op = "000000" AND funct = "000000") OR (op = "000000" AND funct = "000010") OR (op = "000000" AND funct = "000011")) ELSE
        -- for sll, srl, sra use, here sa is the second operant.
        "0000000000000000" & immed WHEN (op = "001000" AND immed(15) = '0') ELSE -- extends 0 for addi
        "1111111111111111" & immed WHEN (op = "001000" AND immed(15) = '1') ELSE -- extends 1 for addi
        "0000000000000000" & immed WHEN (op = "001010" AND immed(15) = '0') ELSE -- extends 0 for slti
        "1111111111111111" & immed WHEN (op = "001010" AND immed(15) = '1') ELSE -- extends 1 for slti
        "0000000000000000" & immed WHEN (op = "001100") ELSE -- extends 0 for andi
        "0000000000000000" & immed WHEN (op = "001101") ELSE -- extends 0 for ori
        "0000000000000000" & immed WHEN (op = "001110") ELSE -- extends 0 for xori
        "0000000000000000" & immed WHEN (op = "001111") ELSE -- extends 0 for lui, ALU should use read_data_2 for lui
        "0000000000000000" & immed WHEN (op = "100011" AND immed(15) = '0') ELSE -- extends 0 for lw
        "1111111111111111" & immed WHEN (op = "100011" AND immed(15) = '1') ELSE -- extends 1 for lw
        registerArray(to_integer(unsigned(rt)));

    -- https://opencores.org/projects/plasma/ops
    -- Opcode 0x00 accesses the ALU, and the funct selects which ALU function to use.
    -- ops: opt		  shamt funct
    -- add 000000 rs rt rd 00000 100000
    -- sub 000000 rs rt rd 00000 100010
    -- addi 001000 rs rt imm(sign extend)
    -- mult 000000 rs rt 0000000000 011000
    -- div 000000 rs rt 0000000000 011010
    -- slt 000000 rs rt rd 00000 101010
    -- slti 001010 rs rt imm(sign extend)
    -- and 000000 rs rt rd 00000 100100
    -- or 000000 rs rt rd 00000 100101
    -- nor 000000 rs rt rd 00000 100111
    -- xor 000000 rs rt rd 00000 100110
    -- andi 001100 rs rt imm(zero extend)
    -- ori 001101 rs rt imm(zero extend)
    -- xori 001110 rs rt imm(zero extend)
    -- mfhi 000000 0000000000 rd 00000 010000
    -- mflo 000000 0000000000 rd 00000 010010
    -- lui 001111 rs rt imm(zero extend)
    -- sll 000000 rs rt rd sa 000000
    -- srl 000000 rs rt rd sa 000010
    -- sra 000000 00000 rt rd sa 000011
    -- lw 100011 rs rt offset(sign extend)
    -- sw 101011 rs rt offset(sign extend)
    -- beq 000100 rs rt offset(sign extend)
    -- bne 000101 rs rt offset(sign extend)
    -- j 000010 target
    -- jr 000000 rs 000000000000000 001000
    -- jal 000011 target
    ALU <= "00000" WHEN (op = "000000" AND funct = "100000") ELSE --add is 0
        "00001" WHEN (op = "000000" AND funct = "100010") ELSE --sub is 1
        "00010" WHEN (op = "001000") ELSE --addi is 2
        "00011" WHEN (op = "000000" AND funct = "011000") ELSE --mult is 3
        "00100" WHEN (op = "000000" AND funct = "011010") ELSE --div is 4
        "00101" WHEN (op = "000000" AND funct = "101010") ELSE --slt is 5
        "00110" WHEN (op = "001010") ELSE --slti is 6
        "00111" WHEN (op = "000000" AND funct = "100100") ELSE -- and
        "01000" WHEN (op = "000000" AND funct = "100101") ELSE -- or
        "01001" WHEN (op = "000000" AND funct = "100111") ELSE -- nor
        "01010" WHEN (op = "000000" AND funct = "100110") ELSE -- xor
        "01011" WHEN (op = "001100") ELSE -- andi
        "01100" WHEN (op = "001101") ELSE -- ori
        "01101" WHEN (op = "001110") ELSE --xori
        "01110" WHEN (op = "000000" AND funct = "010000") ELSE -- mfhi
        "01111" WHEN (op = "000000" AND funct = "010010") ELSE -- mflo
        "10000" WHEN (op = "001111") ELSE -- lui
        "10001" WHEN (op = "000000" AND funct = "000000") ELSE -- sll
        "10010" WHEN (op = "000000" AND funct = "000010") ELSE -- srl
        "10011" WHEN (op = "000000" AND funct = "000011") ELSE -- sra
        "10100" WHEN (op = "100011") ELSE -- lw
        "10101" WHEN (op = "101011") ELSE -- sw
        "10110" WHEN (op = "000100") ELSE -- beq
        "10111" WHEN (op = "000101") ELSE -- bne
        "11000" WHEN (op = "000010") ELSE -- j
        "11001" WHEN (op = "000000" AND funct = "001000") ELSE -- jr
        "11010" WHEN (op = "000011"); -- jal

    sign_extend <= "0000000000000000" & immed WHEN (op = "001000" AND immed(15) = '0') ELSE -- extends 0 for addi
        "1111111111111111" & immed WHEN (op = "001000" AND immed(15) = '1') ELSE -- extends 1 for addi
        "0000000000000000" & immed WHEN (op = "001010" AND immed(15) = '0') ELSE -- extends 0 for slti
        "1111111111111111" & immed WHEN (op = "001010" AND immed(15) = '1') ELSE -- extends 1 for slti
        "0000000000000000" & immed WHEN (op = "001100") ELSE -- extends 0 for andi
        "0000000000000000" & immed WHEN (op = "001101") ELSE -- extends 0 for ori
        "0000000000000000" & immed WHEN (op = "001110") ELSE -- extends 0 for xori
        "0000000000000000" & immed WHEN (op = "001111") ELSE -- extends 0 for lui
        "0000000000000000" & immed WHEN (op = "100011" AND immed(15) = '0') ELSE -- extends 0 for lw
        "1111111111111111" & immed WHEN (op = "100011" AND immed(15) = '1') ELSE -- extends 1 for lw
        "0000000000000000" & immed WHEN (op = "101011" AND immed(15) = '0') ELSE -- extends 0 for sw
        "1111111111111111" & immed WHEN (op = "101011" AND immed(15) = '1') ELSE -- extends 1 for sw
        "0000000000000000" & immed WHEN (op = "000100" AND immed(15) = '0') ELSE -- extends 0 for beq
        "1111111111111111" & immed WHEN (op = "000100" AND immed(15) = '1') ELSE -- extends 1 for beq
        "0000000000000000" & immed WHEN (op = "000101" AND immed(15) = '0') ELSE -- extends 0 for bne
        "1111111111111111" & immed WHEN (op = "000101" AND immed(15) = '1') ELSE -- extends 1 for bne
        "00000000000000000000000000000000"; -- default 0

    -- The following instructions do not need write back.
    -- mult 000000 rs rt 0000000000 011000
    -- div 000000 rs rt 0000000000 011010
    -- mfhi 000000 0000000000 rd 00000 010000
    -- mflo 000000 0000000000 rd 00000 010010
    -- sw 101011 rs rt offset(sign extend)
    -- beq 000100 rs rt offset(sign extend)
    -- bne 000101 rs rt offset(sign extend)
    -- j 000010 target
    -- jr 000000 rs 000000000000000 001000
    -- jal 000011 target
    wb_flag <= '0' WHEN ((op = "000000" AND (funct = "011000" OR funct = "011010" OR funct = "001000" OR funct = "010000" OR funct = "010010")) OR (op = "101011") OR (op = "000100") OR (op = "000101") OR (op = "000010") OR (op = "000011")) ELSE
        '1';

    -- lw 100011 rs rt offset(sign extend)
    -- sw 101011 rs rt offset(sign extend)			  
    mem_access_flag <= '1' WHEN (op = "100011" OR op = "101011") ELSE
        '0';

    -- beq 000100 rs rt offset(sign extend)
    -- bne 000101 rs rt offset(sign extend)
    -- j 000010 target
    -- jr 000000 rs 000000000000000 001000
    -- jal 000011 target						 
    br_and_j_flag <= '1' WHEN ((op = "000100") OR (op = "000101") OR (op = "000010") OR (op = "000000" AND funct = "001000") OR (op = "000011")) ELSE
        '0';

    -- lw 100011 rs rt offset(sign extend)				  
    load_flag <= '1' WHEN (op = "100011") ELSE
        '0';

    -- ops: opt		  shamt funct
    -- add 000000 rs rt rd 00000 100000
    -- sub 000000 rs rt rd 00000 100010
    -- slt 000000 rs rt rd 00000 101010
    -- and 000000 rs rt rd 00000 100100
    -- or 000000 rs rt rd 00000 100101
    -- nor 000000 rs rt rd 00000 100111
    -- xor 000000 rs rt rd 00000 100110
    -- mfhi 000000 0000000000 rd 00000 010000
    -- mflo 000000 0000000000 rd 00000 010010
    -- sll 000000 rs rt rd sa 000000
    -- srl 000000 rs rt rd sa 000010
    -- sra 000000 00000 rt rd sa 000011
    wb_register_out <= rd WHEN (op = "000000" AND (funct = "100000" OR funct = "100010" OR funct = "101010" OR funct = "100100" OR funct = "100101" OR funct = "100111" OR funct = "100110" OR funct = "010000" OR funct = "010010" OR funct = "000000" OR funct = "000010" OR funct = "000011")) ELSE
        -- addi 001000 rs rt imm(sign extend)
        -- slti 001010 rs rt imm(sign extend)
        -- andi 001100 rs rt imm(zero extend)
        -- ori 001101 rs rt imm(zero extend)
        -- xori 001110 rs rt imm(zero extend)
        -- lui 001111 rs rt imm(zero extend)
        -- lw 100011 rs rt offset(sign extend)
        rt WHEN (op = "001000" OR op = "001010" OR op = "001100" OR op = "001101" OR op = "001110" OR op = "001111" OR op = "100011") ELSE
        -- mult 000000 rs rt 0000000000 011000
        -- div 000000 rs rt 0000000000 011010
        -- sw 101011 rs rt offset(sign extend)
        -- beq 000100 rs rt offset(sign extend)
        -- bne 000101 rs rt offset(sign extend)
        -- j 000010 target
        -- jr 000000 rs 000000000000000 001000
        -- jal 000011 target
        "00000";

    current_PC_out <= current_PC;

    -- ops: opt		  shamt funct
    -- add 000000 rs rt rd 00000 100000
    -- sub 000000 rs rt rd 00000 100010
    -- addi 001000 rs rt imm(sign extend)
    -- mult 000000 rs rt 0000000000 011000
    -- div 000000 rs rt 0000000000 011010
    -- slt 000000 rs rt rd 00000 101010
    -- slti 001010 rs rt imm(sign extend)
    -- and 000000 rs rt rd 00000 100100
    -- or 000000 rs rt rd 00000 100101
    -- nor 000000 rs rt rd 00000 100111
    -- xor 000000 rs rt rd 00000 100110
    -- andi 001100 rs rt imm(zero extend)
    -- ori 001101 rs rt imm(zero extend)
    -- xori 001110 rs rt imm(zero extend)
    -- lw 100011 rs rt offset(sign extend)
    -- sw 101011 rs rt offset(sign extend)
    -- beq 000100 rs rt offset(sign extend)
    -- bne 000101 rs rt offset(sign extend)
    -- jr 000000 rs 000000000000000 001000
    rs_out <= rs WHEN ((op = "000000" AND (funct = "100000" OR funct = "100010" OR funct = "011000" OR funct = "011010" OR funct = "101010" OR funct = "100100" OR funct = "100101" OR funct = "100111" OR funct = "100110" OR funct = "001000"))
        OR op = "001000" OR op = "001010" OR op = "001100" OR op = "001101" OR op = "001110" OR op = "100011" OR op = "101011" OR op = "000100" OR op = "000101") ELSE
        -- mfhi 000000 0000000000 rd 00000 010000
        -- mflo 000000 0000000000 rd 00000 010010
        -- lui 001111 rs rt imm(zero extend)
        -- sll 000000 rs rt rd sa 000000
        -- srl 000000 rs rt rd sa 000010
        -- sra 000000 00000 rt rd sa 000011
        -- j 000010 target
        -- jal 000011 target
        "00000";

    -- ops: opt		  shamt funct
    -- add 000000 rs rt rd 00000 100000
    -- sub 000000 rs rt rd 00000 100010
    -- mult 000000 rs rt 0000000000 011000
    -- div 000000 rs rt 0000000000 011010
    -- slt 000000 rs rt rd 00000 101010
    -- and 000000 rs rt rd 00000 100100
    -- or 000000 rs rt rd 00000 100101
    -- nor 000000 rs rt rd 00000 100111
    -- xor 000000 rs rt rd 00000 100110
    -- sll 000000 rs rt rd sa 000000
    -- srl 000000 rs rt rd sa 000010
    -- sra 000000 00000 rt rd sa 000011
    -- sw 101011 rs rt offset(sign extend)
    -- beq 000100 rs rt offset(sign extend)
    -- bne 000101 rs rt offset(sign extend)
    rt_out <= rt WHEN ((op = "000000" AND (funct = "100000" OR funct = "100010" OR funct = "011000" OR funct = "011010" OR funct = "101010" OR funct = "100100" OR funct = "100101" OR funct = "100111" OR funct = "100110" OR funct = "000000" OR funct = "000010" OR funct = "000011"))
        OR op = "101011" OR op = "000100" OR op = "000101") ELSE
        -- addi 001000 rs rt imm(sign extend)
        -- slti 001010 rs rt imm(sign extend)
        -- andi 001100 rs rt imm(zero extend)
        -- ori 001101 rs rt imm(zero extend)
        -- xori 001110 rs rt imm(zero extend)
        -- mfhi 000000 0000000000 rd 00000 010000
        -- mflo 000000 0000000000 rd 00000 010010
        -- lui 001111 rs rt imm(zero extend)
        -- lw 100011 rs rt offset(sign extend)
        -- j 000010 target
        -- jr 000000 rs 000000000000000 001000
        -- jal 000011 target
        "00000";

    ex_flag <= '0' WHEN ((op = "000000" AND funct = "010000") OR (op = "000000" AND funct = "010010")) ELSE -- for mfhi and mflo
        '1';

    --process(wb_register_data, wb_register, LO_data, HI_data)
    --begin
    --if (wb_register = "00000") then registerArray(0) <= "00000000000000000000000000000000"; 
    --else registerArray(to_integer(unsigned(wb_register))) <= wb_register_data;
    --end if;
    --if (rd /= "00000" and op="000000" and funct="010000") then registerArray(to_integer(unsigned(rd))) <= HI_data;
    --elsif (rd /= "00000" and op="000000" and funct="010010") then registerArray(to_integer(unsigned(rd))) <= LO_data;
    --end if;
    --end process;

    PROCESS (wb_register_data, wb_register, LO_data, HI_data)
    BEGIN
        IF (wb_register = "00000") THEN
            registerArray(0) <= "00000000000000000000000000000000";
        ELSE
            registerArray(to_integer(unsigned(wb_register))) <= wb_register_data;
        END IF;
        IF (rd /= "00000" AND op = "000000" AND funct = "010000") THEN
            registerArray(to_integer(unsigned(rd))) <= HI_data;
        ELSIF (rd /= "00000" AND op = "000000" AND funct = "010010") THEN
            registerArray(to_integer(unsigned(rd))) <= LO_data;
        END IF;
        IF (op = "000011") THEN
            registerArray(31) <= STD_LOGIC_VECTOR(unsigned(current_PC) + num_four);
        END IF;
    END PROCESS;

    PROCESS (clock)
        VARIABLE r : line;
        FILE register_f : text;
    BEGIN
        IF (rising_edge(clock)) THEN
            file_open(register_f, "register_file.txt", write_mode);
            FOR i IN 0 TO 31 LOOP
                write(r, registerArray(i));
                writeline(register_f, r);
            END LOOP;
            file_close(register_f);
        END IF;
    END PROCESS;
    reg_0 <= registerArray(0);
    reg_1 <= registerArray(1);
    reg_2 <= registerArray(2);
    reg_3 <= registerArray(3);
    reg_4 <= registerArray(4);
    reg_5 <= registerArray(5);
    reg_6 <= registerArray(6);
    reg_7 <= registerArray(7);
    reg_8 <= registerArray(8);
    reg_9 <= registerArray(9);
    reg_10 <= registerArray(10);
    reg_11 <= registerArray(11);
    reg_12 <= registerArray(12);
    reg_13 <= registerArray(13);
    reg_14 <= registerArray(14);
    reg_15 <= registerArray(15);
    reg_16 <= registerArray(16);
    reg_17 <= registerArray(17);
    reg_18 <= registerArray(18);
    reg_19 <= registerArray(19);
    reg_20 <= registerArray(20);
    reg_21 <= registerArray(21);
    reg_22 <= registerArray(22);
    reg_23 <= registerArray(23);
    reg_24 <= registerArray(24);
    reg_25 <= registerArray(25);
    reg_26 <= registerArray(26);
    reg_27 <= registerArray(27);
    reg_28 <= registerArray(28);
    reg_29 <= registerArray(29);
    reg_30 <= registerArray(30);
    reg_31 <= registerArray(31);
END arch;