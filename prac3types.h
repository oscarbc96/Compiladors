#ifndef prac3typesH
#define prac3typesH

#include <stdbool.h>

typedef enum {CALC, PRGM} pmode;

typedef enum {BINT, BFLOAT, BSTRING, BBOOL} type;

typedef struct {
  int line_number;
  struct line *next;
} line;

typedef struct{
  union {
    int intValue;
    float floatValue;
    char *stringValue;
    bool boolValue;
  };
  type type;
  void* next;
  bool array;
  bool empty;
  char *name;
  line *trueList;
  line *falseList;
  line *nextList;
} uniontype;

#endif