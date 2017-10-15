%{

#include <stdio.h>
#include <stdlib.h>
#include "prac1y.h"
#include "./symtab/symtab.h"
#include <math.h>
#include <string.h>

#define YYLMAX 100

extern FILE *yyout;
extern int yylineno;
extern char* yytext;
extern void yyerror(char*);

%}

%code requires {
  #include "prac1types.h"
}

%error-verbose

%union{
  uniontype utype;
}

%token <utype> UTYPE
%token <utype> ID
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
%token <utype> FUNC
%token <utype> COMP

%type <utype> statement
%type <utype> expression

%left ADD SUBSTRACT
%left MULTIPLY DIVIDE MOD
%left POW COMP
%left PARENTHESIS_OPEN PARENTHESIS_CLOSE

%%

root:
    root statement | statement;

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
  };
};

statement : NEWLINE {};

expression: FUNC PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing function\n");
  if (strcmp($1.stringValue, "sqrt") == 0) {
    $$.type = BFLOAT;
    if($3.type == BFLOAT){
      $$.floatValue = sqrt($3.floatValue);
    }else if($3.type == BINT){
      $$.floatValue = sqrt($3.intValue);
    }else{
      yyerror("bad sqrt function");
    }
  } else if (strcmp($1.stringValue, "log") == 0){
    $$.type = BFLOAT;
    if($3.type == BFLOAT){
      $$.floatValue = log($3.floatValue);
    }else if($3.type == BINT){
      $$.floatValue = log($3.intValue);
    }else{
      yyerror("bad log function");
    }
  }else{
    yyerror("bad function");
  }
};

expression: expression COMP expression {
  printf("BISON: Performing comparation\n");
  $$.type = BINT;
  if($1.type == BSTRING && $3.type == BSTRING){
    $$.intValue = strcmp($1.stringValue, $3.stringValue);
  }else if($1.type == BINT && $3.type == BINT){
    if (strcmp($2.stringValue, ">") == 0) {
      $$.intValue = $1.intValue > $3.intValue;
    } else if (strcmp($2.stringValue, "<") == 0) {
      $$.intValue = $1.intValue < $3.intValue;
    } else if (strcmp($2.stringValue, ">=") == 0) {
      $$.intValue = $1.intValue >= $3.intValue;
    } else if (strcmp($2.stringValue, "<=") == 0) {
      $$.intValue = $1.intValue <= $3.intValue;
    } else if (strcmp($2.stringValue, "==") == 0) {
      $$.intValue = $1.intValue == $3.intValue;
    } else if (strcmp($2.stringValue, "!=") == 0) {
      $$.intValue = $1.intValue != $3.intValue;
    }
  }else if($1.type == BFLOAT && $3.type == BFLOAT){
    if (strcmp($2.stringValue, ">") == 0) {
      $$.intValue = $1.floatValue > $3.floatValue;
    } else if (strcmp($2.stringValue, "<") == 0) {
      $$.intValue = $1.floatValue < $3.floatValue;
    } else if (strcmp($2.stringValue, ">=") == 0) {
      $$.intValue = $1.floatValue >= $3.floatValue;
    } else if (strcmp($2.stringValue, "<=") == 0) {
      $$.intValue = $1.floatValue <= $3.floatValue;
    } else if (strcmp($2.stringValue, "==") == 0) {
      $$.intValue = $1.floatValue == $3.floatValue;
    } else if (strcmp($2.stringValue, "!=") == 0) {
      $$.intValue = $1.floatValue != $3.floatValue;
    }
  }else if($1.type == BFLOAT && $3.type == BINT){
    if (strcmp($2.stringValue, ">") == 0) {
      $$.intValue = $1.floatValue > $3.intValue;
    } else if (strcmp($2.stringValue, "<") == 0) {
      $$.intValue = $1.floatValue < $3.intValue;
    } else if (strcmp($2.stringValue, ">=") == 0) {
      $$.intValue = $1.floatValue >= $3.intValue;
    } else if (strcmp($2.stringValue, "<=") == 0) {
      $$.intValue = $1.floatValue <= $3.intValue;
    } else if (strcmp($2.stringValue, "==") == 0) {
      $$.intValue = $1.floatValue == $3.intValue;
    } else if (strcmp($2.stringValue, "!=") == 0) {
      $$.intValue = $1.floatValue != $3.intValue;
    }
  }else if($1.type == BINT && $3.type == BFLOAT){
    if (strcmp($2.stringValue, ">") == 0) {
      $$.intValue = $1.intValue > $3.floatValue;
    } else if (strcmp($2.stringValue, "<") == 0) {
      $$.intValue = $1.intValue < $3.floatValue;
    } else if (strcmp($2.stringValue, ">=") == 0) {
      $$.intValue = $1.intValue >= $3.floatValue;
    } else if (strcmp($2.stringValue, "<=") == 0) {
      $$.intValue = $1.intValue <= $3.floatValue;
    } else if (strcmp($2.stringValue, "==") == 0) {
      $$.intValue = $1.intValue == $3.floatValue;
    } else if (strcmp($2.stringValue, "!=") == 0) {
      $$.intValue = $1.intValue != $3.floatValue;
    }
  }else{
    yyerror("bad comparator");
  }
}

