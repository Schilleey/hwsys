library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CONTROLLER is
  port (
    clk, reset: in std_logic;
    ir: in std_logic_vector(15 downto 0);  -- Befehlswort
    ready, zero: in std_logic;         -- weitere Statussignale
    c_reg_ldmem, c_reg_ldi,            -- Auswahl beim Register-Laden
    c_regfile_load_lo, c_regfile_load_hi,  -- Steuersignale Reg.-File
    c_pc_load, c_pc_inc,               -- Steuereingänge PC
    c_ir_load,                         -- Steuereingang IR
    c_mem_rd, c_mem_wr,                -- Signale zum Speicher
    c_adr_pc_not_reg : out std_logic   -- Auswahl Adress-Quelle
  );
end CONTROLLER;

architecture RTL of CONTROLLER is
	-- Aufzählungstyp für den Zustand...
	type t_state is ( s_reset, s_if1, s_if2, s_id, s_alu, s_ldil, s_ldih );
	signal state: t_state;
begin

	-- Prozess für die Zustandsübergangsfunktion...
	state_trans: process (clk)   
	-- (nur) Taktsignal in Sensitivitätsliste
	begin
		if clk'event and clk = '1' then
			if reset = '1' then state <= s_reset;  
			-- Reset hat Vorrang!
			else 
				case state is
					when s_reset => state <= s_if1;
					when s_if1   => if ready = '0' then state <= s_if2; end if;
					when s_if2   => if ready = '1' then state <= s_id; end if;
					when s_id	 => 
						if ir(15 downto 14) = "00" then state <= s_alu; else
							if ir(15 downto 14) = "01" and ir(12 downto 11) = "00" then state <= s_ldil; else
								if ir(15 downto 11) = "01-01" then state <= s_ldih; --Versuch mit don't care
								end if; 
							end if; 
						end if;
					when others => null;      
				end case;
			end if;
		end if;
	end process;
	
	
	-- Prozess für die Ausgabefunktion...
	output: process (state)  
	-- Zustand in Sensitiviätsliste 
    --(bei Mealy-Automat auch Eingänge)
	begin   
	-- Default-Werte für alle Ausgangssignale
		
		c_adr_pc_not_reg <= '0'; 		
		c_reg_ldmem <= '0';
		c_reg_ldi <= '0';
		c_regfile_load_lo <= '0';
		c_regfile_load_hi <= '0';	
		c_pc_load <= '0';
		c_pc_inc <= '0';
		c_ir_load <= '0';
		c_mem_rd <= '0';
		c_mem_wr <= '0';
		c_adr_pc_not_reg <= '0';
		
		-- zustandsabhängige Belegung...
		case state is
			when s_if2 =>
				c_adr_pc_not_reg <= '1'; -- hier müssen nur Abweichungen von der
				c_mem_rd <= '1'; -- Default-Belegung behandelt werden
				c_ir_load <= '1';          
			
			when s_id =>
				c_pc_inc <= '1';
				
			when s_alu =>
				c_reg_ldmem <= '1';
				
			when s_ldil =>
				c_reg_ldi <= '1';
				c_regfile_load_lo <= '1';
				
			when s_ldih =>
				c_reg_ldi <= '1';
				c_regfile_load_hi <= '1';
				
			when others => null;      
		end case;
	end process;
end RTL;
	
