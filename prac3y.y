%{

#include <stdio.h>
#include <stdlib.h>
#include "prac3y.h"
#include "./symtab/symtab.h"
#include "./operations.h"
#include "./C3A.h"

#define YYLMAX 100

extern FILE *yyout;
extern int yylineno;
extern char* yytext;
extern int yylex();
extern void yyerror(const char*);
pmode current_mode;

int var_counter = 1;
int line_counter = 0;
int instructions_capacity = N_INSTRUCCIONS_ADD;
char ** instructions;

char * get_type(uniontype value){
  switch(value.type){
    case BINT:
      return "INT";
      break;
    case BFLOAT:
      return "FLOAT";
      break;
    case BSTRING:
      return "STRING";
      break;
    case BBOOL:
      return "BOOL";
      break;
  };
}

char * utype_to_string(uniontype value){
  char *str = malloc(12);
  char *aux = malloc(100);
  uniontype *auxt = &value;

  switch(value.type){
    case BINT:
      sprintf(str, "%d", value.intValue);
      break;
    case BFLOAT:
      sprintf(str, "%f", value.floatValue);
      break;
    case BSTRING:
      return value.stringValue;
      break;
    case BBOOL:
      if(value.boolValue)
        return "true";
      else
        return "false";
      break;
  };
  return str;
}


%}

%code requires {
  #include "prac3types.h"
}

%error-verbose

%union{
  uniontype utype;
}

%token <utype> MODE
%token <utype> UTYPE
%token <utype> ID
%token <utype> ID_B
%token <utype> TTRUE
%token <utype> TFALSE
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
%token SWITCH
%token CASE
%token DEFAULT
%token BREAK
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
%token COMMA
%token <utype> SQUARE_BRACKET_OPEN
%token <utype> SQUARE_BRACKET_CLOSE
%token <utype> CONTINUE
%token <utype> FUNC_SQRT
%token <utype> FUNC_LOG
%token <utype> COMP

%type <utype> statement
%type <utype> general_expression
%type <utype> expression
%type <utype> boolean_expression
%type <utype> check_mode
%type <utype> id
%type <utype> if_init
%type <utype> while_init
%type <utype> repeat_init
%type <utype> for_init
%type <utype> for_id
%type <utype> iterative_body
%type <utype> iterative_statement
%type <utype> array
%type <utype> array_statement
%type <utype> array_content
%type <utype> array_value
%type <utype> array_position

%left ADD SUBSTRACT
%left MULTIPLY DIVIDE MOD
%left POW 
%left NOT
%left AND
%left OR
%left COMP
%left PARENTHESIS_OPEN PARENTHESIS_CLOSE
%left ID_B 
%left ID
%precedence MAX_PRIORITY

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

root: root statement | statement;

statement : check_mode program_statement;

statement : id ASSIGN general_expression NEWLINE{
  sym_enter($1.stringValue, &$3);

  char * typestr = get_type($3);

  if (current_mode == CALC){
    if(!$3.array){
      char * utypestr = utype_to_string($3);
      printf("BISON: ASSIGN ID: %s TYPE: %s VALUE: %s\n", $1.stringValue, typestr, utypestr);
      fprintf(yyout, "ASSIGN ID: %s TYPE: %s VALUE: %s\n", $1.stringValue, typestr, utypestr);
    } else {
      if (!$1.empty) {
        uniontype * auxt = &$3;

        printf("BISON: ASSIGN ID: %s TYPE: ARRAY VALUE: ", $1.stringValue);
        fprintf(yyout, "ASSIGN ID: %s TYPE: ARRAY VALUE: ", $1.stringValue);
        
        while(auxt->next != NULL){
          printf("%s, ", utype_to_string(*auxt));
          fprintf(yyout,"%s, ", utype_to_string(*auxt));
          auxt = auxt->next;
        }

        printf("%s\n", utype_to_string(*auxt));
        fprintf(yyout,"%s\n", utype_to_string(*auxt));
      } else {
        printf("BISON: EXPRESSION: TYPE: ARRAY VALUE: EMPTY\n");
        fprintf(yyout, "EXPRESSION: TYPE: ARRAY VALUE: EMPTY\n");
      }
    }
  } else {
    if(!$1.array){
      //printf("BISON: ASSIGN ID: %s TYPE: %s\n", $1.stringValue, typestr);
      //fprintf(yyout, "ASSIGN ID: %s TYPE: %s\n", $1.stringValue, typestr);
      char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
      create_variable(&$$.name);
      sprintf(instruction, "%s := %s", $$.name, $3.name);
      emit(instruction);
      sprintf(instruction, "%s := %s", $1.stringValue, $$.name);
      emit(instruction);
    } else {
      printf("BISON: ASSIGN ID: %s TYPE: ARRAY\n", $1.stringValue);
      fprintf(yyout, "ASSIGN ID: %s TYPE: ARRAY\n", $1.stringValue);
    }
  }
};

