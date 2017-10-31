#ifndef prac2typesH
#define prac2typesH

typedef enum {CALC, PRGM} pmode;

typedef enum {BINT, BFLOAT, BSTRING} type;

typedef struct{
  union {
    int intValue;
    float floatValue;
    char *stringValue;
  };
  type type;
} uniontype;

#endif