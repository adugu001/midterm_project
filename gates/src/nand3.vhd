library ieee;
use ieee.std_logic_1164.all;

entity nand3 is
    port (
        a_in : in  std_logic;
        b_in : in  std_logic;
        c_in : in  std_logic;
        z_out: out std_logic
    );
end entity nand3;

architecture rtl of nand3 is
begin
    z_out <= not (a_in and b_in and c_in) after 10ns;
end architecture rtl;