statement : general_expression NEWLINE {
  char * typestr = get_type($1);
  
  if (current_mode == CALC){
    if(!$1.array){
      char * utypestr = utype_to_string($1);
      printf("BISON: EXPRESSION: TYPE: %s VALUE: %s\n", typestr, utypestr);
      fprintf(yyout, "EXPRESSION: TYPE: %s VALUE: %s\n", typestr, utypestr);
    } else {
      if (!$1.empty) {
        uniontype * auxt = &$1;

        printf("BISON: EXPRESSION: TYPE: ARRAY VALUE: ");
        fprintf(yyout, "EXPRESSION: TYPE: ARRAY VALUE: ");
        
        while(auxt->next != NULL){
          printf("%s, ", utype_to_string(*auxt));
          fprintf(yyout,"%s, ", utype_to_string(*auxt));
          auxt = auxt->next;
        }

        printf("%s\n", utype_to_string(*auxt));
        fprintf(yyout,"%s\n", utype_to_string(*auxt));
      } else {
        printf("BISON: EXPRESSION: TYPE: ARRAY VALUE: EMPTY\n");
        fprintf(yyout, "EXPRESSION: TYPE: ARRAY VALUE: EMPTY\n");
      }
    }
  } else {
    if(!$1.array){
      char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
      switch ($1.type){
        case BINT:
          sprintf(instruction, "PUTI %s", $1.name);
          break;
        case BFLOAT:
          sprintf(instruction, "PUTF %s", $1.name);
          break;
      }
      emit(instruction);
    } else {
      printf("BISON: EXPRESSION TYPE: ARRAY\n");
      fprintf(yyout, "EXPRESSION TYPE: ARRAY\n");
    }
  }
};

statement : NEWLINE {};

check_mode : { 
  printf("BISON: Checking mode\n");

  if (current_mode == CALC)
    yyerror("Program statements not allowed in PRGM mode.\n");
};

general_expression : expression | boolean_expression | array;

general_expression : ID SQUARE_BRACKET_OPEN array_position SQUARE_BRACKET_CLOSE {
  if ($3.type != BINT)
    yyerror("Position must be an int");

  if ($3.intValue < 0)
    yyerror("Position must be positive");

  uniontype* paux = (uniontype*)malloc(sizeof(uniontype));

  sym_lookup($1.stringValue, paux);
  
  if (!paux->array)
    yyerror("Value must be an array");

  if (paux->empty)
    yyerror("Index error");

  int pos = $3.intValue;
  while(pos > 0){
    paux = paux->next;
    if (paux == NULL)
      yyerror("Index error");
    pos--;
  }

  $$ = *paux;
  $$.array = false;
  $$.next = NULL;
};

array_position : ID | UTYPE;

id: ID | ID_B;

array_value : id { 
    printf("BISON: Looking for ID %s\n", $1.stringValue);
    if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND)
      yyerror("ID not defined");
  } | UTYPE { $$ = $1; } | TTRUE { $$ = $1; } | TFALSE { $$ = $1; };

array_content : array_value COMMA  { $$ = $1; } | array_value SQUARE_BRACKET_CLOSE { $$ = $1; };

