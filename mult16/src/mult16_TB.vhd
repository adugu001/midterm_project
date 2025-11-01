library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult16_tb is
end entity mult16_tb;

architecture test of mult16_tb is
    -- Component for the Unit Under Test (UUT)
    component mult16
        port (
            a_in     : in  std_logic_vector(15 downto 0);
            b_in     : in  std_logic_vector(15 downto 0);
            r_out    : out std_logic_vector(15 downto 0);
            overflow : out std_logic
        );
    end component mult16;

    -- Testbench signals
    signal s_a_in     : std_logic_vector(15 downto 0) := (others => '0');
    signal s_b_in     : std_logic_vector(15 downto 0) := (others => '0');
    signal s_r_out    : std_logic_vector(15 downto 0) := (others => '0');
    signal s_overflow : std_logic := '0';

begin
    -- Instantiate the UUT
    uut_mult16 : mult16
        port map (
            a_in     => s_a_in,
            b_in     => s_b_in,
            r_out    => s_r_out,
            overflow => s_overflow
        );

    -- Stimulus process to test 128 * 128
    stim_proc : process
    begin
        report "Starting testbench for 128 * 128...";

        -- Set initial values
        s_a_in <= (others => '0');
        s_b_in <= (others => '0');
        wait for 100 ns; -- Wait for signals to settle at 0

        -- Apply the test vectors
        -- A = 128 (x"0080")
        s_a_in <= std_logic_vector(to_signed(128, 16));
        
        -- B = 128 (x"0080")
        s_b_in <= std_logic_vector(to_signed(128, 16));
        
        -- Wait for the simulation to run long enough to see the result
        wait for 500 ns; 

        -- Check the result
        -- 128 * 128 = 16384 (x"4000"). This is not an overflow.
        assert (s_r_out = X"4000") 
            report "Test 128*128: r_out failed. Expected x""4000""" severity error;
        assert (s_overflow = '0') 
            report "Test 128*128: overflow failed. Expected '0'" severity error;
        
        report "Testbench finished. Check waveform for 128 * 128 = 16384 (x""4000"")";
        wait; -- Stop simulation
    end process stim_proc;

end architecture test;