ghdl -a alu.vhdl alu_tb.vhdl
ghdl -d
ghdl -e alu_tb
ghdl -r alu_tb --wave=alu_tb.ghw
