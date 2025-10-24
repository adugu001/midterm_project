library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux8 is
    port (
        sel : in  std_logic_vector(2 downto 0);
        a0 : in std_logic;
        a1 : in std_logic;
        a2 : in std_logic;
        a3 : in std_logic;
        a4 : in std_logic;
        a5 : in std_logic;
        a6 : in std_logic;
        a7 : in std_logic;
        z_out : out std_logic
    );
end mux8;

architecture rtl of mux8 is

begin
z_out <=    a0 when sel = "000" else 
            a1 when sel = "001" else
            a2 when sel = "010" else
            a3 when sel = "011" else
            a4 when sel = "100" else 
            a5 when sel = "101" else
            a6 when sel = "110" else
            a7 when sel = "111";
end architecture rtl;