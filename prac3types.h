#ifndef prac3typesH
#define prac3typesH

#include <stdbool.h>

typedef enum {CALC, PRGM} pmode;

typedef enum {BINT, BFLOAT, BSTRING, BBOOL} type;


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
} uniontype;

#endif