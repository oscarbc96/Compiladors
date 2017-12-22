%{

#include <stdio.h>
#include <stdlib.h>
#include "prac3y.h"
#include "./symtab/symtab.h"
#include "./operations.h"
#include "./C3A.h"
#include "./bison_aux.h"

#define YYLMAX 100

extern FILE *yyout;
extern int yylineno;
extern char* yytext;
extern int yylex();
extern void yyerror(const char*);

pmode current_mode;
uniontype current_switch_id;

int var_counter = 1;
int line_counter = 0;
int instructions_capacity = N_INSTRUCCIONS_ADD;
char ** instructions;

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
%type <utype> for_init
%type <utype> for_id
%type <utype> iterative_body
%type <utype> iterative_statement
%type <utype> array
%type <utype> array_statement
%type <utype> array_content
%type <utype> array_value
%type <utype> array_position

%type <utype> if_statement
%type <utype> elsif_recursion
%type <utype> elsif_statement
%type <utype> root
%type <utype> condition
%type <utype> while_statement
%type <utype> program_statement
%type <utype> save_position
%type <utype> goto_exit
%type <utype> for_statement
%type <utype> repeat_statement
%type <utype> switch_statement
%type <utype> switch_id
%type <utype> switch_case_default_init
%type <utype> switch_case
%type <utype> switch_case_default
%type <utype> switch_condition

%left ADD SUBSTRACT
%left MULTIPLY DIVIDE MOD
%left POW 
%left NOT
%left OR
%left AND
%left COMP
%left PARENTHESIS_OPEN PARENTHESIS_CLOSE
%left ID_B 
%left ID
%precedence MAX_PRIORITY

%start start
%%

start: calc NEWLINE root save_position {
  if (current_mode == PRGM){
    emit("HALT");
    complete($3.nextList, $4.intValue + 1);
  }
};

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

root: root save_position statement{ 
  $$ = $3; 
  complete($1.nextList, $2.intValue + 1); 
} | statement ;

statement : check_mode program_statement { $$ = $2; };

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
      char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));

      if (!reg_matches($3.name, "\\$t[0-9]+")){
        create_variable(&$$.name);
        sprintf(instruction, "%s := %s", $$.name, $3.name);
        emit(instruction);
        sprintf(instruction, "%s := %s", $1.stringValue, $$.name);
      } else {
        sprintf(instruction, "%s := %s", $1.stringValue, $3.name);
      }

      emit(instruction);

      free(instruction);
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
      sprintf(instruction, "PARAM %s", $1.name);
      emit(instruction);

      switch ($1.type){
        case BINT:
          sprintf(instruction, "CALL PUTI,1");
          break;
        case BFLOAT:
          sprintf(instruction, "CALL PUTF,1");
          break;
      }
      emit(instruction);

      free(instruction);
    } else {
      printf("BISON: EXPRESSION TYPE: ARRAY\n");
      fprintf(yyout, "EXPRESSION TYPE: ARRAY\n");
    }
  }
};

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

save_position : { 
  $$.intValue = line_counter;
}

goto_exit : { 
  emit("GOTO"); 
  $$.nextList = create_line(line_counter);
}

program_statement : if_statement | while_statement | repeat_statement | for_statement | switch_statement;

if_statement : IF PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN NEWLINE save_position root FI NEWLINE {
  complete($3.trueList, $7.intValue + 1);
  $$.trueList = NULL;
  $$.falseList = NULL;
  $$.nextList = merge($3.falseList, $8.nextList);
};

if_statement : IF PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN NEWLINE save_position root ELSE NEWLINE goto_exit save_position root FI NEWLINE{
  complete($3.trueList, $7.intValue + 1);
  complete($3.falseList, $12.intValue + 1);
  $$.trueList = NULL;
  $$.falseList = NULL;
  $$.nextList = merge($11.nextList, merge($8.nextList, $13.nextList));
};

if_statement : IF PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN NEWLINE save_position root elsif_recursion ELSE NEWLINE goto_exit root FI NEWLINE{
  complete($3.trueList, $7.intValue + 1);
  complete($3.falseList, $9.intValue);
  $$.trueList = NULL;
  $$.falseList = NULL;
  $$.nextList = merge($12.nextList, merge($8.nextList, merge($9.nextList, $13.nextList)));
};

