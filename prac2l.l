%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "prac2y.h"
#include "prac2types.h"
#include "./symtab/symtab.h"

extern FILE *yyin;

int return_token(int tok, char *s) {
  if (tok == ID) {
    uniontype aux;
    yylval.utype.stringValue = strdup(yytext); 

    if (sym_lookup(yylval.utype.stringValue, &aux) != SYMTAB_NOT_FOUND){
      yylval.utype.type = aux.type;
      if(aux.type == BBOOL){
        tok = ID_B;
        printf("FLEX: ID_B yytex: %s -> %s\n", yytext, yylval.utype.stringValue);
      } else {
        tok = ID;
        printf("FLEX: ID yytex: %s -> %s\n", yytext, yylval.utype.stringValue);
      }
    }
  }else if (tok == COMP) {
    yylval.utype.stringValue = strdup(yytext); 
    yylval.utype.type = BSTRING; 

    printf("FLEX: COMP yytex: %s -> %s\n", yytext, yylval.utype.stringValue);
  }else if (tok == TTRUE || tok == TFALSE) {
    yylval.utype.type = BBOOL; 
    if (tok == TTRUE){
      yylval.utype.boolValue = true;
      printf("FLEX: %s yytex: true\n", s);
    } else {
      yylval.utype.boolValue = false;
      printf("FLEX: %s yytex: false\n", s);
    }
  }else if (tok == NEWLINE) {
    printf("FLEX: NEWLINE\n");
  }else{
    printf("FLEX: %s yytex: %s\n", s, yytext);
  }
  return tok;
}

int return_utype(type t) {
  yylval.utype.type = t; 
                                       
  switch(t){
    case BINT:
      yylval.utype.intValue = atoi(yytext);  
      printf("FLEX: INT yytex: %s -> %i\n", yytext, yylval.utype.intValue);
      break;
    case BFLOAT:
      yylval.utype.floatValue = atof(yytext); 
      printf("FLEX: FLOAT yytex: %s -> %f\n", yytext, yylval.utype.floatValue);                                 
      break;
    case BSTRING:
      yylval.utype.stringValue = strdup(yytext); 
      printf("FLEX: STRING yytex: %s -> %s\n", yytext, yylval.utype.stringValue); 
      break;
    case BBOOL:
      yylval.utype.boolValue = strcmp(yytext, "true") == 0; 
      printf("FLEX: BOOL yytex: %s -> %s\n", yytext, yylval.utype.boolValue ? "true" : "false"); 
      break;
  }
  return UTYPE;
}

int error(char *msg){
  printf("FLEX ERROR: %s on line %d, yytex: %s \n", msg, yylineno, yytext);
  exit(EXIT_FAILURE);
}

int return_mode(pmode m){
  switch(m){
    case CALC:
      printf("FLEX: Detected mode CALC\n");
      break;
    case PRGM:
      printf("FLEX: Detected mode PRGM\n");
      break;
  }
  yylval.utype.intValue = m;
  return MODE;
}

#define RETURN(t) return return_token(t, #t)
#define RETURN_UTYPE(u) return return_utype(u)
#define ERROR(e) return error(e)
#define RETURN_MODE(m) return return_mode(m)
%}

%option yylineno
%option noyywrap

%x COMMENT
%x STRING
%x CALCMODE

id [a-zA-Z]+[a-zA-Z0-9]*
int [0-9]+
float {int}\.{int}
string (?:[^\"\\\n]|\\.)*
oneline_comment \/\/.*
space [ \t\r]*
 
%%

"calc"                              if(yylineno == 1) BEGIN(CALCMODE); else RETURN(ID);
<CALCMODE>"on"                      RETURN_MODE(CALC);
<CALCMODE>"off"                     RETURN_MODE(PRGM);
<CALCMODE>"\n"                      BEGIN(INITIAL); RETURN(NEWLINE);
<CALCMODE>.

"true"                              RETURN(TTRUE);
"false"                             RETURN(TFALSE);
"not"                               RETURN(NOT);
"and"                               RETURN(AND);
"or"                                RETURN(OR);

"if"                                RETURN(IF);
"then"                              RETURN(THEN);
"else"                              RETURN(ELSE);
"elsif"                             RETURN(ELSIF);
"fi"                                RETURN(FI);
"while"                             RETURN(WHILE);
"do"                                RETURN(DO);
"done"                              RETURN(DONE);
"repeat"                            RETURN(REPEAT);
"until"                             RETURN(UNTIL);
"for"                               RETURN(FOR);
"in"                                RETURN(IN);
".."                                RETURN(RANGE);
"continue"                          RETURN(CONTINUE);

"+"                                 RETURN(ADD);
"-"                                 RETURN(SUBSTRACT);
"**"                                RETURN(POW);
"mod"                               RETURN(MOD);
"*"                                 RETURN(MULTIPLY);
"/"                                 RETURN(DIVIDE);
">"                                 RETURN(COMP);
"<"                                 RETURN(COMP);
">="                                RETURN(COMP);
"<="                                RETURN(COMP);
"="                                 RETURN(COMP);
"<>"                                RETURN(COMP);
"sqrt"                              RETURN(FUNC_SQRT);
"log"                               RETURN(FUNC_LOG);
"("                                 RETURN(PARENTHESIS_OPEN);
")"                                 RETURN(PARENTHESIS_CLOSE);
":="                                RETURN(ASSIGN); 
{id}                                RETURN(ID);
{int}                               RETURN_UTYPE(BINT);
{float}                             RETURN_UTYPE(BFLOAT);
"\""                                BEGIN(STRING);
<STRING>{string}                    RETURN_UTYPE(BSTRING);
<STRING>"\""                        BEGIN(INITIAL);
"\n"                                RETURN(NEWLINE); 
\/\*                                printf("FLEX: MULTILINE COMMENT BEGIN -> "); BEGIN(COMMENT);
<COMMENT>\*\/                       printf("FLEX: MULTILINE COMMENT END -> "); BEGIN(INITIAL);
<COMMENT>\n
<COMMENT>.
<COMMENT><<EOF>>                    ERROR("unterminated comment"); 
{oneline_comment}                   printf("FLEX: COMMENT -> ");
{space}
.                                   ERROR("unknown character"); 

%%

int init_analisi_lexic(char *file_name){
  int error;

  yyin=fopen(file_name,"r");

  if(yyin == NULL){
    error = EXIT_FAILURE;
  }else{
    error = EXIT_SUCCESS;
  }

  return error;
}

int end_analisi_lexic(){
  int error = fclose(yyin);

  if (error == 0){
    error = EXIT_SUCCESS;
  }else{
    error = EXIT_FAILURE;
  }

  return error;
}
