#ifndef prac1typesH
#define prac1typesH

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