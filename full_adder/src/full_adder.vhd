library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fullAdder is
    port (
        a_in : in std_logic;
        b_in : in std_logic;
        c_in: in std_logic;
        sum: out std_logic;
        c_out: out std_logic
    );
end fullAdder;

architecture behavioral of fullAdder is
begin
    sum <= a_in xor b_in xor c_in;
    c_out <= (a_in and b_in) or (c_in and (a_in xor b_in));
end architecture behavioral;	 

architecture structural of fullAdder is		  
begin
    uut_xor1 : entity work.and2(rtl)				 
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_and );	 
    uut_xor2 : entity work.or2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_or  );
    uut_xor3 : entity work.xor2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_xor );
	uut_and1 : entity work.and2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_and );	 
    uut_and2 : entity work.or2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_or  );
    uut_or1 : entity work.xor2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_xor );
end architecture structural;