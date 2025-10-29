library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity mux8_tb is
end entity mux8_tb;

architecture behavioral of mux8_tb is 
--CREATES TEST CASE
type TestCase_Record is record
    A0       : STD_LOGIC_VECTOR(15 downto 0);
    A1       : STD_LOGIC_VECTOR(15 downto 0);
    A2       : STD_LOGIC_VECTOR(15 downto 0); 
    A3       : STD_LOGIC_VECTOR(15 downto 0);
    A4       : STD_LOGIC_VECTOR(15 downto 0);
	A5       : STD_LOGIC_VECTOR(15 downto 0);
    A6       : STD_LOGIC_VECTOR(15 downto 0);
    A7       : STD_LOGIC_VECTOR(15 downto 0);
end record;	 
-- IF SEL = n, THEN THE INPUT VECTOR WILL BE n
constant cases : TestCase_Record := (	
	A0       => X"0000",	--sel = 0
    A1       => X"0001",	--sel = 1
    A2       => X"0002", 	-- etc
    A3       => X"0003",
    A4       => X"0004",
	A5       => X"0005",
    A6       => X"0006",
    A7       => X"0007"
);	 
-- DECLARE OUTPUT SIGNALS
signal sel_sig : STD_LOGIC_VECTOR(2 downto 0);
signal R_str, R_beh : STD_LOGIC_VECTOR(15 downto 0);
constant DELTA_DELAY : time :=  10ns;  -- MUX WORKS WITH NO DELAY

begin	
	uut1 : entity work.mux16(behavioral)
        port map ( 	  
			SEL => sel_sig,
			A0 => cases.A0,
			A1 => cases.A1,
			A2 => cases.A2,
			A3 => cases.A3,
			A4 => cases.A4,
			A5 => cases.A5,
			A6 => cases.A6,
			A7 => cases.A7,
			R  => R_beh
		);	 
	uut2 : entity work.mux16(structural)
        port map ( 	  
			SEL => sel_sig,
			A0 => cases.A0,
			A1 => cases.A1,
			A2 => cases.A2,
			A3 => cases.A3,
			A4 => cases.A4,
			A5 => cases.A5,
			A6 => cases.A6,
			A7 => cases.A7,
			R  => R_str
		);

    test : process	
    begin	
		THE_LOOP : for i in 0 to 7 loop	
			-- SET SEL = i
			sel_sig <= STD_LOGIC_VECTOR(TO_UNSIGNED(i,3));	  
			wait for DELTA_DELAY; 
			-- VERIFY OUTPUT = i
			assert TO_INTEGER(UNSIGNED(R_beh)) = i 
				report "[BEHAVIORAL]  Failure at mux input : " & INTEGER'IMAGE(i);  
			assert TO_INTEGER(UNSIGNED(R_str)) = i 
				report "[STRUCTURAL]  Failure at mux input : " & INTEGER'IMAGE(i); 
		end loop;
        wait;
    end process test;

end architecture behavioral;