library ieee;
use ieee.std_logic_1164.all;

entity or3 is
    port (
        a_in : in  std_logic;
        b_in : in  std_logic;
        c_in : in  std_logic;
        z_out: out std_logic
    );
end entity or3;

architecture rtl of or3 is
begin
    z_out <= a_in or b_in or c_in after 10ns;
end architecture rtl;