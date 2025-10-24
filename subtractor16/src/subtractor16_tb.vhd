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
    signal cout_beh, cc : STD_LOGIC;  	 
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
    begin
		for i in 0 to 20 loop	
			for j in 0 to 10 loop	
				--POS - POS
				R_int   := i - j;
				--assign
				A_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(i, 16));
				B_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(j, 16));
				wait for DELTA_DELAY; 
				-- assert
				assert (TO_INTEGER(SIGNED(R_beh)) = R_int) report "behavioral fail";
				assert (TO_INTEGER(SIGNED(R_str)) = R_int) report "structural fail"; 
				
				--POS - NEG
				R_int   := i - (-j);
				--assign
				A_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(i, 16));
				B_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(j, 16));
				wait for DELTA_DELAY; 
				-- assert
				assert (TO_INTEGER(SIGNED(R_beh)) = R_int) report "behavioral fail";
				assert (TO_INTEGER(SIGNED(R_str)) = R_int) report "structural fail"; 
				
				--NEG - POS
				R_int   := (-i) - j;
				--assign
				A_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(i, 16));
				B_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(j, 16));
				wait for DELTA_DELAY; 
				-- assert
				assert (TO_INTEGER(SIGNED(R_beh)) = R_int) report "behavioral fail";
				assert (TO_INTEGER(SIGNED(R_str)) = R_int) report "structural fail"; 
				
				-- NEG - NEG
				R_int   := (-i) - (-j);
				--assign
				A_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(i, 16));
				B_sig   <= STD_LOGIC_VECTOR(TO_SIGNED(j, 16));
				wait for DELTA_DELAY; 
				-- assert
				assert (TO_INTEGER(SIGNED(R_beh)) = R_int) report "behavioral fail";
				assert (TO_INTEGER(SIGNED(R_str)) = R_int) report "structural fail"; 			

			end loop;
		end loop;
        --put test here

        wait;

    end process test;

end architecture behavioral;