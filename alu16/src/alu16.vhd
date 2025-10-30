library ieee; 
library mux;
library adder16;
library subtractor16;
library mult16;
use mux.all;
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
	
	-- GENERATE ARRAY OF MUX TO SPECIFY WHICH CALCULATION TO PROPOGATE
	GEN_OUTPUT_MUX : for i in 0 to 15 generate
		THE_MUX: entity mux.mux8(behavioral)		 
        	port map(
		        sel 	=> sel_sig,
		        a0 		=> R_adder(i),
		        a1 		=> R_mult(i),
		        a2 		=> A(i),
		        a3 		=> B(i),
		        a4 		=> R_sub(i),
		        a5 		=> '0',
		        a6 		=> '0',
		        a7 		=> '0',
		        z_out 	=> R_sig(i)
		    );
	end generate;
	
    -- 1. OVERFLOW FLAG (V)
    -- Calculate overflow for each operation that can have one
    V_adder <= (A(15) and B(15) and (not R_adder(15))) or
               ((not A(15)) and (not B(15)) and R_adder(15)); -- No delay needed here, let gates propagate
    
    V_sub <= ((not A(15)) and B(15) and R_sub(15)) or
             (A(15) and (not B(15)) and (not R_sub(15)));
    
    V_mult <= OF_mult;
    -- Select the correct overflow flag based on sel_sig
    -- This is a multiplexer for the V_flag.
    V_flag <= (V_adder and (not S2) and (not S1) and (not S0)) or -- "000" = ADD
              (V_mult and (not S2) and (not S1) and S0) or     -- "001" = MULT
              (V_sub and S2 and (not S1) and (not S0)) after 30ns;     -- "100" = SUB
    -- All other combinations result in V_flag = '0', which is correct.
    -- *** This line was the main error in your code. ***
    -- 2. ZERO FLAG (Z)
    -- Z is '1' if the final result R_sig is all zeros
    Z_flag <= '1' when R_sig = ZEROS_16 else '0';
    -- 3. NEGATIVE FLAG (N)
    -- N is the most significant bit of the final result
    N_flag <= R_sig(15);
    -- ASSIGN FINAL OUTPUTS
    R      <= R_sig;
    status <= V_flag & Z_flag & N_flag;
	
	-- TO DO!!!!! NEED DELAY OF MULT16!!!
	-- FINAL DELAY = MAX(adder, mult, sub) + V_calc_delay + V_sel_delay = MAX(mult, 650) + 60 ns  
	
end architecture structural;