array_statement : array_content array_statement { $$ = $1; $$.next = &$2; $$.array = true; $$.empty = false; } | array_content { $$ = $1; $$.next = NULL; $$.array = true; $$.empty = false;};

array : SQUARE_BRACKET_OPEN SQUARE_BRACKET_CLOSE{ $$.array = true; $$.empty = true; };

array : SQUARE_BRACKET_OPEN array_statement {
  $$ = $2;
  $$.array = true;
  $$.empty = false;
};

program_statement : if_statement | while_statement | repeat_statement | for_statement | switch_statement;

if_statement : IF if_init PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN root elsif_else_fi;

if_init : {
  printf("BISON: IF\n");
  fprintf(yyout, "IF\n");
};

elsif_else_fi : ELSIF elsif_init PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN root elsif_else_fi;

elsif_init : {
  printf("BISON: ELSIF\n");
  fprintf(yyout, "ELSIF\n");
};

elsif_else_fi : ELSE else_init root if_end;

else_init : {
  printf("BISON: ELSE\n");
  fprintf(yyout, "ELSE\n");
};

elsif_else_fi: if_end;

if_end : FI {
  printf("BISON: END_IF\n");
  fprintf(yyout, "END_IF\n");
};

switch_statement : SWITCH switch_init PARENTHESIS_OPEN id PARENTHESIS_CLOSE DO NEWLINE switch_case DONE{
  printf("BISON: END_SWITCH\n");
  fprintf(yyout, "END_SWITCH\n");
};

switch_init : {
  printf("BISON: SWITCH_INIT\n");
  fprintf(yyout, "SWITCH_INIT\n");
};

switch_case : CASE switch_case_init condition THEN root BREAK NEWLINE switch_case;

switch_case : DEFAULT switch_case_default_init THEN root BREAK NEWLINE;

switch_case_init : {
  printf("BISON: CASE\n");
  fprintf(yyout, "CASE\n");
};

switch_case_default_init : {
  printf("BISON: DEFAULT\n");
  fprintf(yyout, "DEFAULT\n");
};

while_statement: WHILE while_init PARENTHESIS_OPEN condition PARENTHESIS_CLOSE DO iterative_body DONE{
  printf("BISON: END_WHILE\n");
  fprintf(yyout, "END_WHILE\n");
};

while_init : {
  printf("BISON: WHILE\n");
  fprintf(yyout, "WHILE\n");
};

repeat_statement: REPEAT repeat_init iterative_body UNTIL PARENTHESIS_OPEN condition PARENTHESIS_CLOSE{
  printf("BISON: END_REPEAT\n");
  fprintf(yyout, "END_REPEAT\n");
}

repeat_init : {
  printf("BISON: REPEAT\n");
  fprintf(yyout, "REPEAT\n");
};

for_statement: FOR for_init PARENTHESIS_OPEN for_id IN for_range PARENTHESIS_CLOSE DO iterative_body DONE {
  printf("BISON: END_FOR\n");
  fprintf(yyout, "END_FOR\n");
}

for_init : {
  printf("BISON: FOR\n");
  fprintf(yyout, "FOR\n");
};

for_id : ID {
  printf("BISON: Looking for ID %s\n", $1.stringValue);
  if (sym_lookup($1.stringValue, &$$) != SYMTAB_NOT_FOUND)
    yyerror("ID previously defined");
}

for_range: expression RANGE expression {
  if (($1.type != BINT && $1.type != BFLOAT) || ($3.type != BINT && $3.type != BFLOAT))
    yyerror("Values in range must be integers\n");
};

condition : boolean_expression {
  if($1.type != BBOOL)
    yyerror("Expression result must be boolean");
}

iterative_body : iterative_body iterative_statement | iterative_statement;

iterative_statement : CONTINUE {
  printf("BISON: CONTINUE\n");
  fprintf(yyout, "CONTINUE\n");
};

iterative_statement : statement;

expression: FUNC_SQRT PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing sqrt function\n");
  if (current_mode == CALC){
    if (sqrt_function(&$$, $3) == OP_FAILED){
      yyerror("BISON: bad sqrt function\n");
    }
  } else if ($3.type == BINT || $3.type == BFLOAT) {
    $$.type = BFLOAT;
  } else {
    yyerror("BISON: bad sqrt function\n");
  }
};

