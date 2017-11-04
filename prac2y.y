%{

#include <stdio.h>
#include <stdlib.h>
#include "prac2y.h"
#include "./symtab/symtab.h"
#include "./operations.h"

#define YYLMAX 100

extern FILE *yyout;
extern int yylineno;
extern char* yytext;
extern int yylex();
extern void yyerror(const char*);
pmode current_mode;

%}

%code requires {
  #include "prac2types.h"
}

%error-verbose

%union{
  uniontype utype;
}

%token <utype> MODE
%token <utype> UTYPE
%token <utype> ID
%token NOT
%token AND
%token OR
%token IF
%token THEN
%token ELSE
%token ELSIF
%token FI
%token WHILE
%token DO
%token DONE
%token REPEAT
%token UNTIL
%token FOR
%token IN
%token RANGE
%token NEWLINE
%token ASSIGN
%token ADD
%token SUBSTRACT
%token MULTIPLY
%token DIVIDE
%token POW
%token MOD
%token PARENTHESIS_OPEN
%token PARENTHESIS_CLOSE
%token <utype> FUNC_SQRT
%token <utype> FUNC_LOG
%token <utype> COMP

%type <utype> primitive
%type <utype> statement
%type <utype> expression
%type <utype> boolean_expression

%left ADD SUBSTRACT
%left MULTIPLY DIVIDE MOD
%left POW COMP
%left NOT
%left AND
%left OR
%left PARENTHESIS_OPEN PARENTHESIS_CLOSE
%left MODE

%start start
%%

start: calc root;

calc: MODE {
  current_mode = $1.intValue;

  switch(current_mode){
    case CALC:
      printf("BISON: Starting in mode CALC\n");
      break;
    case PRGM:
      printf("BISON: Starting in mode PRGM\n");
      break;
  }
};

root:
  root statement | statement;

statement : program_statement;

program_statement : if_statement | while_statement | repeat_statement | for_statement;

if_statement : IF PARENTHESIS_OPEN boolean_expression PARENTHESIS_CLOSE THEN root elsif_else_fi{
  if ($3.type != BBOOL) {
    yyerror("The value between parentheses must be a boolean expression");
  } else {
    printf("BISON: IF %s\n", $3.boolValue ? "true" : "false");
    fprintf(yyout, "IF %s\n", $3.boolValue ? "true" : "false");
  }
};


elsif_else_fi : ELSIF PARENTHESIS_OPEN boolean_expression PARENTHESIS_CLOSE THEN root elsif_else_fi {
  if ($3.type != BBOOL) {
    yyerror("The value between parentheses must be a boolean expression");
  } else {
    printf("BISON: ELSIF %s\n", $3.boolValue ? "true" : "false");
    fprintf(yyout, "ELSIF %s\n", $3.boolValue ? "true" : "false");
  }
};

elsif_else_fi : ELSE root if_end {
  printf("BISON: ELSE\n");
  fprintf(yyout, "ELSE\n");
};

elsif_else_fi: if_end;

if_end : FI {
  printf("BISON: FI\n");
  fprintf(yyout, "FI\n");
};

while_statement: WHILE PARENTHESIS_OPEN boolean_expression PARENTHESIS_CLOSE DO root DONE{
  if ($3.type != BBOOL) {
    yyerror("The value between parentheses must be a boolean expression");
  } else {
    printf("BISON: WHILE %s\n", $3.boolValue ? "true" : "false");
    fprintf(yyout, "WHILE %s\n", $3.boolValue ? "true" : "false");
  }
};

repeat_statement: REPEAT root UNTIL PARENTHESIS_OPEN boolean_expression PARENTHESIS_CLOSE{
  if ($5.type != BBOOL) {
    yyerror("The value between parentheses must be a boolean expression");
  } else {
    printf("BISON: WHILE %s\n", $5.boolValue ? "true" : "false");
    fprintf(yyout, "WHILE %s\n", $5.boolValue ? "true" : "false");
  }
}

for_statement: FOR PARENTHESIS_OPEN ID IN expression RANGE expression PARENTHESIS_CLOSE DO root DONE {
  if ($5.type != BBOOL) {
    yyerror("The value between parentheses must be a boolean expression");
  } else {
    printf("BISON: FOR %s\n", $5.boolValue ? "true" : "false");
    fprintf(yyout, "FOR %s\n", $5.boolValue ? "true" : "false");
  }
}

boolean_expression : expression;

boolean_expression: NOT boolean_expression {
  printf("BISON: Performing not operation\n");
  if (not_operation(&$$, $2) == OP_FAILED)
    yyerror("BISON: bad not operation\n");
};

