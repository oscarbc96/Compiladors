#ifndef prac2typesH
#define prac2typesH

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
} uniontype;

#endif