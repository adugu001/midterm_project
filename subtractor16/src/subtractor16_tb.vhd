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
    constant DELTA_DELAY : time :=  650 ns;

begin	
	uut_beh : entity work.subtractor16(behavioral)
        port map ( A => A_sig, B => B_sig, R => R_beh, c_out => cout_beh);	 
    uut_str : entity work.subtractor16(structural)
        port map ( A => A_sig, B => B_sig, R => R_str, c_out => cout_str);   

    test : process	
	variable A_int, B_int, R_int, cout_int : INTEGER;  
	variable R_v : STD_LOGIC_VECTOR(15 downto 0);
	variable cout_exp : std_logic;
    begin	   
		-- general sanity test
		for k in 0 to 3 loop
		    for i in 0 to 10 loop
		        for j in 0 to 10 loop
		            
		            -- Calculate signed integer inputs and result
		            A_int := i;
		            B_int := j;
		            
		            if (k = 1 or k = 3) then A_int := -i; end if;
		            if (k = 2 or k = 3) then B_int := -j; end if;
		            
		            R_int := A_int - B_int;  -- True mathematical result
		
		            -- 1. ASSIGN INPUTS
		            A_sig <= STD_LOGIC_VECTOR(TO_SIGNED(A_int, 16));
		            B_sig <= STD_LOGIC_VECTOR(TO_SIGNED(B_int, 16));
		            
		            -- Wait for signals to propagate
		            wait for DELTA_DELAY;  
					
					 -- 2. CALCULATE EXPECTED RESULT VECTOR (R_v)
		            -- Cast R_int to 16-bit UNSIGNED. This correctly performs R_int MOD 2^16, 
		            -- simulating the hardware's 16-bit truncation/wrap-around.
		            R_v := STD_LOGIC_VECTOR(TO_UNSIGNED(R_int mod 65536, 16));
		            
		            -- 3. CALCULATE EXPECTED CARRY-OUT (Cout)
		            -- Cout is the "No Borrow" flag: '1' if A >= B (unsigned comparison)
		            if TO_INTEGER(UNSIGNED(A_sig)) >= TO_INTEGER(UNSIGNED(B_sig)) then 
		                cout_exp := '1';
		            else 
		                cout_exp := '0';
		            end if;
					
					assert (R_beh = R_v and cout_beh = cout_exp ) 
					report 	"behavioral fail" & LF &
							"A_int    : " & INTEGER'IMAGE(A_int) & LF &
							"A_sig    : " & INTEGER'IMAGE(TO_INTEGER(SIGNED(A_sig))) & LF &  
							"B_int    : " & INTEGER'IMAGE(B_int) & LF & 
							"B_sig    : " & INTEGER'IMAGE(TO_INTEGER(SIGNED(B_sig))) & LF & 
							"R_int    : " & INTEGER'IMAGE(R_int) & LF & 
							"R_beh    : " & INTEGER'IMAGE(TO_INTEGER(SIGNED(R_beh))) & LF & 
							"cout_exp : " &	STD_LOGIC'IMAGE(cout_exp) & LF &
							"Cout_beh : " & STD_LOGIC'IMAGE(cout_beh);
					assert (R_str = R_v and cout_str = cout_exp ) 	
					report 	"Structural fail" & LF &
							"A_int    : " & INTEGER'IMAGE(A_int) & LF &
							"A_sig    : " & INTEGER'IMAGE(TO_INTEGER(SIGNED(A_sig))) & LF &  
							"B_int    : " & INTEGER'IMAGE(B_int) & LF & 
							"B_sig    : " & INTEGER'IMAGE(TO_INTEGER(SIGNED(B_sig))) & LF & 
							"R_int    : " & INTEGER'IMAGE(R_int) & LF & 
							"R_str    : " & INTEGER'IMAGE(TO_INTEGER(SIGNED(R_str))) & LF &
							"cout_exp : " &	STD_LOGIC'IMAGE(cout_exp) & LF &
							"Cout_str : " & STD_LOGIC'IMAGE(cout_str);
					end loop;
			end loop;
		end loop; 
        wait;

    end process test;

end architecture behavioral;