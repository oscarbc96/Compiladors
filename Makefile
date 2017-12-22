CC = gcc
LEX = flex
YACC = bison
LIB = -lc -lfl 
ELEX = prac3l.l
EYACC = prac3y.y
OBJ = prac3.o prac3y.o prac3l.o
SRC = prac3.c symtab/symtab.c operations.c C3A.c bison_aux.c
SRCL = prac3l.c
SRCY = prac3y.c
BIN = prac3
LFLAGS = -n -o $*.c 
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g
OTHERS = prac3y.h prac3y.output

all : $(SRCL) $(SRCY)
	$(CC) -o $(BIN) $(SRCL) $(SRCY) $(SRC) $(LIB)

$(SRCL) : $(ELEX)	
	$(LEX) $(LFLAGS) $<

$(SRCY) : $(EYACC)
	$(YACC) $(YFLAGS) $<
clean : 
	rm -f *~ $(BIN) $(OBJ) $(SRCL) $(SRCY) $(OTHERS) ./output/* ./debug/*

test : clean all
	for filename in ./input/program_statement_*.txt; do \
		file=$$(basename $$filename); \
		echo "Running "$$filename; \
    ./$(BIN) ./input/$$file ./output/$$file &> ./debug/$$file; \
    python3 diff.py --from ./output/$$file --to ./expected/$$file; \
  done