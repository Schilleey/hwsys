library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_TB is
end PC_TB;


architecture TESTBENCH of PC_TB is

 -- Component declaration
  component PC is
    port (clk, reset, inc, load: in std_logic; 
		pc_in: in std_logic_vector (15 downto 0); 
		pc_out: out std_logic_vector (15 downto 0));
  end component;

  -- Configuration...
  for IMPL: PC use entity WORK.PC(RTL);

  -- Internal signals...
  signal clk, reset, inc, load: std_logic; 
  signal pc_in, pc_out: std_logic_vector (15 downto 0); 

begin
  -- Instantiate PC
  IMPL: PC port map (clk => clk, reset => reset, inc => inc, load => load, pc_in => pc_in, pc_out => pc_out);

  -- Main process...
  process
  
  procedure run_cycle is
	variable period: time := 10 ns;
	begin
		clk <= '0'; -- 'clk' ist ein global deklariertes Signal
	wait for period / 2;
		clk <= '1';
	wait for period / 2;
  end procedure;
  
  begin
 
  -- Test Load --
    -- load = 1  
    pc_in <= "1010101010101010"; load <= '1'; 
    run_cycle;
    assert pc_out = "1010101010101010" report "load does not set to 1010101010101010";

    -- load = 1 and inc = 1 (should load be stronger?) actually this shouldnt happen..    
    pc_in <= "0101010101010101"; load <= '1'; inc <= '1';
    run_cycle; 
    assert pc_out = "0101010101010101" report "load does not set to 0101010101010101";
 
    -- load = 0 dont load, return last loaded pc_in
    pc_in <= "0000000000000000"; load <= '0'; inc <= '0';
	run_cycle;
	assert pc_out = "0101010101010101" report "load does not set to 0101010101010101";

  -- Test Reset --
    -- reset = 1 has to be stronger than everything
    reset <= '1'; load <= '1'; inc <= '1'; pc_in <= "1111111111111111";
    run_cycle;
    assert pc_out = "0000000000000000" report "reset does not set to 0000000000000000";

    -- reset = 0
	pc_in <= "1111111111111111"; load <= '1'; reset <= '0';
    run_cycle; 
    assert pc_out = "1111111111111111" report "reset does not set to 0000000000000000";


 -- Test Increase --  
    -- reset before test
    reset <= '1'; load <= '0'; inc <= '0';
    run_cycle;
    -- increase = 1
    inc <= '1'; reset <= '0';  
    run_cycle;
    assert pc_out = "0000000000000001" report "inc does not set to 0000000000000001";
    
    -- increase with pc_in but without load = 1
    pc_in <= "1111111111111111"; inc <= '1'; 
    run_cycle;
    assert pc_out = "0000000000000010" report "inc does not set to 0000000000000010";

    -- load highest number then increase    
    pc_in <= "1111111111111111"; load <= '1'; 
    run_cycle;
    inc <= '1'; load <= '0';
    run_cycle; 
    assert pc_out = "0000000000000000" report "inc does not set to 0000000000000000";

  -- Test Memory
    -- load number then wait some cycles
    pc_in <= "1111111111111111"; load <= '1'; inc <= '0';
    run_cycle;
    pc_in <= "1111111111111111"; load <= '0'; inc <= '0'; reset <= '0';
    for i in 0 to 5 loop
		run_cycle;
	end loop;
    assert pc_out = "1111111111111111" report "after cycles without changes does not return 1111111111111111";

 -- Print a note & finish simulation now
    assert false report "Simulation finished" severity note;
    wait;               -- end simulation

  end process;

end architecture;
