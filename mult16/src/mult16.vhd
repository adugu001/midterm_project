library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library half_adder;	
library gates;	   	   
library full_adder;
use full_adder.all;
use half_adder.all;	
use gates.all;
entity mult16 is
    port (
        a_in     : in  std_logic_vector(15 downto 0);
        b_in     : in  std_logic_vector(15 downto 0);
        r_out    : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end entity mult16;

architecture behavioral of mult16 is
    signal a_signed          : signed(15 downto 0);
    signal b_signed          : signed(15 downto 0);
    signal mult_result_32bit : signed(31 downto 0);


    constant MIN_S16_VAL : signed(31 downto 0) := to_signed(-32768, 32);
    constant MAX_S16_VAL : signed(31 downto 0) := to_signed(32767, 32);

begin

    a_signed <= signed(a_in);
    b_signed <= signed(b_in);


    mult_result_32bit <= a_signed * b_signed;


    r_out <= std_logic_vector(mult_result_32bit(15 downto 0));

    overflow <= '1' when (mult_result_32bit < MIN_S16_VAL) or (mult_result_32bit > MAX_S16_VAL) else
                '0';

end architecture behavioral;

--architecture structural of mult16 is
--    -- Component for AND gate
--    component and2
--        port (
--            a_in  : in  std_logic;
--            b_in  : in  std_logic;
--            z_out : out std_logic
--        );
--    end component and2;
--
--    -- Component for Full Adder
--    component fullAdder
--        port (
--            a_in  : in  std_logic;
--            b_in  : in  std_logic;
--            c_in  : in  std_logic;
--            sum   : out std_logic;
--            c_out : out std_logic
--        );
--    end component fullAdder;
--
--    -- Signal array for the 256 partial products (a_in(i) AND b_in(j))
--    type pp_array is array (0 to 15, 0 to 15) of std_logic;
--    signal pp : pp_array;
--
--    type sum_array is array (0 to 15, 0 to 15) of std_logic;
--    type carry_array is array (0 to 15, 0 to 15) of std_logic;
--    signal s : sum_array;
--    signal c : carry_array;
--
--    -- Signals for the final 16-bit adder row (row 15)
--    signal last_row_s : std_logic_vector(15 downto 0);
--    signal last_row_c : std_logic_vector(15 downto 0);
--
--begin
--    GEN_PP : for j in 0 to 15 generate -- b_in (rows)
--        GEN_PP_ROW : for i in 0 to 15 generate -- a_in (cols)
--            U_AND2 : entity gates.and2(rtl)
--                port map (
--                    a_in  => a_in(i),
--                    b_in  => b_in(j),
--                    z_out => pp(i, j)
--                );
--        end generate GEN_PP_ROW;
--    end generate GEN_PP;
--
--
--    GEN_ADDER_ARRAY : for j in 1 to 15 generate -- 15 rows of adders
--       
--        U_FA_COL0 : entity full_adder.fullAdder(structural)
--            port map (
--                a_in  => pp(0, j),
--                b_in  => s(0, j - 1),
--                c_in  => '0',
--                sum   => s(0, j),
--                c_out => c(0, j)
--            );
--
--        -- Main Adder Grid (i = 1 to 14)
--        GEN_ADDER_ROW : for i in 1 to 14 generate
--            U_FA_GRID : entity full_adder.fullAdder(structural)
--                port map (
--                    a_in  => pp(i, j),      -- Partial product
--                    b_in  => s(i, j - 1),   -- Sum from row above
--                    c_in  => c(i - 1, j),   -- Carry from left
--                    sum   => s(i, j),
--                    c_out => c(i, j)
--                );
--        end generate GEN_ADDER_ROW;
--
--        U_FA_COL_LAST : entity full_adder.fullAdder(structural)
--            port map (
--                a_in  => pp(15, j),
--                b_in  => s(15, j - 1),
--                c_in  => c(14, j),
--                sum   => last_row_s(j),
--                c_out => last_row_c(j)  
--            );
--
--    end generate GEN_ADDER_ARRAY;
--    r_out(0) <= pp(0, 0);
--
--    -- r_out(1) to r_out(14) are the sum outputs from the first column of adders
--    GEN_SUM_OUTS : for k in 1 to 14 generate
--        r_out(k) <= s(0, k);
--    end generate GEN_SUM_OUTS;
--
--    -- r_out(15) is the sum from the last "first column" adder
--    r_out(15) <= s(0, 15);
--
--    -- This is a 16-bit ripple-carry adder
--    GEN_FINAL_ADDER : for k in 1 to 15 generate
--        U_FA_FINAL : entity full_adder.fullAdder(structural)
--            port map (
--                a_in  => last_row_s(k),
--                b_in  => c(k - 1, 15),
--                c_in  => last_row_c(k - 1),
--                sum   => r_out(k + 15),
--                c_out => last_row_c(k)
--            );
--    end generate GEN_FINAL_ADDER;
--
--    U_FA_FINAL_0 : entity full_adder.fullAdder(structural)
--        port map (
--            a_in  => s(15, 0), 
--            b_in  => c(14, 15),
--            c_in  => '0',
--            sum   => r_out(16),
--            c_out => last_row_c(0)
--        );
--        
--    -- Final carry bit
--    r_out(31) <= last_row_c(15);
--
--end architecture structural;