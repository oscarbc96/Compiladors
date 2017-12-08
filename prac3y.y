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
%type <utype> if_init
%type <utype> else_init
%type <utype> elsif_init
%type <utype> elsif_else_fi
%type <utype> elsif_init_emit
%type <utype> if_end
%type <utype> root
%type <utype> condition
%type <utype> while_statement
%type <utype> program_statement
%type <utype> save_position
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

statement : check_mode program_statement save_position { 
  complete($2.nextList, $3.intValue + 1);
};

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

save_position : { $$.intValue = line_counter; }

program_statement : if_statement | while_statement | repeat_statement | for_statement | switch_statement;

if_init : IF PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN { 
  $$.intValue = $3.intValue;
  $$.trueList = NULL;
  $$.falseList = $3.falseList;
  complete($3.trueList, line_counter + 1);
};

if_statement : if_init root save_position elsif_else_fi {
  $$.nextList = merge($4.falseList, $4.nextList);
  complete($1.trueList, $3.intValue);
  complete($1.falseList, $4.intValue - 1);
};

elsif_init_emit : ELSIF { 
  emit("GOTO"); 
  $$.intValue = line_counter + 1; 
  $$.trueList = NULL;
  $$.falseList = create_line(line_counter); 
};

elsif_init : elsif_init_emit PARENTHESIS_OPEN condition PARENTHESIS_CLOSE THEN { 
  $$.intValue = $3.intValue;
  $$.trueList = NULL;
  $$.falseList = $3.falseList;
  $$.nextList = $1.falseList;
  complete($3.trueList, line_counter + 1);
};

elsif_else_fi : elsif_init root save_position elsif_else_fi {
  $$.trueList = NULL;
  $$.falseList = $4.falseList; 
  $$.nextList = merge($1.nextList, $4.nextList);//$1.falseList; //merge($1.falseList, $4.falseList);
  complete($1.trueList, $3.intValue);
  complete($1.falseList, $4.intValue - 1);
};

else_init : ELSE { 
  emit("GOTO"); 
  $$.intValue = line_counter + 2; 
  $$.trueList = NULL; 
  $$.falseList = create_line(line_counter);
  $$.nextList = NULL;
};

elsif_else_fi : else_init root if_end { 
  $$.intValue = $1.intValue;
  $$.trueList = NULL; 
  $$.falseList = merge($1.falseList, $3.falseList);
  $$.nextList = NULL;
};

elsif_else_fi: if_end { $$ = $1; };

if_end : FI { 
  $$.intValue = line_counter + 2; 
  $$.trueList = NULL; 
  $$.falseList = NULL;
  $$.nextList = NULL;
};

switch_statement : SWITCH PARENTHESIS_OPEN switch_id PARENTHESIS_CLOSE DO NEWLINE switch_case DONE {
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
  $$.falseList = create_line(line_counter);
  $$.intValue = line_counter;
};

switch_case : CASE switch_condition THEN save_position root BREAK NEWLINE switch_case_default {
  complete($2.trueList, $4.intValue + 1);
  complete($2.falseList, $8.intValue - 1);
  $$.nextList = $8.nextList;
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

switch_case_default: switch_case_default_init DEFAULT THEN root BREAK NEWLINE { 
  $$.nextList = $1.falseList;
};

while_statement: WHILE save_position PARENTHESIS_OPEN condition PARENTHESIS_CLOSE DO save_position iterative_body DONE{
  complete($4.trueList, $7.intValue + 1);
  complete($8.nextList, $2.intValue);
  complete($8.trueList, $2.intValue + 1);
  $$.nextList = $4.falseList;
  emit("GOTO");
  complete(create_line(line_counter), $2.intValue + 1);
};

repeat_statement: REPEAT save_position iterative_body UNTIL PARENTHESIS_OPEN condition PARENTHESIS_CLOSE{
  complete($6.trueList, $2.intValue + 1);
  complete($3.trueList, $2.intValue + 1);
  $$.nextList = $6.falseList;
}

for_statement: for_init save_position iterative_body DONE {
  complete($1.trueList, $2.intValue + 1);
  complete($3.trueList, $2.intValue - 1);

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  char * temp_variable = (char*) malloc(5 * sizeof(char));
  create_variable(&temp_variable);

  sprintf(instruction, "%s := %s ADDI %s", temp_variable, $1.name, "1");
  emit(instruction);

  sprintf(instruction, "%s := %s", $1.name, temp_variable);
  emit(instruction);

  emit("GOTO");
  complete(create_line(line_counter), $1.intValue);
  $$.nextList = $1.falseList;
}

for_id : ID {
  printf("BISON: Looking for ID %s\n", $1.stringValue);
  if (sym_lookup($1.stringValue, &$$) != SYMTAB_NOT_FOUND)
    yyerror("ID previously defined");
  $$.name = $1.stringValue;
}

for_init: FOR save_position PARENTHESIS_OPEN for_id IN expression RANGE expression PARENTHESIS_CLOSE DO {
  if (($6.type != BINT && $6.type != BFLOAT) || ($8.type != BINT && $8.type != BFLOAT))
    yyerror("Values in range must be integers\n");
  
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  sprintf(instruction, "%s := %s", $4.name, $6.name);
  emit(instruction);

  strcpy(instruction, "IF ");
  strcat(instruction, $4.name);
  strcat(instruction, " LT");

  if($6.type == BINT && $8.type == BINT){
    strcat(instruction, "I ");
  }else if($6.type == BFLOAT || $8.type == BFLOAT){
    strcat(instruction, "F ");
  }

  strcat(instruction, $8.name);
  strcat(instruction, " GOTO");
  
  emit(instruction);
  $$.trueList = create_line(line_counter);
  emit("GOTO");
  $$.falseList = create_line(line_counter);
  $$.intValue = line_counter - 1;
  $$.name = $4.name;
};

condition : boolean_expression {
  $$ = $1;
  if($1.type != BBOOL)
    yyerror("Expression result must be boolean");
}

iterative_body : iterative_body iterative_statement  { $$.trueList = merge($1.trueList, $2.trueList);$$.falseList = merge($1.falseList, $2.falseList);$$.nextList = merge($1.nextList, $2.nextList); }| iterative_statement { $$=$1; };

iterative_statement : CONTINUE {
  emit("GOTO"); 
  $$.trueList = create_line(line_counter);
  $$.falseList = NULL;
  $$.nextList = NULL;
};

iterative_statement : statement  { $$=$1; };

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

boolean_expression: boolean_expression AND boolean_expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = and_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = and_operation_c3a(&$$, &$1, &$3);
  
  if (status == OP_FAILED)
    yyerror("BISON: bad and operation\n");
};

boolean_expression: boolean_expression OR boolean_expression {
  op_status status = OP_FAILED;

  if (current_mode == CALC)
    status = or_operation(&$$, $1, $3);
  else if (current_mode == PRGM)
    status = or_operation_c3a(&$$, &$1, &$3);
  
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
  if (current_mode == PRGM){
    emit("HALT");

    /* optmize goto lines */ 
    for (int i = 0; i < line_counter; i++) {
      if (reg_matches(instructions[i], "[0-9]+: GOTO")){
        int length = optimize_line_str_len(instructions[i]);
        int line = atoi(instructions[i]+length);
        int new_line = optimize_line(line - 1);
        
        if (line != new_line)
          sprintf(instructions[i], "%d: GOTO %d", i+1, new_line);
      }
    }

    for (int i = 0; i < line_counter; i++)
      fprintf(yyout, "%s\n", instructions[i]);
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
