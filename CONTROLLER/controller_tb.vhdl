library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY CONTROLLER_TB IS
END CONTROLLER_TB;


ARCHITECTURE BEHAVIOR OF CONTROLLER_TB IS

	-- Component Declaration
	COMPONENT CONTROLLER IS
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
	END COMPONENT;

	-- Configuration...
	for IMPL: CONTROLLER use entity WORK.CONTROLLER(RTL);
	
	  -- Clock period
    constant period: time := 10 ns;

	-- Internal signals...
	signal clk, reset, ready, zero, c_reg_ldmem, c_reg_ldi,	
	       c_regfile_load_lo, c_regfile_load_hi, c_pc_load, c_pc_inc,
	       c_ir_load, c_mem_rd, c_mem_wr, c_adr_pc_not_reg: std_logic;
	signal ir: std_logic_vector(15 downto 0);

begin

	IMPL: CONTROLLER port map (clk => clk, reset => reset, 
	  ready => ready, zero => zero, c_reg_ldmem => c_reg_ldmem,
	  c_reg_ldi => c_reg_ldi, c_regfile_load_lo => c_regfile_load_lo,
	  c_regfile_load_hi => c_regfile_load_hi, c_pc_load => c_pc_load, 
	  c_pc_inc => c_pc_inc, c_ir_load => c_ir_load, c_mem_rd => c_mem_rd, 
	  c_mem_wr => c_mem_wr, c_adr_pc_not_reg => c_adr_pc_not_reg, ir => ir);
	
	process
	
    -- Helper to perform one clock cycle...
    procedure run_cycle is
    begin
      clk <= '0';
      wait for period / 2;
      clk <= '1';
      wait for period / 2;
    end procedure;
	
	begin
		reset <= '1';
		run_cycle;
		ready <= '1';
		run_cycle;
		
		--ir <= "0011000110001101";
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem";
		assert c_reg_ldi = '0' report "c_reg_ldi";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi";
		assert c_pc_load = '0' report "c_pc_load";
		assert c_pc_inc = '0' report "c_pc_inc";
		assert c_ir_load = '0' report "c_ir_load";
		assert c_mem_rd = '0' report "c_mem_rd";
		assert c_mem_wr = '0' report "c_mem_wr";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg";

---
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		--ir <= "0011000110001101";
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=if2";
		assert c_reg_ldi = '0' report "c_reg_ldi state=if2";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=if2";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=if2";
		assert c_pc_load = '0' report "c_pc_load state=if2";
		assert c_pc_inc = '0' report "c_pc_inc state=if2";
		assert c_ir_load = '1' report "c_ir_load state=if2";
		assert c_mem_rd = '1' report "c_mem_rd state=if2";
		assert c_mem_wr = '0' report "c_mem_wr state=if2";
		assert c_adr_pc_not_reg = '1' report "c_adr_pc_not_reg state=if2";

		--------------------------------------------------
		
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		ready <= '1';
		run_cycle; --id
		
