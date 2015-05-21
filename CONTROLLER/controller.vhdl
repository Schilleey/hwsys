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
	type t_state is ( s_reset, s_if1, s_if2, s_id, s_alu, s_ldil, s_ldih, s_gif, s_ld, s_ld2, s_st, s_jmp, s_halt, s_jz, s_jnz, s_wait);
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
					--when s_gif	 => if ready = '1' and ir(12 downto 11) = "10" then state <= s_ld; 
									--else
										--if ready = '1' and ir(12 downto 11) = "11" then state <= s_st;
										--end if;
									--end if;
					when s_id	 => 
						case ir(15 downto 14) is
							when "00" => state <= s_alu;
							when "01" => 
								case ir(12 downto 11) is
									when "00" => state <= s_ldil;
									when "01" => state <= s_ldih; 
									when "10" => if ready = '0' then state <= s_ld; else state <= s_wait; end if;
									when "11" => if ready = '0' then state <= s_st; else state <= s_wait; end if;
									when others => null;
								end case;	
							when "10" => 
								case ir(12 downto 11) is
									when "00" => state <= s_jmp;
									when "01" => state <= s_halt;
									when "10" => if zero = '0' then state <= s_jz; else state <= s_if1; end if;
									when "11" => if zero = '1' then state <= s_jnz; else state <= s_if1; end if;
									when others => null;
								end case;
							when others => null;
						end case;
					when s_wait =>
						if ready = '0' then
							if ir(12 downto 11) = "10" then state <= s_ld; else state <= s_st; end if;
						end if;
					when s_alu 	=> state <= s_if1;
					when s_ldil	=> state <= s_if1;
					when s_ldih	=> state <= s_if1;
					when s_ld   =>
						if ready = '1' then state <= s_ld2; end if;
					when s_ld2   => state <= s_if1;
					when s_st   => 
						if ready = '1' then state <= s_if1; end if;
					when s_jmp  => state <= s_if1;
					when s_jz   => state <= s_if1;
					when s_jnz  => state <= s_if1;
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
		
		-- zustandsabhängige Belegung...
		case state is
			when s_if2 =>
				c_adr_pc_not_reg <= '1'; -- hier müssen nur Abweichungen von der
				c_mem_rd <= '1'; -- Default-Belegung behandelt werden
				c_ir_load <= '1';          
			
			when s_id =>
				c_pc_inc <= '1';
				
			when s_alu =>
				c_regfile_load_lo <= '1';
				c_regfile_load_hi <= '1';
				
			when s_ldil =>
				c_reg_ldi <= '1';
				c_regfile_load_lo <= '1';
				
			when s_ldih =>
				c_reg_ldi <= '1';
				c_regfile_load_hi <= '1';
				
			when s_ld =>
				c_mem_rd <= '1';
				--c_adr_pc_not_reg <= '1';
				c_reg_ldmem <= '1';
				
			when s_ld2 =>
				c_mem_rd <= '1';
				--c_adr_pc_not_reg <= '1';
				c_reg_ldmem <= '1';
				c_regfile_load_lo <= '1';
				c_regfile_load_hi <= '1';	
			
			when s_st =>
				c_mem_wr <= '1';
				--c_adr_pc_not_reg <= '1';
							
			
			when s_jmp =>
				c_pc_load <= '1';
			
			when s_jz =>
				c_pc_load <= '1';
			
			when s_jnz =>
				c_pc_load <= '1';
						
				
			when others => null;      
		end case;
	end process;
end RTL;
	