expression: PARENTHESIS_OPEN expression PARENTHESIS_CLOSE{
  $$ = $2;
};

expression: expression POW expression {
  printf("BISON: Performing pow\n");
  if($1.type == BINT && $3.type == BINT){
    $$.intValue = pow($1.intValue, $3.intValue);
    $$.type = BINT;
  }else if($1.type == BFLOAT || $3.type == BFLOAT){
    $$.type = BFLOAT;

    if($1.type == BFLOAT && $3.type == BFLOAT){
      $$.floatValue = pow($1.floatValue, $3.floatValue);
    }else if($1.type == BFLOAT && $3.type == BINT){
      $$.floatValue = pow($1.floatValue, $3.intValue);
    }else if($1.type == BINT && $3.type == BFLOAT){
      $$.floatValue = pow($1.intValue, $3.floatValue);
    }
  }else{
    yyerror("bad **");
  }
};

expression: expression MOD expression {
  printf("BISON: Performing mod\n");
  if($1.type == BINT && $3.type == BINT){
    $$.intValue = $1.intValue % $3.intValue;
    $$.type = BINT;
  }else if($1.type == BFLOAT || $3.type == BFLOAT){
    $$.type = BFLOAT;

    if($1.type == BFLOAT && $3.type == BFLOAT){
      $$.floatValue = fmodf($1.floatValue, $3.floatValue);
    }else if($1.type == BFLOAT && $3.type == BINT){
      $$.floatValue = fmodf($1.floatValue, $3.intValue);
    }else if($1.type == BINT && $3.type == BFLOAT){
      $$.floatValue = fmodf($1.intValue, $3.floatValue);
    }
  }else{
    yyerror("bad mod");
  }
};

expression: expression MULTIPLY expression {
  printf("BISON: Performing multiply\n");
  if($1.type == BINT && $3.type == BINT){
    $$.intValue = $1.intValue * $3.intValue;
    $$.type = BINT;
  }else if($1.type == BFLOAT || $3.type == BFLOAT){
    $$.type = BFLOAT;

    if($1.type == BFLOAT && $3.type == BFLOAT){
      $$.floatValue = $1.floatValue * $3.floatValue;
    }else if($1.type == BFLOAT && $3.type == BINT){
      $$.floatValue = $1.floatValue * $3.intValue;
    }else if($1.type == BINT && $3.type == BFLOAT){
      $$.floatValue = $1.intValue * $3.floatValue;
    }
  }else{
    yyerror("bad *");
  }
};

