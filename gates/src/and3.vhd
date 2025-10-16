library ieee;
use ieee.std_logic_1164.all;

entity and3 is
    port (
        a_in : in  std_logic;
        b_in : in  std_logic;
        c_in : in  std_logic;
        z_out: out std_logic
    );
end entity and3;

architecture rtl of and3 is
begin
    z_out <= a_in and b_in and c_in after 10ns;
end architecture rtl;