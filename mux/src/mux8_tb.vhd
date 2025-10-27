library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity mux8_tb is
end entity mux8_tb;

architecture behavioral of mux8_tb is
--SIGNAL DECLARATIONS
	--input
    signal inputs   : STD_LOGIC_VECTOR(7 downto 0) := X"01"; 
    signal sel_sig  : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');   
	--outputs
    signal z_sig    : STD_LOGIC;
    constant DELTA_DELAY : time :=  0ns;

begin	
	uut : entity work.mux8(behavioral)
        port map ( 	  
			sel => sel_sig,
			a0 => inputs(0), 
			a1 => inputs(1),
			a2 => inputs(2),
			a3 => inputs(3),
			a4 => inputs(4),
			a5 => inputs(5),
			a6 => inputs(6),
			a7 => inputs(7),
			z_out => z_sig
		);	   

    test : process	
	variable input_v : STD_LOGIC_VECTOR(7 downto 0) := X"01";
    begin	   
		THE_LOOP : for i in 0 to 7 loop
			sel_sig <= STD_LOGIC_VECTOR(TO_UNSIGNED(i,3));
			inputs <= input_v sll i;
			wait for DELTA_DELAY;
			assert z_sig = '1' report "FAIL"; 
		end loop;
        wait;

    end process test;

end architecture behavioral;