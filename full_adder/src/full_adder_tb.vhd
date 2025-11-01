library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity full_adder_tb is
end entity full_adder_tb;

architecture behavioral of fullAdder is

    signal a, b, cin    : std_logic; 
    signal cout_sig_beh : std_logic;
	signal sum_sig_beh  : std_logic; 
	signal cout_sig_str : std_logic;
	signal sum_sig_str  : std_logic;
    constant DELTA_DELAY : time :=  41 ns;	 --critical path + 1ns

begin
    uut_fa1 : entity work.fullAdder(behavioral)
        port map ( a_in  => a, b_in  => b, c_in => cin, sum => sum_sig_beh, c_out => cout_sig_beh);	 
    uut_fa2 : entity work.fullAdder(structural)
        port map ( a_in  => a, b_in  => b, c_in => cin, sum => sum_sig_str, c_out => cout_sig_str);
    test : process	 
	variable a_var : std_logic := '0';
	variable c_out_var : std_logic;
	variable sum_var   : std_logic;  
	variable abc_var   : std_logic_vector(2 downto 0) := "000";
    begin	   
		for i in 0 to 7 loop	   
			-- set variables to correct input and output
			abc_var   := std_logic_vector(to_unsigned(i, abc_var'length));
			c_out_var := (abc_var(0) and abc_var(1)) or (abc_var(2) and (abc_var(0) xor abc_var(1)));
			sum_var   := abc_var(0) xor abc_var(1) xor abc_var(2); 
			-- assign variables to input signals
			a   <= abc_var(2);
			b   <= abc_var(1);			 
			cin <= abc_var(0);
			-- wait for delay
			wait for DELTA_DELAY;
			assert ((cout_sig_str = c_out_var) and (sum_sig_str  = sum_var)) 
			report "Failure on Structural Model: " & LF &
			       "a | b | cin | sum | cout " & LF &
			       std_logic'image(a)           & " | " & 
			       std_logic'image(b)           & " | " & 
			       std_logic'image(cin)         & " | " & 
			       std_logic'image(sum_sig_str) & " | " & 
			       std_logic'image(cout_sig_str);	  
			assert ((cout_sig_beh = c_out_var) and (sum_sig_beh  = sum_var)) 
			report "Failure on Behavioral Model: " & LF &
			       "a | b | cin | sum | cout " & LF &
			       std_logic'image(a)           & " | " & 
			       std_logic'image(b)           & " | " & 
			       std_logic'image(cin)         & " | " & 
			       std_logic'image(sum_sig_beh) & " | " & 
			       std_logic'image(cout_sig_beh);
		end loop;	     
        wait;
    end process test;
end architecture behavioral;