library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity subtractor16_tb is
end entity subtractor16_tb;

architecture behavioral of subtractor16_tb is
--Only testing for accuracy, since ripple tested on adder16

--SIGNAL DECLARATIONS
	--input
    signal A_sig  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
    signal B_sig  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');   
	--outputs
    signal R_beh    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal cout_beh : STD_LOGIC;  	 
	signal R_str    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal cout_str : STD_LOGIC;  	   
	--crit path
    constant DELTA_DELAY : time :=  660 ns;

begin	
	uut_beh : entity work.subtractor16(behavioral)
        port map ( A => A_sig, B => B_sig, R => R_beh, c_out => cout_beh);	 
    uut_str : entity work.subtractor16(structural)
        port map ( A => A_sig, B => B_sig, R => R_str, c_out => cout_str);   

    test : process	
	variable A_int, B_int, R_int, cout_int : INTEGER;
	variable overflow : std_logic;
    begin	   
		-- general sanity test
		for k in 0 to 3 loop
			for i in 0 to 50 loop	
				for j in 0 to 50 loop  
					A_int := i;
					B_int := j;
					if 	  (k = 1 or k = 3) then A_int := -i;
					elsif (k = 2 or k = 3) then B_int := -j;
					end if;
					R_int   := A_int - B_int;
					--assign
					A_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(A_int, 16));
					B_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(B_int, 16));
					wait for DELTA_DELAY; 
					-- assert
					assert (TO_INTEGER(SIGNED(R_beh)) = R_int) 
					report 	"behavioral fail" & LF &
							"Expected:   A_int - B_int = R_int" & LF &
							INTEGER'IMAGE(A_int) & " - " & INTEGER'IMAGE(B_int) & " = " & INTEGER'IMAGE(R_int) & LF &
							"Actual:     A_sig - B_sig = R_beh" & LF &
							INTEGER'IMAGE(TO_INTEGER(SIGNED(A_sig))) & " - " & INTEGER'IMAGE(TO_INTEGER(SIGNED(B_sig))) & " = " & INTEGER'IMAGE(TO_INTEGER(SIGNED(R_beh)));
					assert (TO_INTEGER(SIGNED(R_str)) = R_int) 	
					report 	"structural fail" & LF &
							"Expected:   A_int - B_int = R_int" & LF &
							INTEGER'IMAGE(A_int) & " - " & INTEGER'IMAGE(B_int) & " = " & INTEGER'IMAGE(R_int) & LF &
							"Actual:     A_sig - B_sig = R_str" & LF &
							INTEGER'IMAGE(TO_INTEGER(SIGNED(A_sig))) & " - " & INTEGER'IMAGE(TO_INTEGER(SIGNED(B_sig))) & " = " & INTEGER'IMAGE(TO_INTEGER(SIGNED(R_str)));		
				end loop;
			end loop;
		end loop; 
		
		--c_out TESTING
		
		--max neg - pos, c_out = 0
		A_sig <= X"8000";	  	 
		B_sig <= X"0001";	  	  	
		wait for DELTA_DELAY;
		assert cout_beh = '0' 
			report "behaviroal fail" & LF &
			"Expected  C_OUT: 0 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_beh); 
		assert cout_str = '0' 
			report "structural fail" & LF &
			"Expected  C_OUT: 0 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_str);
		
		--max neg - neg, c_out = 1
		A_sig <= X"8000"; 		
		B_sig <= X"F000";		
		wait for DELTA_DELAY;	
		assert cout_beh = '1' 
			report "behaviroal fail" & LF &
			"Expected  C_OUT: 1 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_beh); 
		assert cout_str = '1' 
			report "structural fail" & LF &
			"Expected  C_OUT: 1 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_str);
		
		--max pos - pos, c_out = 0
		A_sig <= X"0FFF"; 		--max pos
		B_sig <= X"0001";		
		wait for DELTA_DELAY;
		assert cout_beh = '0' 
			report "behaviroal fail" & LF &
			"Expected  C_OUT: 0 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_beh); 
		assert cout_str = '0' 
			report "structural fail" & LF &
			"Expected  C_OUT: 0 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_str);
		
		--max pos - neg, c_out = 1
		A_sig <= X"0FFF"; 		--max pos
		B_sig <= X"FFFF";		
		wait for DELTA_DELAY;
		assert cout_beh = '1' 
			report "behaviroal fail" & LF &
			"Expected  C_OUT: 1 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_beh); 
		assert cout_str = '1' 
			report "structural fail" & LF &
			"Expected  C_OUT: 1 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_str);
		
		--	  1 - 3 = neg, c_out = 1
		A_sig <= X"0001"; 	
		B_sig <= X"0003";		
		wait for DELTA_DELAY;
		assert cout_beh = '1' 
			report "behaviroal fail" & LF &
			"Expected  C_OUT: 1 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_beh); 
		assert cout_str = '1' 
			report "structural fail" & LF &
			"Expected  C_OUT: 1 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_str);
		
		--	  -1 - (-3) = pos, c_out = 0
		A_sig <= X"FFFF"; 	
		B_sig <= X"FFFD";		
		wait for DELTA_DELAY;
		assert cout_beh = '0' 
			report "behaviroal fail" & LF &
			"Expected  C_OUT: 0 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_beh); 
		assert cout_str = '0' 
			report "structural fail" & LF &
			"Expected  C_OUT: 0 " & LF &
			"Actual C_OUT :   " & STD_LOGIC'IMAGE(cout_str);
		
        wait;

    end process test;

end architecture behavioral;