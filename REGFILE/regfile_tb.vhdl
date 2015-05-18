library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REGFILE_TB is
end REGFILE_TB;

architecture BEHAVORIAL of REGFILE_TB is

	component REGFILE
		port (
			clk: in std_logic; --takteingang
			in_data: in std_logic_vector (15 downto 0); --das soll in ein register rein
			in_sel: in std_logic_vector (2 downto 0); 
			out0_data: out std_logic_vector (15 downto 0); --gibt auch registerinhalt aus
			out0_sel: in std_logic_vector (2 downto 0); 
			out1_data: out std_logic_vector (15 downto 0); --gibt registerinhalt aus
			out1_sel: in std_logic_vector (2 downto 0); -- wird in integer umgewandelt um unser array zu adressieren
			load_lo, load_hi: in std_logic -- vordere hälfte einlesen oder untere hälfte eines registers
		);
	end component;
	
	--Configuration:
	for U_REGFILE: REGFILE use entity WORK.REGFILE(RTL);
	
	--Clock period
	constant period: time := 10 ns;
	
	--signals: hier ist nochmal alles wie für port von regfile
	signal clk, load_lo, load_hi: std_logic; --takteingang
	signal in_data, out0_data, out1_data: std_logic_vector (15 downto 0);
	signal in_sel, out0_sel, out1_sel: std_logic_vector (2 downto 0); 
	
	-- hoffentlich funktioniert das:
	type helper_register is array (0 to 7) of std_logic_vector (15 downto 0);	
			
