library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity IR_TB is
end IR_TB;


architecture BEHAVIORAL of IR_TB is

  -- Component declaration
  component IR is
    port ( clk: in std_logic;
           load: in std_logic;
           ir_in: in std_logic_vector (15 downto 0);
           ir_out: out std_logic_vector (15 downto 0)
         );
  end component;

  -- Configuration
  for U_IR: IR use entity WORK.IR(RTL);

  -- Clock period
  constant period: time := 10 ns;

  -- Signals
  signal clk, load: std_logic;
  signal ir_in, ir_out: std_logic_vector (15 downto 0);

begin

  -- Instantiate instruction register...
  U_IR : IR port map (
    clk => clk, load => load, ir_in => ir_in, ir_out => ir_out
  );

  -- Process for applying patterns
  process

    -- Helper to perform one clock cycle...
    procedure run_cycle is
    begin
      clk <= '0';
      wait for period / 2;
      clk <= '1';
      wait for period / 2;
    end procedure;

    variable n: integer;

  begin

    -- Play with uninitialized state (may reveal design errors in specification)...
    for n in 1 to 2 loop run_cycle; end loop;
    load <= '0';
    for n in 1 to 2 loop run_cycle; end loop;
    -- output must be all-'U' or all-'X' until now
    assert ir_out = "UUUUUUUUUUUUUUUU" or ir_out = "XXXXXXXXXXXXXXXX" report "Something seems to be initialized";
    
    -- Load into ir...
    load <= '1';
    ir_in <= "0000000000000001";
    run_cycle;
    assert ir_out = "0000000000000001" report "Loading a value into ir does not work.";
    
    -- Register check...
    load <= '0';
    run_cycle;
    assert ir_out = "0000000000000001" report "IR value is not correct.";
    
    -- Change register value...
    load <= '1';
    ir_in <= "0000000000010101";
    run_cycle;
    assert ir_out = "0000000000010101" report "Changing ir value does not work.";
    
    -- Register check...
    load <= '0';
    run_cycle;
    assert ir_out = "0000000000010101" report "IR value is not correct.";

    -- Finish: stop simulator
    wait;

  end process;

end BEHAVIORAL;

