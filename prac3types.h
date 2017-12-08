#ifndef prac3typesH
#define prac3typesH

#include <stdbool.h>

typedef enum {CALC, PRGM} pmode;

typedef enum {BINT, BFLOAT, BSTRING, BBOOL} type;

typedef struct {
  int line_number;
  void* next;
} line;

typedef struct{
  union {
    int intValue;
    double floatValue;
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