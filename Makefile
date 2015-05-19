##################################################
## Makefile for the VISCY components
##
## Targets die mit "l" beginnen sind für Linux
## und die mit "w" beginnen für Windows.
##
## mit "make wwave" werden beispielsweise unter
## Windows alle Dateien analysiert die cpu_tb
## elaboriert und die cpu_tb.ghw Datei erzeugt.
##
## Das Programm "make" gibt es auch für Windows
## zum Download.
##################################################

GHDL = ghdl

SRC = REGFILE/regfile.vhdl IR/ir.vhdl PC/pc.vhdl ALU/alu.vhdl CONTROLLER/controller.vhdl CPU/CPU.vhdl CPU/CPU_tb.vhdl
OBJ = $(SRC:.vhdl=.o)
TB = cpu_tb

## Build ##

analyse: $(SRC)
	$(GHDL) -a $(SRC)
	
elaborate: analyse
	$(GHDL) -e $(TB)
	
lwave: elaborate
	./$(TB) --wave=$(TB).ghw

wwave: elaborate
	$(GHDL) -r $(TB) --wave=$(TB).ghw
	
### Clean ###

lclean:
	rm *.o *.cf *.ghw

wclean:
	del *.o
	del *.cf
	del *.ghw
