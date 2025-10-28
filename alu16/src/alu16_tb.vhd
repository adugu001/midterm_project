library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- TODO Flag tests for multiplier

entity alu16_tb is
end entity alu16_tb;

architecture behavioral of alu16_tb is
--CREATES TEST CASES FOR SPECIAL-CASES
type TestCase_Record is record
    A       : STD_LOGIC_VECTOR(15 downto 0);
    B       : STD_LOGIC_VECTOR(15 downto 0);
    sel     : STD_LOGIC_VECTOR(2 downto 0);
    R       : STD_LOGIC_VECTOR(15 downto 0);
    status  : STD_LOGIC_VECTOR(2 downto 0);	 --v,z,n
end record;	 
type TestCase_Array is array (natural range <>) of TestCase_Record;		 
--USED TO TEST FOR PROPER STATUS FLAGS
constant flag_tests : TestCase_Array := (		 
	-- SEL = 0 ---> Addition
    (A => X"0001", B => X"0000", sel => "000", R => X"0001", status => "000"), 	--Test no status flag
	(A => X"0000", B => X"0000", sel => "000", R => X"0000", status => "010"), 	--Test z (r=0)
	(A => X"8000", B => X"8001", sel => "000", R => X"0001", status => "100"), 	--Test v
	(A => X"1000", B => X"0000", sel => "000", R => X"1000", status => "001"), 	--Test n
	(A => X"7FFF", B => X"7FFF", sel => "000", R => X"FFFE", status => "101"),	--test v and n (pos + pos = neg)
	(A => X"8000", B => X"8000", sel => "000", R => X"0000", status => "110"),	--test v and z (neg + neg = 0) 
	-- SEL = 1 ---> Mult
    (A => X"", B => X"", sel => "001", R => X"", status => "000"), 	--Test no status flag
	(A => X"", B => X"", sel => "001", R => X"", status => "010"), 	--Test z (r=0)
	(A => X"", B => X"", sel => "001", R => X"", status => "100"), 	--Test v
	(A => X"", B => X"", sel => "001", R => X"", status => "001"), 	--Test n
	-- SEL = 2 ---> A carrythrough
    (A => X"0001", B => X"0000", sel => "010", R => X"0001", status => "000"), 	--Test no status flag
	(A => X"0000", B => X"0001", sel => "010", R => X"0000", status => "010"), 	--Test z (r=0)
	(A => X"1000", B => X"0F00", sel => "010", R => X"1000", status => "001"), 	--Test n
	-- SEL = 3 ---> B carrythrough
    (A => X"0000", B => X"0001", sel => "011", R => X"0001", status => "000"), 	--Test no status flag
	(A => X"0001", B => X"0000", sel => "011", R => X"0000", status => "010"), 	--Test z (r=0)
	(A => X"0F00", B => X"1000", sel => "011", R => X"1000", status => "001"), 	--Test n   
	-- SEL = 4 ---> Subtraction
    (A => X"0008", B => X"0002", sel => "100", R => X"0006", status => "000"), 	--Test no status flag
	(A => X"0004", B => X"0004", sel => "100", R => X"0000", status => "010"), 	--Test z (r=0)
	(A => X"0000", B => X"0000", sel => "100", R => X"0000", status => "100"), 	--Test z
	(A => X"1000", B => X"0000", sel => "100", R => X"1000", status => "001"), 	--Test n
	(A => X"0000", B => X"0FFF", sel => "100", R => X"F001", status => "001"),	--test n
	(A => X"8000", B => X"7FFF", sel => "100", R => X"0001", status => "100"),	--test v       (neg - pos = pos) 
	(A => X"7FFF", B => X"8001", sel => "100", R => X"FFFE", status => "101"),	--test v and n (pos - neg = neg)  
	-- SEL = 5 ---> R always 0
    (A => X"0001", B => X"0001", sel => "101", R => X"0000", status => "010"), 
	(A => X"8000", B => X"0001", sel => "101", R => X"0000", status => "010"), 	
	(A => X"F001", B => X"00F1", sel => "101", R => X"0000", status => "010"), 	
	-- SEL = 6 ---> R always 0
    (A => X"0001", B => X"0001", sel => "110", R => X"0000", status => "010"), 
	(A => X"8000", B => X"0001", sel => "110", R => X"0000", status => "010"), 	
	(A => X"F001", B => X"00F1", sel => "110", R => X"0000", status => "010"), 
	-- SEL = 7 ---> R always 0
    (A => X"0001", B => X"0001", sel => "111", R => X"0000", status => "010"), 
	(A => X"8000", B => X"0001", sel => "111", R => X"0000", status => "010"), 	
	(A => X"F001", B => X"00F1", sel => "111", R => X"0000", status => "010")
);

