library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port (
		clk, reset: in std_logic;
		adr: out std_logic_vector (15 downto 0);
		data: inout std_logic_vector (15 downto 0);
		rd, wr: out std_logic;
		ready: in std_logic
	);
end CPU;

architecture RTL of CPU is
	-- Component declarations...
	component alu is
		port (
			a : in std_logic_vector (15 downto 0); 	-- Eingang A
			b : in std_logic_vector (15 downto 0); 	-- Eingang B
			sel : in std_logic_vector (2 downto 0); -- Operation
			y : out std_logic_vector (15 downto 0); -- Ausgang
			zero: out std_logic						-- gesetzt, falls Eingang B = 0
		);
	end component;
	
	component IR is
	port ( clk: in std_logic;
         load: in std_logic;
         ir_in: in std_logic_vector (15 downto 0);
         ir_out: out std_logic_vector (15 downto 0)
       );
    end component;
	
	component PC is
	port (
		clk: in std_logic;
		reset, inc, load: in std_logic;
		pc_in: in std_logic_vector (15 downto 0);
		pc_out: out std_logic_vector (15 downto 0)
	);
	end component;
	
	component REGFILE is
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
	
	component CONTROLLER is
	port (
	-- Statussignale...
		clk, reset,		
		ir: in std_logic_vector (15 downto 0);
		ready, zero: in std_logic;
		-- Steuersignale...
		c_reg_ldmem, c_reg_ldi, -- Auswahl beim Register-Laden
		c_regfile_load_lo, -- Steuersignale Registerfile
		c_regfile_load_hi,
		c_pc_load, c_pc_inc, -- Steuereingänge PC
		c_ir_load, -- Steuereingang IR
		c_mem_rd, c_mem_wr, -- Signale zum Speicher
		c_adr_pc_not_reg: out std_logic -- Auswahl Adress-Quelle
	);
	end component;
	
	-- Configuration...
	for all: ALU use entity WORK.ALU(RTL);
	for all: PC use entity WORK.PC(RTL);
	for all: IR use entity WORK.IR(RTL);
	for all: CONTROLLER use entity WORK.CONTROLLER(RTL);
	for all: REGFILE use entity WORK.REGFILE(RTL);
	
	-- Internal signals...
	-- ALU
	signal alu_y: STD_LOGIC_VECTOR (15 downto 0); 
	signal alu_zero: STD_LOGIC;
	
	-- PC
	signal pc_out: std_logic_vector (15 downto 0);
	
	-- IR
	signal ir_out: std_logic_vector (15 downto 0);
		
	-- REGFILE
	signal regfile_out0_data, regfile_out1_data, 
		regfile_in_data: STD_LOGIC_VECTOR (15 downto 0);
	
	-- CONTROLLER
	signal c_pc_load, c_pc_inc: std_logic;
	signal c_ir_load: std_logic;
	signal c_regfile_load_lo, c_regfile_load_hi: std_logic;
	signal c_reg_ldmem ,c_reg_ldi: std_logic;
	signal c_adr_pc_not_reg: std_logic;
	
	-- Memory
	signal mem_data_in, mem_data_out: std_logic_vector (15 downto 0);

begin
	-- Component instatiations...
	U_ALU: ALU port map ( 
		a => regfile_out0_data, 
		b => regfile_out1_data, 
		y => alu_y, 
		sel => ir_out(13 downto 11), 
		zero => alu_zero
	);
	
	U_PC: PC port map (
		clk => clk,
		reset => reset,
		inc => c_pc_inc,
		load => c_pc_load,
		pc_in => regfile_out0_data, --???
		pc_out => pc_out
		
	);
	
	U_IR: IR port map (
		clk => clk,
		load => c_ir_load,
		ir_in => data,
		ir_out => ir_out
	);
	
	U_REGFILE: REGFILE port map (
		clk => clk,
		in_data => regfile_in_data,
		in_sel => ir_out(10 downto 8),
		out0_data => regfile_out0_data,
		out0_sel => ir_out(7 downto 5), 
		out1_data => regfile_out1_data,
		out1_sel => ir_out(4 downto 2),
		load_lo => c_regfile_load_lo,
		load_hi => c_regfile_load_hi
	);
	
	U_CONTROLLER: CONTROLLER port map (
		clk => clk,
		reset => reset,
		
		ir => ir_out(15 downto 11),
		ready => ready,
		zero => alu_zero,
	
		-- Auswahl beim Register-Laden
		c_reg_ldmem => c_reg_ldmem,
		c_reg_ldi => c_reg_ldi,
		-- Steuersignale Registerfile
		c_regfile_load_lo => c_regfile_load_lo,
		c_regfile_load_hi => c_regfile_load_hi,
		-- Steuereingänge PC
		c_pc_load => c_pc_load, 
		c_pc_inc => c_pc_inc,
		-- Steuereingang IR
		c_ir_load => c_ir_load,
		-- Signale zum Speicher
		c_mem_rd => rd, 
		c_mem_wr => wr,
		-- Auswahl Adress-Quelle
		c_adr_pc_not_reg => c_adr_pc_not_reg
		
	);
	
	
	-- Multiplexer vor Adressbus...
	process (pc_out, regfile_out0_data, c_adr_pc_not_reg)
	begin
		if c_adr_pc_not_reg = '1' then adr <= pc_out;
			else adr <= regfile_out0_data;
		end if;
	end process;

	-- Tristate-Bus
	process (mem_data_out, c_mem_wr) -- Prozess für Ausgabe
	begin
		if c_mem_wr = '1' then
			data <= mem_data_out; -- CPU treibt den Bus
		else
			data <= "ZZZZZZZZZZZZZZZZ"; -- CPU verhält sich passiv
		end if;
	end process;
	
	-- Multiplexer vor Regfile
	process (ir_out, data, alu_y)
	begin
		if c_reg_ldi = '1' then
			regfile_in_data <= ir_out;
		elsif c_reg_ldmem = '1' then	
			regfile_in_data <= data;
		elsif NOT (c_reg_ldi + c_reg_ldmem) then
			regfile_in_data <= alu_y;
		end if;
	end process;
	
	mem_data_in <= data; -- Dateneingang
	
end RTL;
