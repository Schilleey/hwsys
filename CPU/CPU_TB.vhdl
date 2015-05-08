LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;


ENTITY cpu_tb IS
END cpu_tb;


ARCHITECTURE behavior OF cpu_tb IS

	-- Component Declaration for the Unit Under Test (UUT)...
	COMPONENT cpu
		PORT (
			clk, reset, ready : IN std_logic;
			rd, wr : OUT std_logic;
			adr : OUT std_logic_vector(15 downto 0);
			data : INOUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	-- Signals...
	SIGNAL clk, reset, ready, rd, wr: std_logic;
	SIGNAL adr, data: std_logic_vector (15 downto 0);
	
	-- Parameters...
	constant clk_period: time := 10 ns;
	constant mem_delay: time := 25 ns;
	
	-- Memory content (created by viscy2l) ...
	-- hier Ausgabe von viscy2l einfügen
	
	-- dazu bräuchte ich das Programm in SEPP
	
	
	BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: cpu PORT MAP(
		clk => clk, reset => reset,
		rd => rd, wr => wr, ready => ready,
		adr => adr, data => data
	);
	
	-- Process to simulate the memory behavior...
	memory: process
	begin
		data <= "ZZZZZZZZZZZZZZZZ";
		ready <= '0';
		wait on rd, wr;
		if rd = '1' then
			wait for mem_delay;
			data <= mem_content (conv_integer ('0' & adr));
			ready <= '1';
			wait until rd = '0';
			data <= "ZZZZZZZZZZZZZZZZ";
			wait for mem_delay;
			ready <= '0';
		elsif wr = '1' then
			wait for mem_delay;
			mem_content (conv_integer ('0' & adr)) <= data;
			ready <= '1';
			wait until wr = '0';
			wait for mem_delay;
			ready <= '0';
		end if;
	end process;
	
	-- Main testbench process...
	tb : PROCESS
	
		procedure run_cycle is
		begin
			clk <= '0';
			wait for clk_period / 2;
			clk <= '1';
			wait for clk_period / 2;
		end procedure;

	BEGIN
	
	-- sinnvolles Hauptprogramm überlegen
	
		-- kein plan nur was mir grad so eingefallen ist:
		while programmnotfinished loop 
			controller ruft data ab;
			setzt dazu rd <= '1';
			dann irgendwie memory process starten...
			
			runcycle;
		end loop;
		-- dann muss das Ergebnis der Addition im Programm im Memory stehen??
		assert mem_content = "0000000000000010" report "1 + 1 is not 0000000000000010";
 
	
	wait; -- wait forever (stop simulation)
	END PROCESS;
END;
