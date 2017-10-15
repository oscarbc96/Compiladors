%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "prac1y.h"
#include "prac1types.h"

extern FILE *yyin;

int return_token(int tok, char *s) {
  if (tok == ID || tok == COMP || tok == FUNC) {
    yylval.utype.stringValue = strdup(yytext); 
    yylval.utype.type = BSTRING; 

    if (tok == ID){
      printf("FLEX: ID yytex: %s -> %s\n", yytext, yylval.utype.stringValue);
    }else if (tok == COMP){
      printf("FLEX: COMP yytex: %s -> %s\n", yytext, yylval.utype.stringValue);
    }else if (tok == FUNC) {
      printf("FLEX: FUNC yytex: %s -> %s\n", yytext, yylval.utype.stringValue);
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
  }
  return UTYPE;
}

int error(char *msg){
  printf("FLEX ERROR: %s on line %d, yytex: %s \n", msg, yylineno, yytext);
  exit(EXIT_FAILURE);
}

#define RETURN(t) return return_token(t, #t)
#define RETURN_UTYPE(u) return return_utype(u)
#define ERROR(e) return error(e)

%}

%option yylineno
%option noyywrap

%x COMMENT
%x STRING

id [a-zA-Z]+[a-zA-Z0-9]*
int (-?[1-9]+[0-9]*|0)
float (-[1-9]\.[0-9]+|-0\.[1-9]+[0-9]*|[0-9]+\.[0-9]+|0\.0)
string (?:[^\"\\\n]|\\.)*
oneline_comment \/\/.*
multiline_comment_open \/\*(?:[^\*\/\n])*
multiline_comment_body \\*[^*]*\\*+(?:[^/*][^*]*\\*+)*
multiline_comment_close \/
space [ \t\r]*
 
%%

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
"=="                                RETURN(COMP);
"!="                                RETURN(COMP);
"sqrt"                              RETURN(FUNC);
"log"                               RETURN(FUNC);
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
\/\*                                {printf("FLEX: MULTILINE COMMENT BEGIN -> "); BEGIN(COMMENT);}
<COMMENT>\*\/                       {printf("FLEX: MULTILINE COMMENT END -> "); BEGIN(INITIAL);}
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
