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

SRC = REGFILE/regfile.vhdl IR/ir.vhdl PC/pc.vhdl ALU/alu.vhdl CONTROLLER/controller.vhdl CPU/CPU.vhdl CPU/CPU_TB.vhdl
OBJ = $(SRC:.vhdl=.o)
OBJL = regfile.o ir.o pc.o alu.o controller.o CPU.o CPU_TB.o
TB = cpu_tb

## Build ##

lanalyse: $(SRC)
	$(GHDL) -a $(SRC)

wanalyse: $(SRC)
	$(GHDL) -a $(SRC)

lelaborate: $(OBJL)
	$(GHDL) -e $(TB)
	
welaborate: analyse
	$(GHDL) -e $(TB)
	
lwave: lelaborate
	./$(TB) --wave=$(TB).ghw

wwave: welaborate
	$(GHDL) -r $(TB) --wave=$(TB).ghw

%.o: %.vhdl
	$(GHDL) -a $<
	
### Clean ###

lclean:
	rm *.o *.cf *.ghw

wclean:
	del *.o
	del *.cf
	del *.ghw
