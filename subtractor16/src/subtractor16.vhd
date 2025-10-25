library ieee;
library adder16;
library gates;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use adder16.all;
use gates.all;						      

entity subtractor16 is
    port (
        A 		: in  STD_LOGIC_VECTOR(15 downto 0);
        B 		: in  STD_LOGIC_VECTOR(15 downto 0);										  
        R 		: out STD_LOGIC_VECTOR(15 downto 0);
        c_out	: out STD_LOGIC
    );
end subtractor16;

architecture behavioral of subtractor16 is
begin
    beh_process: process (all)
	    variable A_int, B_int, c_int, R_int : INTEGER;
		variable R_v : STD_LOGIC_VECTOR(16 downto 0);
    begin 
		--convert to int
        A_int := TO_INTEGER(SIGNED(A));
        B_int := TO_INTEGER(SIGNED(B));   
		--calc
        R_int := A_int - B_int;
		R_v   := STD_LOGIC_VECTOR(TO_SIGNED(R_int,17)); 
		--assign
		c_out <=  R_v(16);
        R     <= R_v(15 downto 0);
    end process;
end architecture behavioral;	   

architecture structural of subtractor16 is
signal not_b : STD_LOGIC_VECTOR(15 downto 0);  
begin  	   
	--invert B
	GEN: for i in 0 to 15 generate				 --1 gate deep so crit path = 10ns
		u0_not: entity gates.not1(rtl)		 
        	port map ( 
				a_in  => B(i), 
				z_out => not_b(i)
			);	
	end generate;  
	
	--set c_in = 1  and inverted b to take 2's compliment
	u1: entity adder16.adder16(structural)	--crit == 650ns	 
    	port map ( 
			A     => A, 
			B     => not_b, 
			c_in  => '1', 
			R     => R, 
			c_out => c_out
		);	
end architecture structural;