boolean_expression: boolean_expression AND boolean_expression {
  printf("BISON: Performing and operation\n");
  if (and_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad and operation\n");
};

boolean_expression: boolean_expression OR boolean_expression {
  printf("BISON: Performing or operation\n");
  if (or_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad or operation\n");
};

statement : ID ASSIGN expression NEWLINE{
  sym_enter($1.stringValue, &$3);
  switch($3.type){
    case BINT:
      printf("BISON: ID: %s TYPE: INT VALUE: %i\n",$1.stringValue, $3.intValue);
      fprintf(yyout, "ID: %s TYPE: INT VALUE: %i\n",$1.stringValue, $3.intValue);
      break;
    case BFLOAT:
      printf("BISON: ID: %s TYPE: FLOAT VALUE: %f\n",$1.stringValue, $3.floatValue);
      fprintf(yyout, "ID: %s TYPE: FLOAT VALUE: %f\n",$1.stringValue, $3.floatValue);
      break;
    case BSTRING:
      printf("BISON: ID: %s TYPE: STRING VALUE: %s\n",$1.stringValue, $3.stringValue);
      fprintf(yyout, "ID: %s TYPE: STRING VALUE: %s\n",$1.stringValue, $3.stringValue);
      break;
    case BBOOL:
      printf("BISON: ID: %s TYPE: BOOL VALUE: %s\n",$1.stringValue, $3.boolValue ? "true" : "false");
      fprintf(yyout, "ID: %s TYPE: BOOL VALUE: %s\n",$1.stringValue, $3.boolValue ? "true" : "false");
      break;
  }
};

statement : expression NEWLINE {
  switch($1.type){
    case BINT:
      printf("BISON: EXPRESSION: TYPE: INT VALUE: %i\n",$1.intValue);
      fprintf(yyout, "EXPRESSION: TYPE: INT VALUE: %i\n",$1.intValue);
      break;
    case BFLOAT:
      printf("BISON: EXPRESSION: TYPE: FLOAT VALUE: %f\n",$1.floatValue);
      fprintf(yyout, "EXPRESSION: TYPE: FLOAT VALUE: %f\n",$1.floatValue);
      break;
    case BSTRING:
      printf("BISON: EXPRESSION: TYPE: STRING VALUE: %s\n",$1.stringValue);
      fprintf(yyout, "EXPRESSION: TYPE: STRING VALUE: %s\n",$1.stringValue);
      break;
    case BBOOL:
      printf("BISON: EXPRESSION: TYPE: TYPE: BOOL VALUE: %s\n",$1.boolValue ? "true" : "false");
      fprintf(yyout, "EXPRESSION: TYPE: TYPE: BOOL VALUE: %s\n",$1.boolValue ? "true" : "false");
      break;
  };
};

statement : NEWLINE {};

expression: FUNC_SQRT PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing sqrt function\n");
  if (sqrt_function(&$$, $3) == OP_FAILED)
    yyerror("BISON: bad sqrt function\n");
};

expression: FUNC_LOG PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing log function\n");
  if (log_function(&$$, $3) == OP_FAILED)
    yyerror("BISON: bad log function\n");
};

expression: expression COMP expression {
  printf("BISON: Performing comparation operation\n");
  if (compare_operation(&$$, $1, $2.stringValue, $3) == OP_FAILED)
    yyerror("BISON: bad comparation\n");
}

expression: PARENTHESIS_OPEN expression PARENTHESIS_CLOSE{
  $$ = $2;
};

expression: expression POW expression {
  printf("BISON: Performing pow\n");
  if (pow_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad **\n");
};

expression: expression MOD expression {
  printf("BISON: Performing mod\n");
  if (pow_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad mod\n");
};

expression: expression MULTIPLY expression {
  printf("BISON: Performing multiply\n");
  if (multiply_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad *\n");
};

expression: expression DIVIDE expression {
  printf("BISON: Performing divide\n");
  if (divide_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad /\n");
};

expression: expression ADD expression {
  printf("BISON: Performing add\n");
  if (add_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad +\n");
};

expression: expression SUBSTRACT expression {
  printf("BISON: Performing substract\n");
  if (substract_operation(&$$, $1, $3) == OP_FAILED)
    yyerror("BISON: bad -\n");
};

expression: primitive;

primitive: ID {
  printf("BISON: Looking for ID %s\n",$1.stringValue);
  if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND)
    yyerror("ID not defined");
};

primitive: UTYPE {
  $$ = $1;
};

%%

int init_analisi_sintactic(char* filename){
  int error = EXIT_SUCCESS;

  yyout = fopen(filename,"w");

  if (yyout == NULL)
    error = EXIT_FAILURE;

  return error;
}

int analisi_semantic(){
  int error;

  if (yyparse() == 0)
    error =  EXIT_SUCCESS;
  else
    error =  EXIT_FAILURE;

 return error;

}

int end_analisi_sintactic(){
  int error = fclose(yyout);

  if(error == 0)
    error = EXIT_SUCCESS;
  else
    error = EXIT_FAILURE;

  return error;
}

void yyerror(const char *explanation){
  fprintf(stderr,"BISON ERROR: %s, in line %d \n",explanation,yylineno);
  exit(EXIT_FAILURE);
}
