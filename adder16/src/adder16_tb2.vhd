library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder16_tb is
end entity adder16_tb;

architecture test of adder16_tb is
    -- Component for the Unit Under Test (UUT)
    component adder16
        port (
            A     : in  std_logic_vector(15 downto 0);
            B     : in  std_logic_vector(15 downto 0);
            c_in  : in  std_logic;
            R     : out std_logic_vector(15 downto 0);
            c_out : out std_logic
        );
    end component adder16;

    -- Testbench signals
    signal s_A     : std_logic_vector(15 downto 0) := (others => '0');
    signal s_B     : std_logic_vector(15 downto 0) := (others => '0');
    signal s_c_in  : std_logic := '0';
    -- Initialize outputs to '0' to avoid 'U' in simulation
    signal s_R     : std_logic_vector(15 downto 0) := (others => '0');
    signal s_c_out : std_logic := '0';

begin
    -- Instantiate the UUT
    uut_adder16 : adder16
        port map (
            A     => s_A,
            B     => s_B,
            c_in  => s_c_in,
            R     => s_R,
            c_out => s_c_out
        );

    -- Stimulus process to test 1000 + 2000
    stim_proc : process
    begin
        report "Starting testbench for 1000 + 2000...";

        -- Set initial values
        s_A <= (others => '0');
        s_B <= (others => '0');
        s_c_in <= '0';
        wait for 100 ns; -- Wait for signals to settle at 0

        -- Apply the test vectors
        -- A = 1000 (which is x"03E8" or "0000001111101000")
        s_A <= std_logic_vector(to_unsigned(1000, 16));
        
        -- B = 2000 (which is x"07D0" or "0000011111010000")
        s_B <= std_logic_vector(to_unsigned(2000, 16));
        
        -- c_in remains '0' for a standard addition
        s_c_in <= '0';

        -- Wait for the simulation to run long enough to see the result
        -- The structural adder is combinational, but the delay is
        -- what you need to measure.
        wait for 500 ns; 

        -- Optional: Test with c_in = '1'
        -- s_c_in <= '1';
        -- wait for 500 ns;
        
        report "Testbench finished. Check waveform for 1000 + 2000 = 3000 (x0BB8)";
        wait; -- Stop simulation
    end process stim_proc;

end architecture test;

