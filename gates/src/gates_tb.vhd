library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity gates_tb is
end entity gates_tb;

architecture behavioral of gates_tb is

    component and2 is
        port (
            a_in  : in  std_logic;
            b_in  : in  std_logic;
            z_out : out std_logic
        );
    end component and2;

    signal a_sig  : std_logic := '0'; 
    signal b_sig  : std_logic := '0'; 
    signal z_and, z_or, z_xor, z_not, z_buf, z_nand, z_nor, z_xnor : std_logic; 
    constant DELTA_DELAY : time :=  11 ns;

begin
    uut_and2 : entity work.and2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_and );	 
    uut_or2 : entity work.or2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_or  );
    uut_xor2 : entity work.xor2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_xor );
    uut_nand2 : entity work.nand2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_nand);
    uut_nor2 : entity work.nor2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_nor );
    uut_xnor2 : entity work.xnor2(rtl)
        port map ( a_in  => a_sig, b_in  => b_sig, z_out => z_xnor);	
	uut_not  : entity work.not1(rtl)
        port map ( a_in  => a_sig, z_out => z_not );
    uut_buf  : entity work.buf1(rtl)
        port map ( a_in  => a_sig, z_out => z_buf );

    test : process
    begin
        a_sig <= '0';
        b_sig <= '0';
        wait for DELTA_DELAY;
        assert z_and = '0' report "and:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_and); 
		assert z_or  = '0' report "or :  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_or);
		assert z_xor = '0' report "xor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xor);  
		assert z_nand= '1' report "nand: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nand);
		assert z_nor = '1' report "nor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nor);
		assert z_xnor= '1' report "xnor: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xnor);
		assert z_not = '1' report "not:  input == " & std_logic'image(a_sig) &  ",  Output == " & std_logic'image(z_not);
		assert z_buf = '0' report "buf:  input == " & std_logic'image(a_sig) &  ",  Output == " & std_logic'image(z_buf);		

        a_sig <= '0';
        b_sig <= '1';
        wait for DELTA_DELAY;
        assert z_and = '0' report "and:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_and); 
		assert z_or  = '1' report "or :  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_or);
		assert z_xor = '1' report "xor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xor);  
		assert z_nand= '1' report "nand: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nand);
		assert z_nor = '0' report "nor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nor);
		assert z_xnor= '0' report "xnor: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xnor);

        a_sig <= '1';
        b_sig <= '0';
        wait for DELTA_DELAY;
        assert z_and = '0' report "and:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_and); 
		assert z_or  = '1' report "or :  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_or);
		assert z_xor = '1' report "xor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xor);  
		assert z_nand= '1' report "nand: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nand);
		assert z_nor = '0' report "nor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nor);
		assert z_xnor= '0' report "xnor: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xnor);
		assert z_not = '0' report "not:  input == " & std_logic'image(a_sig) &  ",  Output == " & std_logic'image(z_not);
		assert z_buf = '1' report "buf:  input == " & std_logic'image(a_sig) &  ",  Output == " & std_logic'image(z_buf);

        a_sig <= '1';
        b_sig <= '1';
        wait for DELTA_DELAY;
        assert z_and = '1' report "and:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_and); 
		assert z_or  = '1' report "or :  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_or);
		assert z_xor = '0' report "xor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xor);  
		assert z_nand= '0' report "nand: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nand);
		assert z_nor = '0' report "nor:  input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_nor);
		assert z_xnor= '1' report "xnor: input == " & std_logic'image(a_sig) & std_logic'image(b_sig) & ",  Output == " & std_logic'image(z_xnor);

        wait;

    end process test;

end architecture behavioral;