elsif_recursion : elsif_recursion elsif_statement {
  $$.intValue =  $1.intValue;
  $$.trueList = merge($1.trueList, $2.trueList);
  $$.falseList = NULL;
  $$.nextList = merge($1.nextList, $2.nextList);
}| elsif_statement;

elsif_statement : goto_exit ELSIF PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN NEWLINE save_position root save_position{
  $$.intValue = $8.intValue - 1;
  complete($4.trueList, $8.intValue + 1);
  complete($4.falseList, $10.intValue + 2);
  $$.trueList = NULL;
  $$.falseList = NULL;
  $$.nextList = merge($1.nextList, $9.nextList);
};

switch_statement : SWITCH PARENTHESIS_OPEN switch_id PARENTHESIS_CLOSE DO NEWLINE switch_case DONE NEWLINE{
  $$ = $7;
};

switch_id: id {
  printf("BISON: Looking for ID %s\n",$1.stringValue);
  if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND)
    yyerror("ID not defined");
  $$.name = $1.stringValue;
  current_switch_id = $$;
}

switch_condition : UTYPE {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  sprintf(instruction, "IF %s EQ %s GOTO", current_switch_id.name, utype_to_string($1));
  emit(instruction);
  $$.trueList = create_line(line_counter);
  sprintf(instruction, "GOTO");
  emit(instruction);
  free(instruction);
  $$.falseList = create_line(line_counter);
  $$.intValue = line_counter;
};

switch_case : CASE switch_condition THEN NEWLINE save_position root BREAK NEWLINE switch_case_default {
  complete($2.trueList, $5.intValue + 1);
  complete($2.falseList, $9.intValue - 1);
  $$.nextList = merge($6.nextList, $9.nextList);
};

switch_case_default_init : {
  emit("GOTO"); 
  $$.intValue = line_counter + 2; 
  $$.trueList = NULL; 
  $$.falseList = create_line(line_counter);
  $$.nextList = NULL;
};

switch_case_default: switch_case_default_init switch_case { 
  $$.nextList = merge($1.falseList, $2.nextList);
};

switch_case_default: switch_case_default_init DEFAULT THEN NEWLINE root BREAK NEWLINE { 
  $$.nextList = $1.falseList;
};

while_statement: WHILE save_position PARENTHESIS_OPEN condition PARENTHESIS_CLOSE DO NEWLINE save_position iterative_body DONE NEWLINE{
  complete($4.trueList, $8.intValue + 1);
  complete($9.nextList, $2.intValue + 1);
  complete($9.trueList, $2.intValue + 1);
  emit("GOTO");
  complete(create_line(line_counter), $2.intValue + 1);
  $$.trueList = NULL;
  $$.falseList = NULL;
  $$.nextList = merge($4.falseList, $9.falseList);
};

repeat_statement: REPEAT NEWLINE save_position iterative_body UNTIL PARENTHESIS_OPEN save_position condition PARENTHESIS_CLOSE NEWLINE{
  complete($8.trueList, $3.intValue + 1);
  complete($4.nextList, $7.intValue + 1);
  complete($4.trueList, $3.intValue + 1);
  $$.trueList = NULL;
  $$.falseList = NULL;
  $$.nextList = merge($4.falseList, merge($8.falseList, $4.nextList));
}

for_statement: for_init save_position iterative_body DONE NEWLINE {
  complete($1.trueList, $2.intValue + 1);
  complete($3.trueList, $2.intValue - 1);

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  sprintf(instruction, "%s := %s ADDI %s", $1.name, $1.name, "1");
  emit(instruction);
  free(instruction);

  emit("GOTO");
  complete(create_line(line_counter), $1.intValue);
  $$.trueList = NULL;
  $$.falseList = NULL;
  complete($3.nextList, line_counter - 1);
  $$.nextList = merge($1.falseList, $3.falseList);
}

for_id : ID {
  printf("BISON: Looking for ID %s\n", $1.stringValue);
  if (sym_lookup($1.stringValue, &$$) != SYMTAB_NOT_FOUND)
    yyerror("ID previously defined");
  $$.name = $1.stringValue;
}