begin

	--innitiate
	U_REGFILE: REGFILE port map(
	clk => clk,
	in_data => in_data,
	in_sel => in_sel,
	out0_data => out0_data,
	out0_sel => out0_sel,
	out1_data => out1_data,
	out1_sel => out1_sel,
	load_lo => load_lo,
	load_hi => load_hi
	);
	
	process
	
		-- Helper to perform one clock cycle...
		procedure run_cycle is
		begin
		  clk <= '0';
		  wait for period / 2;
		  clk <= '1';
		  wait for period / 2;
		end procedure;
		
		-- Helper um daten zu sichern --hoffentlich funktioniert das:
		variable h1, h2, h3: helper_register;
		variable j: integer;
    
    begin
    
		-- überall nullen einlesen:
		run_cycle;
		load_hi <= '1'; load_lo <= '1';
		in_data <= "0000000000000000"; --16 stellen für das register
		for i in 0 to 7 loop
			in_sel <= std_logic_vector( to_unsigned (i, 3));
			run_cycle;
		end loop;
		
		-- nur hi-bytes schreiben:
		-- array mit verschiedenen zahlen zum einlesen
		h1(0)(15 downto 0) := "1000000000000001"; --eingabe
		h1(1)(15 downto 0) := "0100000000000010";
		h1(2)(15 downto 0) := "0010000000000100";
		h1(3)(15 downto 0) := "0001000000001000";
		h1(4)(15 downto 0) := "0000100000010000";
		h1(5)(15 downto 0) := "0000010000100000";
		h1(6)(15 downto 0) := "0000001001000000";
		h1(7)(15 downto 0) := "0000000110000000";
		load_hi <= '1'; load_lo <= '0';
		for i in 0 to 7 loop
			in_data <= h1(1);
			in_sel <= std_logic_vector( to_unsigned (i, 3));
			run_cycle;
		end loop;
		load_hi <= '0';
		
		-- prüfen:
		h1(0)(15 downto 0) := "1000000000000000"; --erwartete ausgabe
		h1(1)(15 downto 0) := "0100000000000000";
		h1(2)(15 downto 0) := "0010000000000000";
		h1(3)(15 downto 0) := "0001000000000000";
		h1(4)(15 downto 0) := "0000100000000000";
		h1(5)(15 downto 0) := "0000010000000000";
		h1(6)(15 downto 0) := "0000001000000000";
		h1(7)(15 downto 0) := "0000000100000000";
		for i in 0 to 7 loop --ausgae von out0 prüfen
			out0_sel <= std_logic_vector( to_unsigned (i, 3));
			run_cycle;
			assert out0_data /= h1(i) report "Fehler bei load_hi einlesen und out0_sel auslesen!";
		end loop;
		for i in 0 to 7 loop --ausgabe von out1 prüfen
			out1_sel <= std_logic_vector( to_unsigned (i, 3));
			run_cycle;
			assert out1_data /= h1(i) report "Fehler bei load_hi einlesen und out1_sel auslesen!";
		end loop;
		for i in 0 to 7 loop-- ausgabe von out0 und out1 gleichzeitig prüfen
			j := 7 - i;
			out0_sel <= std_logic_vector( to_unsigned (i, 3));
			out1_sel <= std_logic_vector( to_unsigned (j, 3));
			run_cycle;
			assert out0_data /= h1(i) report "Fehler bei load_hi einlesen und out0_sel und out1_sel gleichzeitig auslesen!";
			assert out1_data /= h1(j) report "Fehler bei load_hi einlesen und out1_sel und out0_sel gleichzeitig auslesen!";
		end loop;
		
		-- nur lo-bytes schreiben:
		h1(0)(15 downto 0) := "1100000000000011"; -- eingabe
		h1(1)(15 downto 0) := "0110000000000110";
		h1(2)(15 downto 0) := "0011000000001100";
		h1(3)(15 downto 0) := "0001100000011000";
		h1(4)(15 downto 0) := "0000110000110000";
		h1(5)(15 downto 0) := "0000011001100000";
		h1(6)(15 downto 0) := "0000001111000000";
		h1(7)(15 downto 0) := "1000000110000001";
		load_hi <= '0'; load_lo <= '1';
		for i in 0 to 7 loop
			in_data <= h1(1);
			in_sel <= std_logic_vector( to_unsigned (i, 3));
			run_cycle;
		end loop;
		load_lo <= '0';
		
		--prüfen:
		h3(0)(15 downto 0) := "1000000000000011"; -- erwartte ausgabe
		h3(1)(15 downto 0) := "0100000000000110";
		h3(2)(15 downto 0) := "0010000000001100";
		h3(3)(15 downto 0) := "0001000000011000";
		h3(4)(15 downto 0) := "0000100000110000";
		h3(5)(15 downto 0) := "0000010001100000";
		h3(6)(15 downto 0) := "0000001011000000";
		h3(7)(15 downto 0) := "0000000110000001";
		for i in 0 to 7 loop-- ausgabe von out0 und out1 gleichzeitig prüfen
			j := 7 - i;
			out0_sel <= std_logic_vector( to_unsigned (i, 3));
			out1_sel <= std_logic_vector( to_unsigned (j, 3));
			run_cycle;
			assert out0_data /= h3(i) report "Fehler bei load_lo einlesen und out0_sel und out1_sel gleichzeitig auslesen!";
			assert out1_data /= h3(j) report "Fehler bei load_lo einlesen und out1_sel und out0_sel gleichzeitig auslesen!";
		end loop;
		
		--gleichzeitig schreiben und lesen:
		
		h1(0)(15 downto 0) := "1100000000000000"; -- eingabe
		h1(1)(15 downto 0) := "0110000000000000";
		h1(2)(15 downto 0) := "0011000000000000";
		h1(3)(15 downto 0) := "0001100000000000";
		h1(4)(15 downto 0) := "0000110000000000";
		h1(5)(15 downto 0) := "0000011000000000";
		h1(6)(15 downto 0) := "0000001100000000";
		h1(7)(15 downto 0) := "1000000100000000";
		
		h2(0)(15 downto 0) := "1100000000000011"; --erwartete ausgabe in h3, einen tackt später das hier in h2
		h2(1)(15 downto 0) := "0110000000000110";
		h2(2)(15 downto 0) := "0011000000001100";
		h2(3)(15 downto 0) := "0001100000011000";
		h2(4) := "0000110000110000";
		h2(5) := "0000011001100000";
		h2(6) := "0000001111000000";
		h2(7) := "1000000110000001";
		
		load_hi <= '1';
		load_lo <= '0';
		for i in 0 to 7 loop
			j := 7 - i;
			in_data <= h1(i);
			in_sel <= std_logic_vector( to_unsigned (i, 3));
			out0_sel <= std_logic_vector( to_unsigned (i, 3));
			out1_sel <= std_logic_vector( to_unsigned (j, 3));
			run_cycle;
			assert out0_data /= h3(i) report "Fehler beim gleichzeitig aus und einlesen im ersten takt";
			assert out1_data /= h3(j) report "Fehler beim gleichzeitig aus und einlesen im ersten takt";
		end loop;
		
		for i in 0 to 7 loop
			j := 7 - i;
			-- in_data <= h1(i);
			-- in_sel <= conv_std_logic_vector (i, 3);
			out0_sel <= std_logic_vector( to_unsigned (i, 3));
			out1_sel <= std_logic_vector( to_unsigned (j, 3));
			run_cycle;
			assert out0_data /= h2(i) report "Fehler beim gleichzeitig aus und einlesen im nächsten takt durchgang";
			assert out1_data /= h2(j) report "Fehler beim gleichzeitig aus und einlesen im nächsten takt durchgang";
		end loop;
    
    end process;

end architecture;
