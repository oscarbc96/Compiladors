CC = gcc
LEX = flex
YACC = bison
LIB = -lc -lfl 
ELEX = prac1l.l
EYACC = prac1y.y
OBJ = prac1.o prac1y.o prac1l.o
SRC = prac1.c symtab/symtab.c
SRCL = prac1l.c
SRCY = prac1y.c
BIN = prac1
LFLAGS = -n -o $*.c 
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g
OTHERS = prac1y.h prac1y.output

all : $(SRCL) $(SRCY)
	$(CC) -o $(BIN) $(SRCL) $(SRCY) $(SRC) $(LIB)

$(SRCL) : $(ELEX)	
	$(LEX) $(LFLAGS) $<

$(SRCY) : $(EYACC)
	$(YACC) $(YFLAGS) $<

clean : 
	rm -f *~ $(BIN) $(OBJ) $(SRCL) $(SRCY) $(OTHERS) ./outputs/*.txt

