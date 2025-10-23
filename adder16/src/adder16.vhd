library ieee;
library full_adder;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use full_adder.all;

entity adder16 is
    port (
        a_in : in STD_LOGIC_VECTOR(15 downto 0);
        b_in : in STD_LOGIC_VECTOR(15 downto 0);
        c_in: in std_logic;
        sum: out STD_LOGIC_VECTOR(15 downto 0);
        c_out: out std_logic
    );
end adder16;

architecture behavioral of adder16 is
begin
    beh_process: process (a_in, b_in, c_in)
    variable a, b, c : integer;
    variable sum_v : integer; 
	variable sum_slv : std_logic_vector(16 downto 0);
    begin
        a := to_integer(unsigned(a_in));
        b := to_integer(unsigned(b_in));   
		c := to_integer(unsigned('0'&c_in));
        sum_v := a + b + c;
		sum_slv := Std_Logic_Vector(to_unsigned(sum_v,17));   
		c_out <=  sum_slv(16);
        sum <= sum_slv(15 downto 0);
    end process;
end architecture behavioral;	   

architecture structural of adder16 is
signal CARRY : std_logic_vector(16 downto 0);  
--fa crit path = 40ns 
--16 full adders in series
--crit path = 16*40ns = 640ns
begin
	CARRY(0) <= c_in;
	c_out <= CARRY(16);
	GEN1: for i in 15 downto 0 generate					 
		fa: entity full_adder.fullAdder(structural)		 
        	port map ( 
				a_in  => a_in(i), 
				b_in  => b_in(i), 
				c_in => CARRY(i), 
				sum => sum(i), 
				c_out => CARRY(i+1)
			);	
	end generate GEN1;
end architecture structural;
