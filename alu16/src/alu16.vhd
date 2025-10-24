library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- subtraction:
--   a---------->adder
--   b---->inv----^	  
--  '1'-----------^	  

entity alu16 is
    port (
        A : 	 in STD_LOGIC_VECTOR(15 downto 0);
        B : 	 in STD_LOGIC_VECTOR(15 downto 0);
        S2: 	 in STD_LOGIC; 
		S1: 	 in STD_LOGIC;
		S0: 	 in STD_LOGIC;
        status : out STD_LOGIC_VECTOR(2 downto 0);	   --[OF, Z, N]
        R : 	 out STD_LOGIC_VECTOR(15 downto 0)
    );
end alu16;	   

architecture behavioral of alu16 is
begin
    process(all)	  
	variable a_var, b_var, r_var : STD_LOGIC_VECTOR(15 downto 0);	
	variable sel 		: STD_LOGIC_VECTOR(2 downto 0); 
	variable stat_var 	: STD_LOGIC_VECTOR(2 downto 0); 
	variable a_int, b_int, r_int, sel_int : INTEGER;
	begin
		sel := S2 & S1 & S0;  
		sel_int := TO_INTEGER(UNSIGNED(sel));
		a_int := TO_INTEGER(SIGNED(A));	
		b_int := TO_INTEGER(SIGNED(B));	   
		if 		sel_int = 0 then 
			r_int := a_int + b_int;
		elsif 	sel_int = 1 then 
			r_int := a_int * b_int;
		elsif 	sel_int = 2 then 
			r_int := a_int;
		elsif 	sel_int = 3 then 
			r_int := b_int;
		elsif 	sel_int = 4 then 
			r_int := a_int - b_int;
		else					
			r_int := 0;
		end if;	
		--status logic to do
		R <= STD_LOGIC_VECTOR(TO_SIGNED(r_int, 16));
	end process;
end architecture behavioral;	