expression: FUNC_LOG PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing log function\n");
  if (current_mode == CALC){
    if (log_function(&$$, $3) == OP_FAILED){
      yyerror("BISON: bad log function\n");
    }
  } else if ($3.type == BINT || $3.type == BFLOAT) {
    $$.type = BFLOAT;
  } else {
    yyerror("BISON: bad log function\n");
  }
};

expression: PARENTHESIS_OPEN expression PARENTHESIS_CLOSE{
  $$ = $2;
};

expression: expression POW expression {
  printf("BISON: Performing pow\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = pow_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = pow_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad **\n");
};

expression: expression MOD expression {
  printf("BISON: Performing mod\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = mod_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = mod_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad mod\n");
};

expression: expression MULTIPLY expression {
  printf("BISON: Performing multiply\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = multiply_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = multiply_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad *\n");
};

expression: expression DIVIDE expression {
  printf("BISON: Performing divide\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = divide_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = divide_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad /\n");
};

expression: expression ADD expression {
  printf("BISON: Performing add\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = add_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = add_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad +\n");
};

expression: expression SUBSTRACT expression {
  printf("BISON: Performing substract\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = substract_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = substract_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad -\n");
};

expression: SUBSTRACT expression %prec MAX_PRIORITY{
  printf("BISON: Performing negate\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = negate_operation(&$$, $2);
  else if (current_mode == PRGM)
    status = negate_operation_c3a(&$$, &$2);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad -\n");
};

expression: ID {
  printf("BISON: Looking for ID %s\n",$1.stringValue);
  if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND)
    yyerror("ID not defined");
  $$.name = $1.stringValue;
};

expression: UTYPE {
  $$ = $1;
  $$.name = utype_to_string($1);
};

boolean_expression: expression COMP expression {
  printf("BISON: Performing comparation operation\n");
  if (current_mode == CALC){
    if (compare_operation(&$$, $1, $2.stringValue, $3) == OP_FAILED){
      yyerror("BISON: bad comparation\n");
    }
  } else {
    $$.type = BBOOL;
  }
};

boolean_expression: NOT boolean_expression {
  printf("BISON: Performing not operation\n");
  if (current_mode == CALC){
    if (not_operation(&$$, $2) == OP_FAILED){
      yyerror("BISON: bad not operation\n");
    }
  } else {
    $$.type = BBOOL;
  }
};

boolean_expression: boolean_expression AND boolean_expression {
  printf("BISON: Performing and operation\n");

  if (current_mode == CALC){
    if (and_operation(&$$, $1, $3) == OP_FAILED){
      yyerror("BISON: bad and operation\n");
    }
  } else {
    $$.type = BBOOL;
  }
};

boolean_expression: boolean_expression OR boolean_expression {
  printf("BISON: Performing or operation\n");
  if (current_mode == CALC){
    if (or_operation(&$$, $1, $3) == OP_FAILED){
      yyerror("BISON: bad or operation\n");
    }
  } else {
    if (or_operation_c3a(&$$, &$1, &$3) == OP_FAILED){
      yyerror("BISON: bad or operation\n");
    }
  }
};


boolean_expression: PARENTHESIS_OPEN boolean_expression PARENTHESIS_CLOSE{
  $$ = $2;
};

boolean_expression: ID_B {
  printf("BISON: Looking for ID_B %s\n",$1.stringValue);
  if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND)
    yyerror("ID not defined");
};

boolean_expression: TTRUE | TFALSE {
  $$ = $1;
};

%%

int init_analisi_sintactic(char* filename){
  int error = EXIT_SUCCESS;

  instructions = (char**) malloc(N_INSTRUCCIONS_ADD * sizeof(char*));
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
  if (current_mode == PRGM){
    for (int i = 0; i < line_counter; i++) {
      //printf("%s\n", instructions[i]);
      fprintf(yyout, "%s\n", instructions[i]);
    }
  }
  
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
