library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xor3 is
    port (
        a_in : in  std_logic;
        b_in : in  std_logic;
        c_in : in  std_logic;
        z_out: out std_logic
    );
end xor3;

architecture rtl of xor3 is

begin
    z_out <= a_in xor b_in xor c_in after 10ns;
end architecture rtl;