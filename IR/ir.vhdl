library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity IR is
  port ( clk: in std_logic;
         load: in std_logic;
         ir_in: in std_logic_vector (15 downto 0);
         ir_out: out std_logic_vector (15 downto 0)
       );
end IR;


architecture RTL of IR is
  signal state: std_logic_vector (15 downto 0);
begin

  -- Output function...
  ir_out <= std_logic_vector(state);

  -- State transition function...
  process(clk)
  begin
    if rising_edge(clk) then
      if (load = '1') then state <= ir_in; end if;
    end if;
  end process;

end RTL;
