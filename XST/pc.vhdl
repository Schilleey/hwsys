library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC is
	port (
		clk: in std_logic;
		reset, inc, load: in std_logic;
		pc_in: in std_logic_vector (15 downto 0);
		pc_out: out std_logic_vector (15 downto 0)
);
end PC;


architecture RTL of PC is
	signal counter: unsigned (15 downto 0);
begin

	pc_out <= std_logic_vector(counter);

	process (clk) --, reset, inc, load, pc_in)
	begin

	if rising_edge(clk) then
		if(reset = '1') then
			counter <= "0000000000000000";
		else
			if(inc = '1') then
				counter <= counter + 1;
			end if;
			if(load = '1') then
				counter <= unsigned(pc_in);
			end if;
		end if;	
	end if;	
		
	end process;

end RTL;
 