--SIGNAL DECLARATIONS
	--input
    signal A_sig    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
    signal B_sig    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal sel_sig  : STD_LOGIC_VECTOR(2 downto 0);    
	--outputs
    signal R_beh    : STD_LOGIC_VECTOR(15 downto 0);
    signal stat_beh : STD_LOGIC_VECTOR(2 downto 0);  	 
	signal R_str    : STD_LOGIC_VECTOR(15 downto 0);
    signal stat_str : STD_LOGIC_VECTOR(2 downto 0);  	   
	--crit path
    constant DELTA_DELAY : time :=  640 ns;	 --XXXXX GET ONCE CRIT DELAY CALCULATED XXXXXX

begin	
	uut_beh : entity work.alu16(behavioral)
        port map (A  => A_sig, B => B_sig, S2 => sel(2), S1 => sel(1), S0 => sel(0), status => stat_beh, R => R_beh);
	uut_str : entity work.alu16(structural)
        port map (A  => A_sig, B => B_sig, S2 => sel(2), S1 => sel(1), S0 => sel(0), status => stat_str, R => R_str);

    test : process	
	--TODO PUT VARIABLE DECLARATIONS
    begin
		INPUT_SIGNS: for k in 0 to 3 loop -- to check different operand sign combinations 
			if (k = 1 or k = 3) then A_sign := -1; else A_sign := 1; end if;
			if (k = 2 or k = 3) then B_sign := -1; else B_sign := 1; end if;
		    A_LOOP: for i in 0 to 10 loop  
				A_int := i*A_sign;
		        B_LOOP: for j in 0 to 10 loop -- to check various values for B
					B_int := j*B_sign;
					for sel_op in 0 to 7 loop -- to test each operation
			           	-- Calculate result for correct operation
						if    sel_op = 0 then R_int := A_int + B_int;
						elsif sel_op = 1 then R_int := A_int * B_int;
						elsif sel_op = 2 then R_int := A_int;
						elsif sel_op = 3 then R_int := B_int;
						elsif sel_op = 4 then R_int := A_int - B_int;
						else R_int := 0;
						end if;			
						R_v := STD_LOGIC_VECTOR(TO_UNSIGNED(R_int, 17));	-- Cast to vector
						-- Assign inputs
			            A_sig <= STD_LOGIC_VECTOR(TO_SIGNED(A_int, 16));   	
			            B_sig <= STD_LOGIC_VECTOR(TO_SIGNED(B_int, 16));
			            sel <= STD_LOGIC_VECTOR(TO_UNSIGNED(sel_op, 3));
					    -- delay
			            wait for DELTA_DELAY;  	
						assert R_beh = R_v(15 downto 0) 	    -- Check Answer
						report 	"BEHAVIORAL FAIL. SEL = " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(sel))) & LF &	
								"   Expected: " & LF &
								"     A: " & INTEGER'IMAGE(A_int) & LF &	
								"     B: " & INTEGER'IMAGE(B_int) & LF &	
								"     R: " & INTEGER'IMAGE(R_int) & LF & 
								"   Actual: " & LF &
								"     A: " & INTEGER'IMAGE(TO_INTEGER(SIGNED(A_sig))) & LF &	
								"     B: " & INTEGER'IMAGE(TO_INTEGER(SIGNED(B_sig))) & LF &	
								"     R: " & INTEGER'IMAGE(TO_INTEGER(SIGNED(R_beh))); 
						assert R_str = R_v(15 downto 0) 	    -- Check Answer
						report 	"STRUCTURAL FAIL. SEL = " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(sel))) & LF &	
								"   Expected: " & LF &
								"     A: " & INTEGER'IMAGE(A_int) & LF &	
								"     B: " & INTEGER'IMAGE(B_int) & LF &	
								"     R: " & INTEGER'IMAGE(R_int) & LF & 
								"   Actual: " & LF &
								"     A: " & INTEGER'IMAGE(TO_INTEGER(SIGNED(A_sig))) & LF &	
								"     B: " & INTEGER'IMAGE(TO_INTEGER(SIGNED(B_sig))) & LF &	
								"     R: " & INTEGER'IMAGE(TO_INTEGER(SIGNED(R_str)));
					end loop;  
				end loop;
			end loop;
		end loop; 
        wait;
    end process test;

end architecture behavioral;