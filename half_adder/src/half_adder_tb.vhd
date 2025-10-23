library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity full_adder_tb is
end entity full_adder_tb;

architecture behavioral of full_adder_tb is

    signal a, b    : std_logic; 
    signal cout_sig_beh : std_logic;
	signal sum_sig_beh  : std_logic; 
	signal cout_sig_str : std_logic;
	signal sum_sig_str  : std_logic;
    constant DELTA_DELAY : time :=  21 ns;	 --critical path + 1ns

begin
    uut_fa1 : entity work.halfAdder(behavioral)
        port map ( a_in  => a, b_in  => b, sum => sum_sig_beh, c_out => cout_sig_beh);	 
    uut_fa2 : entity work.halfAdder(structural)
        port map ( a_in  => a, b_in  => b, sum => sum_sig_str, c_out => cout_sig_str);	  
		
    test : process	 
	variable c_out_var : std_logic;
	variable sum_var   : std_logic;  
	variable ab_var   : std_logic_vector(1 downto 0) := "00";
    begin	   
		for i in 0 to 3 loop	   
			-- set variables to correct input and output
			ab_var   := std_logic_vector(to_unsigned(i, ab_var'length));
			c_out_var := ab_var(0) and ab_var(1);
			sum_var   := ab_var(0) xor ab_var(1); 
			-- assign variables to input signals
			a   <= ab_var(1);
			b   <= ab_var(0);			 
			-- wait for delay
			wait for DELTA_DELAY;
			assert ((cout_sig_str = c_out_var) and (sum_sig_str  = sum_var)) 
			report "Failure on Structural Model: " & LF &
			       "a | b | sum | cout " & LF &
			       std_logic'image(a)           & " | " & 
			       std_logic'image(b)           & " | " &  
			       std_logic'image(sum_sig_str) & " | " & 
			       std_logic'image(cout_sig_str);	  
			assert ((cout_sig_beh = c_out_var) and (sum_sig_beh  = sum_var)) 
			report "Failure on Behavioral Model: " & LF &
			       "a | b | sum | cout " & LF &
			       std_logic'image(a)           & " | " & 
			       std_logic'image(b)           & " | " & 
			       std_logic'image(sum_sig_beh) & " | " & 
			       std_logic'image(cout_sig_beh);
		end loop;	     
        wait;
    end process test;
end architecture behavioral;