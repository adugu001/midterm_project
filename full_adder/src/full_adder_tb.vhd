library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity full_adder_tb is
end entity full_adder_tb;

architecture behavioral of full_adder_tb is

    signal a_b_cin    : std_logic_vector(2 downto 0) := "000"; 
    signal cout_sig_beh : std_logic;
	signal sum_sig_beh  : std_logic; 
	signal cout_sig_str : std_logic;
	signal sum_sig_str  : std_logic;
    constant DELTA_DELAY : time :=  41 ns;	 --critical path + 1ns

begin
    uut_fa1 : entity work.full_adder(behavioral)
        port map ( a_in  => a_b_cin(0), b_in  => a_b_cin(1), c_in => a_b_cin(2), sum => sum_sig_beh, c_out => cout_sig_beh);	 
    uut_fa2 : entity work.full_adder(structural)
        port map ( a_in  => a_b_cin(0), b_in  => a_b_cin(1), c_in => a_b_cin(2), sum => sum_sig_str, c_out => cout_sig_str);
    test : process	
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
			a_b_cin <= abc_var;
			-- wait for delay
			wait for DELTA_DELAY;
			assert ((cout_sig_beh = c_out_var) and (sum_sig_beh  = sum_var)) 
				report "[BEH] : input : " & a_b_cin'image & "  sum : " & sum_sig_beh'image & "  cout : " & cout_sig_beh'image;
			assert ((cout_sig_str = c_out_var) and (sum_sig_str  = sum_var)) 
				report "[STR] : input : " & a_b_cin'image & "  sum : " & sum_sig_str'image & "  cout : " & cout_sig_str'image;	
		end loop;	     
        wait;
    end process test;
end architecture behavioral;