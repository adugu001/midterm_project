library ieee; 
library mux16;
library adder16;
library subtractor16;
library mult16;
use mux16.all;
use adder16.all;
use subtractor16.all;
use mult16.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu16 is
    port (
        A : 	 in STD_LOGIC_VECTOR(15 downto 0);
        B : 	 in STD_LOGIC_VECTOR(15 downto 0);
        S2: 	 in STD_LOGIC; 
		S1: 	 in STD_LOGIC;
		S0: 	 in STD_LOGIC;
        status : out STD_LOGIC_VECTOR(2 downto 0);	   --[V, Z, N]
        R : 	 out STD_LOGIC_VECTOR(15 downto 0)
    );
end alu16;	   

architecture behavioral of alu16 is
begin
    process(all)	  			   
	variable r_var : STD_LOGIC_VECTOR(16 downto 0);
	variable a_var, b_var : STD_LOGIC_VECTOR(15 downto 0);	
	variable sel, ABR	: STD_LOGIC_VECTOR(2 downto 0); 
	variable a_int, b_int, r_int, sel_int : INTEGER;	
	variable v_flag, z_flag, n_flag : STD_LOGIC;
	begin	 
		-- CAST SIGNALS
		sel 	:= S2 & S1 & S0;  
		sel_int := TO_INTEGER(UNSIGNED(sel));
		A_var := A;	
		B_var := B;
		a_int 	:= TO_INTEGER(SIGNED(A));	
		b_int 	:= TO_INTEGER(SIGNED(B));
		
		-- DO APPROPRIATE CALC BASED ON SELECT INPUTS
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
		r_var := STD_LOGIC_VECTOR(TO_UNSIGNED(r_int mod 2**17, 17));
		
		-- STATUS FLAG LOGIC	 
		if r_var(15) = '1' then n_flag := '1'; 
		else n_flag := '0';	   
		end if;
		
		if r_var(15 downto 0) = X"0000" then z_flag := '1';
		else z_flag := '0';	
		end if;
		
		if sel_int = 0 then	
			ABR := A_var(15)&B_var(15)&R_var(15);
			if ABR = "001" or ABR = "110" then v_flag := '1';
			else v_flag := '0';
			end if;
		elsif sel_int = 1 then
			--mult v flag logic	
		elsif sel_int = 4 then
			ABR := A_var(15)&B_var(15)&R_var(15);
			if ABR = "011" or ABR = "100" then v_flag := '1';
			else v_flag := '0';
			end if;	
		else v_flag := '0';
		end if;
		
	    status <= v_flag & z_flag & n_flag;
		R <= r_var(15 downto 0);
	end process;
end architecture behavioral;	

architecture structural of alu16 is	
signal R_adder, R_mult, R_sub, R_sig : STD_LOGIC_VECTOR(15 downto 0); 
signal sel_sig : STD_LOGIC_VECTOR(2 downto 0);	 
signal cout_adder, cout_sub, OF_mult : STD_LOGIC;
signal V_adder, V_sub, V_mult : STD_LOGIC;
signal V_flag, Z_flag, N_flag: STD_LOGIC;
begin	   
	-- CAST SELECT LINES TO A VECTOR
	sel_sig <= S2 & S1 & S0;							  
	
	-- INTANTIATE MUX. DELAY_MUX = 0
	MUXES : entity mux16.mux16(structural)
        port map ( 	  
		        sel 	=> sel_sig,
		        a0 		=> R_adder,
		        a1 		=> R_mult,
		        a2 		=> A,
		        a3 		=> B,
		        a4 		=> R_sub,
		        a5 		=> X"0000",
		        a6 		=> X"0000",
		        a7 		=> X"0000",
		        R 		=> R_sig );
	
	-- INSTANTIATE ADD UNIT. DELAY_ADD = 640
	ADD_UNIT : entity adder16.adder16(structural)
        port map ( A  => A, B => B, c_in => '0', R => R_adder, c_out => cout_adder);
	
	-- INSTANTIATE SUB UNIT. DELAY_SUB = 650
	SUB_UNIT : entity subtractor16.subtractor16(structural)
        port map ( A => A, B => B, R => R_sub, c_out => cout_sub);
	
	-- INSTANTIATE MULT UNIT. DELAY_MUL = ============================TO DO
	MUL_UNIT : entity mult16.mult16(behavioral)   --==================CHANGE TO STR
		port map ( a_in => A, b_in => B, r_out => R_mult, overflow => OF_mult);	 
		
	-- OVERFLOW FLAG LOGIC. V_CALC_DELAY = 3 GATE LEVELS = 30ns 	
	V_adder <=  ((A(15) AND B(15) AND (NOT R_adder(15)) ) OR   				  -- overflow if A(15)'B(15)'R(15) + A(15)B(15)R(15)'
				((NOT A(15)) AND (NOT B(15)) AND R_adder(15) )) after 30ns; 
	V_sub   <=  (((NOT A(15)) AND B(15) AND R_sub(15) ) OR   				  -- overflow if A(15)'B(15)R(15)  + A(15)B(15)'R(15)' 
				(A(15) AND (NOT B(15)) AND (NOT R_sub(15)))) after 30ns;	   
	V_mult <= OF_mult;	  
	
	-- LOGIC TO SELECT **WHICH** OVERFLOW FLAG. V_SEL_DELAY = 3 GATE LEVELS = 30ns
	V_flag <= 	(( V_adder AND (not S2) AND (NOT S1) AND (NOT S0)) OR    --S2'S1'S0' == ADDITION
				( V_mult  AND (not S2) AND (NOT S1) AND S0) OR 		     --S2'S1'S0  == MULTIPLICATION
				( V_flag  AND S2 AND (NOT S1) AND (NOT S0))) after 30ns; --S2 S1'S0' == SUBTRACTION
	
	-- Z AND N FLAG LOGIC
	Z_flag <= '1' when R_sig = X"0000" else '0';
	N_flag <= R_sig(15);		
	
	-- ASSIGN FINAL OUTPUTS
	R <= R_sig;
	status <= V_flag & Z_flag & N_flag;  
	
	-- TO DO!!!!! NEED DELAY OF MULT16!!!
	-- FINAL DELAY = MAX(adder, mult, sub) + V_calc_delay + V_sel_delay = MAX(mult, 650) + 60 ns

end architecture structural;