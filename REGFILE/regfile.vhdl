library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REGFILE is
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
end REGFILE;

architecture RTL of REGFILE is
	--t_regfile ist also ein array aus arrays, z.B. in java: t_regfile[7][15]
	type t_regfile is array (0 to 7) of std_logic_vector (15 downto 0);
	--das signal reg ist vom oben definierten typ t_regfile, also ein array aus arrrays
	signal reg: t_regfile;
begin

--Ausgabe:

--reg sind unsere register in denen eingaben gespeichert werden
--out0_data <= reg(to_integer(unsigned(out0_sel))); --sicherheitshalber zu unsigned umwandeln bevor man es zu integer umwandelt
--out1_data <= reg(to_integer(unsigned(out1_sel)));
-- ich hab das da oben ieber in einen prozess getahn;

--Zustandsübergang:
process (clk) --prozess wird pro taktsignal ausgelöst, soll register laden
begin
	if clk'event and clk = '1' then --was heist clk' was heist der strich daran?
		if (load_lo = '1') then --nur jetzt wird was geladen
			reg(to_integer( unsigned(in_sel))) (7 downto 0) <= in_data(7 downto 0); --array-stelle von 0 bis 7 aus in_data
		end if;
		if (load_hi = '1') then
			reg(to_integer( unsigned(in_sel))) (15 downto 8) <= in_data(15 downto 8);
		end if;
	end if;	
end process; --ausgelesen wird immer irgentwas

process (out0_sel, out1_sel, reg) --unabhängig vom taktsignal, prozess für die ausgabe
begin
	-- das auswählen des registers
	out0_data <= reg(to_integer(unsigned(out0_sel))) after 0 ns; --sicherheitshalber zu unsigned umwandeln bevor man es zu integer umwandelt
	out1_data <= reg(to_integer(unsigned(out1_sel)));
	-- könnte man das noch besser machen indem man jedem out einen eigenen prozess gibt?
end process; 

end RTL;
