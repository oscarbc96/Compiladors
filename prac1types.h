#ifndef prac1typesH
#define prac1typesH

#include <stdbool.h>

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