--		ir <= "0011000110001101";
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=id";
		assert c_reg_ldi = '0' report "c_reg_ldi state=id";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=id";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=id";
		assert c_pc_load = '0' report "c_pc_load state=id";
		assert c_pc_inc = '1' report "c_pc_inc state=id";
		assert c_ir_load = '0' report "c_ir_load state=id";
		assert c_mem_rd = '0' report "c_mem_rd state=id";
		assert c_mem_wr = '0' report "c_mem_wr state=id";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=id";

		
		-------------------------------------------------
		
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		ready <= '1';
		run_cycle; --id
		ready <= '0';
		ir <= "0011000110001101"; --some alu command  :P
		run_cycle;
		
		assert c_reg_ldmem = '1' report "c_reg_ldmem, state=alu";
		assert c_reg_ldi = '0' report "c_reg_ldi state=alu";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=alu";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=alu";
		assert c_pc_load = '0' report "c_pc_load state=alu";
		assert c_pc_inc = '0' report "c_pc_inc state=alu";
		assert c_ir_load = '0' report "c_ir_load state=alu";
		assert c_mem_rd = '0' report "c_mem_rd state=alu";
		assert c_mem_wr = '0' report "c_mem_wr state=alu";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=alu";
		
		
		-----------------------------------------------------------
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		ready <= '1';
		run_cycle; --id
		ready <= '0';
		ir <= "0100000110001101"; --LDIL 01-00...  :P
		run_cycle;
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=LDIL";
		assert c_reg_ldi = '1' report "c_reg_ldi state=LDIL";
		assert c_regfile_load_lo = '1' report "c_regfile_load_lo state=LDIL";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=LDIL";
		assert c_pc_load = '0' report "c_pc_load state=LDIL";
		assert c_pc_inc = '0' report "c_pc_inc state=LDIL";
		assert c_ir_load = '0' report "c_ir_load state=LDIL";
		assert c_mem_rd = '0' report "c_mem_rd state=LDIL";
		assert c_mem_wr = '0' report "c_mem_wr state=LDIL";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=LDIL";
		
		
		-----------------------------------------------------------
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		ready <= '1';
		run_cycle; --id
		ready <= '0';
		ir <= "0100100110001101"; --LDIH 01-01...  :P
		run_cycle;
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=LDIH";
		assert c_reg_ldi = '1' report "c_reg_ldi state=LDIH";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=LDIH";
		assert c_regfile_load_hi = '1' report "c_regfile_load_hi state=LDIH";
		assert c_pc_load = '0' report "c_pc_load state=LDIH";
		assert c_pc_inc = '0' report "c_pc_inc state=LDIH";
		assert c_ir_load = '0' report "c_ir_load state=LDIH";
		assert c_mem_rd = '0' report "c_mem_rd state=LDIH";
		assert c_mem_wr = '0' report "c_mem_wr state=LDIH";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=LDIH";
		
		
		
		
		-----------------------------------------------------------
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		ready <= '1';
		run_cycle; --id
		ready <= '0';
		ir <= "0100100110001101"; --LDIH 01-01...  :P
		reset <= '1';
		run_cycle;
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=RESET";
		assert c_reg_ldi = '0' report "c_reg_ldi state=RESET";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=RESET";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=RESET";
		assert c_pc_load = '0' report "c_pc_load state=RESET";
		assert c_pc_inc = '0' report "c_pc_inc state=RESET";
		assert c_ir_load = '0' report "c_ir_load state=RESET";
		assert c_mem_rd = '0' report "c_mem_rd state=RESET";
		assert c_mem_wr = '0' report "c_mem_wr state=RESET";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=RESET";
		
		
		
		-----------------------------------------------------------
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		ready <= '0';
		run_cycle; --if2
		reset <= '1';
		run_cycle;
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=RESET";
		assert c_reg_ldi = '0' report "c_reg_ldi state=RESET";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=RESET";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=RESET";
		assert c_pc_load = '0' report "c_pc_load state=RESET";
		assert c_pc_inc = '0' report "c_pc_inc state=RESET";
		assert c_ir_load = '0' report "c_ir_load state=RESET";
		assert c_mem_rd = '0' report "c_mem_rd state=RESET";
		assert c_mem_wr = '0' report "c_mem_wr state=RESET";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=RESET";
		
		
		
		-----------------------------------------------------------
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '0';
		run_cycle;
		reset <= '1';
		run_cycle;
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=RESET";
		assert c_reg_ldi = '0' report "c_reg_ldi state=RESET";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=RESET";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=RESET";
		assert c_pc_load = '0' report "c_pc_load state=RESET";
		assert c_pc_inc = '0' report "c_pc_inc state=RESET";
		assert c_ir_load = '0' report "c_ir_load state=RESET";
		assert c_mem_rd = '0' report "c_mem_rd state=RESET";
		assert c_mem_wr = '0' report "c_mem_wr state=RESET";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=RESET";
		
		
		-----------------------------------------------------------
		reset <= '1';
		ready <= '1';
		run_cycle; --if1
		reset <= '1';
		run_cycle;
		
		assert c_reg_ldmem = '0' report "c_reg_ldmem, state=RESET";
		assert c_reg_ldi = '0' report "c_reg_ldi state=RESET";
		assert c_regfile_load_lo = '0' report "c_regfile_load_lo state=RESET";
		assert c_regfile_load_hi = '0' report "c_regfile_load_hi state=RESET";
		assert c_pc_load = '0' report "c_pc_load state=RESET";
		assert c_pc_inc = '0' report "c_pc_inc state=RESET";
		assert c_ir_load = '0' report "c_ir_load state=RESET";
		assert c_mem_rd = '0' report "c_mem_rd state=RESET";
		assert c_mem_wr = '0' report "c_mem_wr state=RESET";
		assert c_adr_pc_not_reg = '0' report "c_adr_pc_not_reg state=RESET";
		
		
		
		assert false report "Simulation finished" severity note;
    wait; 
		
		  end process;

end architecture;
