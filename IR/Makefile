##########################
# Makefile for IR
##########################

GHDL = ghdl

SRC = ir.vhdl
TB = ir_tb

analyse: $(SRC)
	$(GHDL) -a $<
	
elaborate: analyse
	$(GHDL) -e $(TB)
	
clean:
	rm *.o
