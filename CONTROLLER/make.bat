ghdl -a controller.vhdl controller_tb.vhdl
ghdl -d
ghdl -e controller_tb
ghdl -r controller_tb --wave=controller_tb.ghw