expression: expression DIVIDE expression {
  printf("BISON: Performing divide\n");
  if(($3.type == BINT && $3.intValue == 0) || ($3.type == BFLOAT && $3.floatValue == 0.0)){
    yyerror("bad /, divided by 0");
  }

  if($1.type == BINT && $3.type == BINT){
    $$.intValue = $1.intValue / $3.intValue;
    $$.type = BINT;
  }else if($1.type == BFLOAT || $3.type == BFLOAT){
    $$.type = BFLOAT;

    if($1.type == BFLOAT && $3.type == BFLOAT){
      $$.floatValue = $1.floatValue / $3.floatValue;
    }else if($1.type == BFLOAT && $3.type == BINT){
      $$.floatValue = $1.floatValue / $3.intValue;
    }else if($1.type == BINT && $3.type == BFLOAT){
      $$.floatValue = $1.intValue / $3.floatValue;
    }
  }else{
    yyerror("bad /");
  }
};

expression: expression ADD expression {
  printf("BISON: Performing add\n");
  if($1.type == BSTRING || $3.type == BSTRING){
    $$.type = BSTRING;

    if($1.type == BSTRING && $3.type == BSTRING){
      char * aux = (char *) malloc(1 + strlen($1.stringValue)+ strlen($3.stringValue));
      strcpy(aux, $1.stringValue);
      strcat(aux, $3.stringValue);
      $$.stringValue = aux;
    }else if($1.type == BSTRING && $3.type == BINT){
      char * aux = (char *) malloc(1 + strlen($1.stringValue) + 11);
      sprintf(aux, "%s%i", $1.stringValue, $3.intValue);
      $$.stringValue = aux;
    }else if($1.type == BINT && $3.type == BSTRING){
      char * aux = (char *) malloc(1 + strlen($3.stringValue) + 11);
      sprintf(aux, "%i%s", $1.intValue, $3.stringValue);
      $$.stringValue = aux;
    }else if($1.type == BSTRING && $3.type == BFLOAT){
      char * aux = (char *) malloc(1 + strlen($1.stringValue) + 11);
      sprintf(aux, "%s%f", $1.stringValue, $3.floatValue);
      $$.stringValue = aux;
    }else if($1.type == BFLOAT && $3.type == BSTRING){
      char * aux = (char *) malloc(1 + strlen($3.stringValue) + 11);
      sprintf(aux, "%f%s", $1.floatValue, $3.stringValue);
      $$.stringValue = aux;
    }
  }else if($1.type == BINT && $3.type == BINT){
    $$.intValue = $1.intValue + $3.intValue;
    $$.type = BINT;
  }else if($1.type == BFLOAT || $3.type == BFLOAT){
    $$.type = BFLOAT;

    if($1.type == BFLOAT && $3.type == BFLOAT){
      $$.floatValue = $1.floatValue + $3.floatValue;
    }else if($1.type == BFLOAT && $3.type == BINT){
      $$.floatValue = $1.floatValue + $3.intValue;
    }else if($1.type == BINT && $3.type == BFLOAT){
      $$.floatValue = $1.intValue + $3.floatValue;
    }
  }else{
    yyerror("bad +");
  }
};

expression: expression SUBSTRACT expression {
  printf("BISON: Performing substract\n");
  if($1.type == BINT && $3.type == BINT){
    $$.intValue = $1.intValue - $3.intValue;
    $$.type = BINT;
  }else if($1.type == BFLOAT || $3.type == BFLOAT){
    $$.type = BFLOAT;

    if($1.type == BFLOAT && $3.type == BFLOAT){
      $$.floatValue = $1.floatValue - $3.floatValue;
    }else if($1.type == BFLOAT && $3.type == BINT){
      $$.floatValue = $1.floatValue - $3.intValue;
    }else if($1.type == BINT && $3.type == BFLOAT){
      $$.floatValue = $1.intValue - $3.floatValue;
    }
  }else{
    yyerror("bad -");
  }
};

expression: ID {
  printf("BISON: Looking for ID %s\n",$1.stringValue);
  if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND){
    yyerror("ID not defined");
  }
};

expression: UTYPE {
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

void yyerror(char *explanation){
  fprintf(stderr,"BISON ERROR: %s, in line %d \n",explanation,yylineno);
  exit(EXIT_FAILURE);
}