for_init: FOR PARENTHESIS_OPEN for_id IN expression RANGE expression PARENTHESIS_CLOSE DO NEWLINE {
  if (($5.type != BINT && $5.type != BFLOAT) || ($7.type != BINT && $7.type != BFLOAT))
    yyerror("Values in range must be integers\n");
  
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  sprintf(instruction, "%s := %s", $3.name, $5.name);
  emit(instruction);

  strcpy(instruction, "IF ");
  strcat(instruction, $3.name);
  strcat(instruction, " LEI ");

  strcat(instruction, $7.name);
  strcat(instruction, " GOTO");
  
  emit(instruction);
  free(instruction);
  $$.trueList = create_line(line_counter);
  emit("GOTO");
  $$.falseList = create_line(line_counter);
  $$.intValue = line_counter - 1;
  $$.name = $3.name;
};

condition : boolean_expression {
  $$ = $1;
  if($1.type != BBOOL)
    yyerror("Expression result must be boolean");
}

iterative_body: iterative_body save_position iterative_statement { 
  complete($1.nextList, $2.intValue + 1);
  $$.trueList = merge($1.trueList, $3.trueList);
  $$.falseList = merge($1.falseList, $3.falseList);
  $$.nextList = $3.nextList;
} | iterative_statement;


iterative_statement : CONTINUE NEWLINE {
  emit("GOTO"); 
  $$.trueList = create_line(line_counter);
  $$.falseList = NULL;
  $$.nextList = NULL;
};

iterative_statement : BREAK NEWLINE {
  emit("GOTO"); 
  $$.trueList = NULL;
  $$.falseList = create_line(line_counter);
  $$.nextList = NULL;
};

iterative_statement : statement;

expression: FUNC_SQRT PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing sqrt function\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = sqrt_function(&$$, $3);
  else if (current_mode == PRGM)
    status = sqrt_function_c3a(&$$, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad sqrt function\n");
};

expression: FUNC_LOG PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  printf("BISON: Performing log function\n");
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = log_function(&$$, $3);
  else if (current_mode == PRGM)
    status = log_function_c3a(&$$, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad log function\n");
};

expression: PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
  $$ = $2;
};

expression: expression POW expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = pow_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = pow_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad **\n");
};

expression: expression MOD expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = mod_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = mod_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad mod\n");
};

expression: expression MULTIPLY expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = multiply_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = multiply_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad *\n");
};

expression: expression DIVIDE expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = divide_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = divide_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad /\n");
};

expression: expression ADD expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = add_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = add_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad +\n");
};

expression: expression SUBSTRACT expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = substract_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = substract_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad -\n");
};

expression: SUBSTRACT expression %prec MAX_PRIORITY{
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
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = compare_operation(&$$, $1, $2.stringValue, $3);
  else if (current_mode == PRGM)
    status = compare_operation_c3a(&$$, &$1, $2.stringValue, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad comparation\n");
};

boolean_expression: NOT boolean_expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = not_operation(&$$, $2);
  else if (current_mode == PRGM)
    status = not_operation_c3a(&$$, &$2);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad not operation\n");
};

boolean_expression: boolean_expression AND save_position boolean_expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = and_operation(&$$, $1, $4);
  else if (current_mode == PRGM)
    status = and_operation_c3a(&$$, &$1, &$4, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad and operation\n");
};

boolean_expression: boolean_expression OR save_position boolean_expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = or_operation(&$$, $1, $4);
  else if (current_mode == PRGM)
    status = or_operation_c3a(&$$, &$1, &$4, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad or operation\n");
};

boolean_expression: PARENTHESIS_OPEN boolean_expression PARENTHESIS_CLOSE{
  $$ = $2;
};

boolean_expression: ID_B {
  printf("BISON: Looking for ID_B %s\n",$1.stringValue);
  if (sym_lookup($1.stringValue, &$$) == SYMTAB_NOT_FOUND)
    yyerror("ID not defined");
};

boolean_expression: TTRUE {
  emit("GOTO");
  $$ = $1;
  $$.trueList = create_line(line_counter);
  $$.name = utype_to_string($1);
};

boolean_expression: TFALSE {
  emit("GOTO");
  $$ = $1;
  $$.falseList = create_line(line_counter);
  $$.name = utype_to_string($1);
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
  if (current_mode == PRGM)
    for (int i = 0; i < line_counter; i++)
      fprintf(yyout, "%s\n", instructions[i]);
  
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
