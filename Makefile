CC = gcc
LEX = flex
YACC = bison
LIB = -lc -lfl 
ELEX = prac2l.l
EYACC = prac2y.y
OBJ = prac2.o prac2y.o prac2l.o
SRC = prac2.c symtab/symtab.c
SRCL = prac2l.c
SRCY = prac2y.c
BIN = prac2
LFLAGS = -n -o $*.c 
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g
OTHERS = prac2y.h prac2y.output

all : $(SRCL) $(SRCY)
	$(CC) -o $(BIN) $(SRCL) $(SRCY) $(SRC) $(LIB)

$(SRCL) : $(ELEX)	
	$(LEX) $(LFLAGS) $<

$(SRCY) : $(EYACC)
	$(YACC) $(YFLAGS) $<

clean : 
	rm -f *~ $(BIN) $(OBJ) $(SRCL) $(SRCY) $(OTHERS) ./outputs/*.txt

