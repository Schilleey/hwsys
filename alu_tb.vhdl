library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_TB is
end ALU_TB;

architecture TESTBENCH of ALU_TB is

  -- Component declaration...
  component ALU is
    port (
		a : in std_logic_vector (15 downto 0); 	-- Eingang A
		b : in std_logic_vector (15 downto 0); 	-- Eingang B
		sel : in std_logic_vector (2 downto 0); -- Operation
		y : out std_logic_vector (15 downto 0); -- Ausgang
		zero: out std_logic						-- gesetzt, falls Eingang B = 0
	);
  end component;

  -- Configuration...
  for IMPL: ALU use entity WORK.ALU(BEHAVIOR);
  
  
  signal a,b,y: std_logic_vector(15 downto 0);
  signal sel: std_logic_vector(2 downto 0);
  signal zero: std_logic;

begin

  -- Instantiate alu
  IMPL: ALU port map (a => a, b => b, sel => sel, y => y, zero => zero);
  
  -- Main process...
  process
  begin  	  	
  --loop mit unterer und oberer wertebereich und sel. alles vergleichen mit einfacher berechnung
		
  
	--iterate the 'sel' "000"-"111"
	for i in 0 to 7 loop
		sel <= std_logic_vector(to_unsigned(i, 3));			
					
		--iterate for 'a' some low values (plus and minus)
		for j in 0 to 10 loop
			a <= std_logic_vector(to_signed((j -5) * 6073, 16));		
			--iterate for 'b' some low values (plus and minus)
			for k in 0 to 10 loop
				b <= std_logic_vector(to_signed((k-5) * 6073, 16));
				
				wait for 1 ns;
				case sel is
					when "000" => assert y = std_logic_vector(signed(a) + signed(b)) report "problem with add"; --ADD 
					when "001" => assert y = std_logic_vector(signed(a) - signed(b)) report "problem with sub"; --SUB
					when "010" => assert y = a(14 downto 0) & '0' report "problem with shift left"; --Shift left
					when "011" => assert y = a(15) & a(15 downto 1) report "problem with shift right"; --SAR !!
					when "100" => assert y = (a AND b) report "problem with AND"; --AND
					when "101" => assert y = (a OR b) report "problem with OR"; --OR
					when "110" => assert y = (a XOR b) report "problem with XOR"; --XOR
					when others => assert y = (NOT a) report "problem with NOT"; --NOT
				end case;
			end loop;
		end loop;			
	end loop;
	
	a<="0111111111111111";
	b<="0111111111111111";
	
	for i in 0 to 7 loop
		sel <= std_logic_vector(to_unsigned(i, 3));			
					
		--iterate for 'a' some low values (plus and minus)
		for j in 0 to 10 loop
			a <= std_logic_vector(to_signed(to_integer(signed(a)-j), 16));		
			--iterate for 'b' some low values (plus and minus)
			for k in 0 to 10 loop
				b <= std_logic_vector(to_signed(to_integer(signed(b)-k), 16));		
				
				wait for 1 ns;
				case sel is
					when "000" => assert y = std_logic_vector(signed(a) + signed(b)) report "problem with add"; --ADD 
					when "001" => assert y = std_logic_vector(signed(a) - signed(b)) report "problem with sub"; --SUB
					when "010" => assert y = a(14 downto 0) & '0' report "problem with shift left"; --Shift left
					when "011" => assert y = a(15) & a(15 downto 1) report "problem with shift right"; --SAR !!
					when "100" => assert y = (a AND b) report "problem with AND"; --AND
					when "101" => assert y = (a OR b) report "problem with OR"; --OR
					when "110" => assert y = (a XOR b) report "problem with XOR"; --XOR
					when others => assert y = (NOT a) report "problem with NOT"; --NOT
				end case;
			end loop;
		end loop;			
	end loop;
	
	
	a<="1111111111111111";
	b<="1111111111111111";
	
	
	for i in 0 to 7 loop
		sel <= std_logic_vector(to_unsigned(i, 3));			
					
		--iterate for 'a' some low values (plus and minus)
		for j in 10 to 0 loop
			a <= std_logic_vector(to_signed(to_integer(signed(a)+j), 16));		
			--iterate for 'b' some low values (plus and minus)
			for k in 0 to 10 loop
				b <= std_logic_vector(to_signed(to_integer(signed(b)+k), 16));		
				
				wait for 1 ns;
				case sel is
					when "000" => assert y = std_logic_vector(signed(a) + signed(b)) report "problem with add"; --ADD 
					when "001" => assert y = std_logic_vector(signed(a) - signed(b)) report "problem with sub"; --SUB
					when "010" => assert y = a(14 downto 0) & '0' report "problem with shift left"; --Shift left
					when "011" => assert y = a(15) & a(15 downto 1) report "problem with shift right"; --SAR !!
					when "100" => assert y = (a AND b) report "problem with AND"; --AND
					when "101" => assert y = (a OR b) report "problem with OR"; --OR
					when "110" => assert y = (a XOR b) report "problem with XOR"; --XOR
					when others => assert y = (NOT a) report "problem with NOT"; --NOT
				end case;
			end loop;
		end loop;			
	end loop;
	
	
	
	
	--Test for zero bit set by b
	a <= ( 10 = '1' others => '0');
	b <= (others => '0');		
	wait for 1 ns;
	assert zero = '1' report "Zero is not 1 but b is 0!";
	
	
	
	
    -- Print a note & finish simulation now
    assert false report "Simulation finished" severity note;
    wait;               -- end simulation

  end process;

end architecture;
