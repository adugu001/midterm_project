library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity adder16_tb is
end entity adder16_tb;

architecture behavioral of adder16_tb is
--CREATES TEST CASES FOR SPECIAL-CASES
type TestCase_Record is record
    A_in    : STD_LOGIC_VECTOR(15 downto 0);
    B_in    : STD_LOGIC_VECTOR(15 downto 0);
    C_in    : STD_LOGIC;
    Sum : STD_LOGIC_VECTOR(15 downto 0);
    Cout: STD_LOGIC;
end record;	 
type TestCase_Array is array (natural range <>) of TestCase_Record;
constant Test_Cases : TestCase_Array := (
    (A_in => X"FFFF", B_in => X"FFFF", C_in => '0', Sum => X"FFFE", Cout => '1'), -- Max + Max + 0
    (A_in => X"FFFF", B_in => X"FFFF", C_in => '1', Sum => X"FFFF", Cout => '1'), -- Max + Max + 1
    (A_in => X"0000", B_in => X"FFFF", C_in => '0', Sum => X"FFFF", Cout => '0'), -- 0 + Max + 0
    (A_in => X"0000", B_in => X"FFFF", C_in => '1', Sum => X"0000", Cout => '1'), -- 0 + Max + 1
    (A_in => X"FFFF", B_in => X"0000", C_in => '0', Sum => X"FFFF", Cout => '0'), -- Max + 0 + 0
    (A_in => X"FFFF", B_in => X"0000", C_in => '1', Sum => X"0000", Cout => '1'), -- Max + 0 + 1
    (A_in => X"0000", B_in => X"FFFE", C_in => '0', Sum => X"FFFE", Cout => '0'), -- 0 + (Max-1) + 0
    (A_in => X"0000", B_in => X"FFFE", C_in => '1', Sum => X"FFFF", Cout => '0'), -- 0 + (Max-1) + 1
    (A_in => X"FFFE", B_in => X"0000", C_in => '0', Sum => X"FFFE", Cout => '0'), -- (Max-1) + 0 + 0
    (A_in => X"FFFE", B_in => X"0000", C_in => '1', Sum => X"FFFF", Cout => '0'), -- (Max-1) + 0 + 1
    (A_in => X"F000", B_in => X"F000", C_in => '0', Sum => X"E000", Cout => '1'), -- Mid-range Overflow
    (A_in => X"F000", B_in => X"F000", C_in => '1', Sum => X"E001", Cout => '1'), -- Mid-range Overflow + 1
    (A_in => X"F000", B_in => X"0FFF", C_in => '0', Sum => X"FFFF", Cout => '0'), -- Check for Max Sum No Carry
    (A_in => X"F000", B_in => X"0FFF", C_in => '1', Sum => X"0000", Cout => '1'), -- Max Sum + 1 = Full Overflow
    (A_in => X"0FFF", B_in => X"F000", C_in => '0', Sum => X"FFFF", Cout => '0'), -- Same as above, commutative
    (A_in => X"0FFF", B_in => X"F000", C_in => '1', Sum => X"0000", Cout => '1'), -- Same as above, commutative
    -- Full Ripple-Through (All 1s, C_in=0, should produce carry-out)
    (A_in => X"8000", B_in => X"8000", C_in => '0', Sum => X"0000", Cout => '1'), -- 32768 + 32768 = 65536    
    (A_in => X"AAAA", B_in => X"5555", C_in => '0', Sum => X"FFFF", Cout => '0'), -- Alternating Ripple (Stresses propagation through all bits)
    (A_in => X"AAAA", B_in => X"5555", C_in => '1', Sum => X"0000", Cout => '1'), -- 1010 + 0101 + 1 = 16-bit ripple to 0	  
    (A_in => X"F00F", B_in => X"0FF0", C_in => '1', Sum => X"0000", Cout => '1'), -- Carry generated at bit 4, ripples to bit 15, then C_out
    (A_in => X"1234", B_in => X"0000", C_in => '0', Sum => X"1234", Cout => '0'),  -- Identity Check (A + 0 + 0 = A)  
    (A_in => X"5A5A", B_in => X"5A5A", C_in => '0', Sum => X"B4B4", Cout => '0')	 -- A=B Check (Simple Doubling)
);

--SIGNAL DECLARATIONS
	--input
    signal A_sig  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
    signal B_sig  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal c_sig  : STD_LOGIC := '0';    
	--outputs
    signal R_beh    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal cout_beh : STD_LOGIC;  	 
	signal R_str    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal cout_str : STD_LOGIC;  	   
	--crit path
    constant DELTA_DELAY : time :=  640 ns;

begin	
	uut_beh : entity work.adder16(behavioral)
        port map ( A  => A_sig, B => B_sig, c_in => c_sig, R => R_beh, c_out => cout_beh);	 
    uut_str : entity work.adder16(structural)
        port map ( A  => A_sig, B => B_sig, c_in => c_sig, R => R_str, c_out => cout_str);

    test : process	
	variable A_int, B_int, c_int, R_int, cout_int : INTEGER;
    begin
        SPECIAL_CASES: for i in Test_cases'range loop 
			--assign
			A_sig   <= Test_cases(i).A_in;
			B_sig   <= Test_cases(i).B_in;
			c_sig   <= Test_cases(i).C_in;  
			wait for DELTA_DELAY;
			--assert
			assert (R_beh = Test_cases(i).Sum and cout_beh = Test_cases(i).Cout) 
				report "behavioral special cases test fail"; 
			assert (R_str = Test_cases(i).Sum and cout_str = Test_cases(i).Cout) 
				report "structural special cases test fail";
		end loop;
		
		sanity_check_loop: for i in 0 to 1000 loop	
			for j in 0 to 10 loop	
				--calc actual sum
				R_int   := i + j;
				--assign
				A_sig   <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 16));
				B_sig   <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, 16));
				c_sig   <= '0';  
				wait for DELTA_DELAY; 
				-- assert
				assert (UNSIGNED(R_beh) = R_int) report "behavioral sanity check fail";
				assert (UNSIGNED(R_str) = R_int) report "structural sanity check fail"; 
				R_int := R_int + 1;
				c_sig <= '1';  
				wait for DELTA_DELAY;
				assert (UNSIGNED(R_beh) = R_int) report "behavioral sanity check fail";
				assert (UNSIGNED(R_str) = R_int) report "structural sanity check fail"; 
			end loop;
		end loop;
        --put test here

        wait;

    end process test;

end architecture behavioral;