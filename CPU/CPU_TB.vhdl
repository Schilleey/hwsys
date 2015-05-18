LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;


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
	
	-- Memory content (created by viscy2l) ...
    --type t_memory is array (0 to 19) of STD_LOGIC_VECTOR(15 downto 0);
    --signal mem_content: t_memory := (
      --16#0000# => "0011000000000000",   -- 	  XOR   r0, r0, r0 ; Nur '0' in r0
      --16#0001# => "0100100000000001",   -- 	  LDIH  r0, 0x01   ; r0 => 0x100
      --16#0002# => "0101000100000000",   -- 	  LD    r1, [r0]   ; 1. Faktor in r1
      --16#0003# => "0011000000000000",   -- 	  XOR   r0, r0, r0
      --16#0004# => "0100000000000001",   -- 	  LDIL  r0, 0x01
      --16#0005# => "0100100000000001",   -- 	  LDIH  r0, 0x01   ; r0 => 0x101
      --16#0006# => "0101001000000000",   -- 	  LD    r2, [r0]   ; 2. Faktor in r2
      --16#0007# => "0011000000000000",   -- 	  XOR   r0, r0, r0
      --16#0008# => "0100000000000010",   -- 	  LDIL  r0, 0x02
      --16#0009# => "0100100000000001",   -- 	  LDIH  r0, 0x01   ; r0 => 0x102
      --16#000a# => "0011001101101100",   -- 	  XOR   r3, r3, r3
      --16#000b# => "0011010010010000",   -- 	  XOR   r4, r4, r4
      --16#000c# => "0100010000000001",   -- 	  LDIL  r4, 1
      --16#000d# => "0011010110110100",   -- 	  XOR   r5, r5, r5
      --16#000e# => "0100010100010000",   -- 	  LDIL  r5, loop
      --16#000f# => "0100110100000000",   -- 	  LDIH  r5, loop>>8
      --16#0010# => "0000001101100100",   -- loop: ADD   r3, r3, r1 ; Addieren, r3 = r3 + r1
      --16#0011# => "0000101001010000",   -- 	  SUB   r2, r2, r4
      --16#0012# => "1001100010101000",   -- 	  JNZ   r2, r5
      --16#0013# => "0101100000001100",   -- 	  ST    [r0], r3   ; Ergebnis speichern
      --others => "UUUUUUUUUUUUUUUU"
    --);
    
      -- Memory content (created by viscy2l) ...
      
    -- Memory content (created by viscy2l) ...
  type t_memory is array (0 to 27) of STD_LOGIC_VECTOR(15 downto 0);
  signal mem_content: t_memory := (
      16#0000# => "0100100000000000",   -- LDIH  r0, 0x00   ; => 1111111100000000
      16#0001# => "0100000000000000",   -- LDIL  r0, 0x00   ; => 1111111111111111
      16#0002# => "0100100100000000",   -- LDIH  r1, 0x00   ; => 1111111100000000
      16#0003# => "0100000100000000",   -- LDIL  r1, 0x00   ; => 1111111111111111
      16#0004# => "0100101100000000",   -- LDIH  r3, 0x00   ; => 1111111100000000
      16#0005# => "0100001100000000",   -- LDIL  r3, 0x00   ; => 1111111111111111
      16#0006# => "0011000000000000",   -- XOR   r0, r0, r0 ; Nur '0' in r0
      16#0007# => "0100000000001000",   -- LDIL  r0, 8      ; 1. Wert in r0
      16#0008# => "0011000100100100",   -- XOR   r1, r1, r1
      16#0009# => "0100000100000100",   -- LDIL  r1, 4
      16#000a# => "0011001101101100",   -- XOR   r3, r3, r3 ; Ergebnis Register leeren
      16#000b# => "0000001100000100",   -- ADD   r3, r0, r1 ; Addieren, r3 = r0 + r1     => 12
      16#000c# => "0011001101101100",   -- XOR   r3, r3, r3
      16#000d# => "0000101100000100",   -- SUB   r3, r0, r1 ; Subtrahieren, r3 = r0 - r1 => 4
      16#000e# => "0011001101101100",   -- XOR   r3, r3, r3
      16#000f# => "0001001100000000",   -- SAL   r3, r0     ; Shift nach links           => 16
      16#0010# => "0011001101101100",   -- XOR   r3, r3, r3
      16#0011# => "0001101100000000",   -- SAR   r3, r0     ; Shift nach rechts          => 4
      16#0012# => "0011001101101100",   -- XOR   r3, r3, r3
      16#0013# => "0100101111111111",   -- LDIH  r3, 0xFF   ; => 1111111100000000
      16#0014# => "0100001111111111",   -- LDIL  r3, 0xFF   ; => 1111111111111111
      16#0015# => "0010001100000100",   -- AND   r3, r0, r1 ; => 0
      16#0016# => "0011001101101100",   -- XOR   r3, r3, r3
      16#0017# => "0010101100000100",   -- OR    r3, r0, r1 ; => 12
      16#0018# => "0011001101101100",   -- XOR   r3, r3, r3
      16#0019# => "0011001100000100",   -- XOR   r3, r0, r1 ; => 12
      16#001a# => "0011001101101100",   -- XOR   r3, r3, r3
      16#001b# => "0011101100000000",   -- NOT   r3, r0     ; => 1111111111110111
      others => "UUUUUUUUUUUUUUUU"
    );


    

  -------------------
	
	-- Parameters...
	constant clk_period: time := 10 ns;
	constant mem_delay: time := 25 ns;
	
	-- Memory content (created by viscy2l) ...
	-- hier Ausgabe von viscy2l einfügen
	
	
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
			data <= mem_content (to_integer ( unsigned('0' & adr)));
			ready <= '1';
			wait until rd = '0';
			data <= "ZZZZZZZZZZZZZZZZ";
			wait for mem_delay;
			ready <= '0';
		elsif wr = '1' then
			wait for mem_delay;
			mem_content (to_integer ( unsigned('0' & adr))) <= data;
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
	reset <= '1';
	run_cycle;
	reset <= '0';
	for i in 0 to 500 loop
		run_cycle;
	end loop;
	
	wait; -- wait forever (stop simulation)
	END PROCESS;
END;
