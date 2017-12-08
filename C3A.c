#include "./C3A.h"
#include "./prac3types.h"

void create_variable(char ** variable) {
  *variable = (char*) malloc(5 * sizeof(char));
  sprintf(*variable, "$t%02d", var_counter);
  var_counter++;
}

line * create_line(int line_number) {
  line *line = malloc(sizeof(line));
  line->line_number = line_number;
  line->next = NULL;
  return line;
}

line * merge(line *group1, line *group2) {
  if (group1 == NULL)
    return group2;

  line *result = group1;

  while (group1->next != NULL)
    group1 = (line*) group1->next;

  group1->next = group2;

  return result;
}

op_status emit(char *instruction) {
  if (line_counter >= instructions_capacity) {
    instructions_capacity = instructions_capacity + N_INSTRUCCIONS_ADD;
    instructions = realloc(instructions, instructions_capacity * sizeof(char *));
  }

  instructions[line_counter] = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  sprintf(instructions[line_counter], "%d: %s", line_counter+1, instruction);
  line_counter++;

  printf("BISON: Emiting -> %d: %s\n", line_counter, instruction);
}

void complete(line *lines, int position) {
  line *line = lines;
  while (line != NULL) {
    char *instruction = instructions[line->line_number - 1];
    char *instruction_complete = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
    sprintf(instruction_complete, "%s %d", instruction, position);
    instructions[line->line_number - 1] = instruction_complete;
    printf("BISON: Completing line %d -> %d\n", line->line_number, position);
    line = line->next;
  }
}

/* math operations */
op_status add_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if(op1->type == BSTRING || op2->type == BSTRING){
    result->type = BSTRING;
    sprintf(instruction, "%s := %s ADDS %s", result->name, op1->name, op2->name);
  }else if(op1->type == BINT && op2->type == BINT){
    result->type = BINT;
    result->intValue = op1->intValue + op2->intValue;
    sprintf(instruction, "%s := %s ADDI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    sprintf(instruction, "%s := %s ADDF %s", result->name, op1->name, op2->name);
  }else{
    return OP_FAILED;
  }

  emit(instruction);

  return OP_SUCCESS;
}

op_status substract_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if(op1->type == BINT && op2->type == BINT){
    result->type = BINT;

    sprintf(instruction, "%s := %s SUBI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    sprintf(instruction, "%s := %s SUBF %s", result->name, op1->name, op2->name);
  } else {
    return OP_FAILED;
  }

  emit(instruction);

  return OP_SUCCESS;
}

op_status pow_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  if(op1->type == BINT && op2->type == BINT){
    result->intValue = pow(op1->intValue, op2->intValue);
    result->type = BINT;
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    if(op1->type == BFLOAT && op2->type == BFLOAT){
      result->floatValue = pow(op1->floatValue, op2->floatValue);
    }else if(op1->type == BFLOAT && op2->type == BINT){
      result->floatValue = pow(op1->floatValue, op2->intValue);
    }else if(op1->type == BINT && op2->type == BFLOAT){
      result->floatValue = pow(op1->intValue, op2->floatValue);
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status multiply_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if(op1->type == BINT && op2->type == BINT){
    result->type = BINT;
    sprintf(instruction, "%s := %s MULI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s MULF %s", result->name, op1->name, op2->name);
  }else{
    return OP_FAILED;
  }

  emit(instruction);

  return OP_SUCCESS;
}

op_status divide_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if((op2->type == BINT && op2->intValue == 0) || (op2->type == BFLOAT && op2->floatValue == 0.0)){
    return OP_FAILED;
  }

  if(op1->type == BINT && op2->type == BINT){
    result->intValue = op1->intValue / op2->intValue;
    result->type = BINT;

    sprintf(instruction, "%s := %s DIVI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s DIVF %s", result->name, op1->name, op2->name);
  } else {
    return OP_FAILED;
  }

  emit(instruction);

  return OP_SUCCESS;
}

op_status mod_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if(op1->type == BINT && op2->type == BINT){
    result->type = BINT;
    sprintf(instruction, "%s := %s MODI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s MODF %s", result->name, op1->name, op2->name);
  }else{
    return OP_FAILED;
  }

  emit(instruction);

  return OP_SUCCESS;
}

op_status negate_operation_c3a(uniontype *result, uniontype *op){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if(op->type == BINT){
    result->intValue = -op->intValue;
    result->type = BINT;

    sprintf(instruction, "%s := CHSI %s", result->name, op->name);
  }else if(op->type == BFLOAT){
    result->floatValue = -op->floatValue;
    result->type = BFLOAT;

    sprintf(instruction, "%s := CHSF %s", result->name, op->name);
  }

  emit(instruction);
};

/* boolean operations */
op_status compare_operation_c3a(uniontype *result, uniontype *op1, char *comp, uniontype *op2){
  result->type = BBOOL;

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  strcpy(instruction, "IF ");
  strcat(instruction, op1->name);

  if (strcmp(comp, ">") == 0) {
    strcat(instruction, " GT");
  } else if (strcmp(comp, "<") == 0) {
    strcat(instruction, " LT");
  } else if (strcmp(comp, ">=") == 0) {
    strcat(instruction, " GE");
  } else if (strcmp(comp, "<=") == 0) {
    strcat(instruction, " LE");
  } else if (strcmp(comp, "=") == 0) {
    strcat(instruction, " EQ ");
  } else if (strcmp(comp, "<>") == 0) {
    strcat(instruction, " NE ");
  }

  bool add_symbol = (strcmp(comp, "=") != 0 && strcmp(comp, "<>") != 0);
  if(add_symbol && op1->type == BINT && op2->type == BINT){
    strcat(instruction, "I ");
  }else if(add_symbol && (op1->type == BFLOAT || op2->type == BFLOAT)){
    strcat(instruction, "F ");
  }

  strcat(instruction, op2->name);
  strcat(instruction, " GOTO");
  
  emit(instruction);
  result->trueList = create_line(line_counter);

  emit("GOTO");
  result->falseList = create_line(line_counter);
  result->intValue = line_counter;

  return OP_SUCCESS;
}

op_status not_operation_c3a(uniontype *result, uniontype *op){
  if(op->type == BBOOL){
    result->type = BBOOL;
    result->trueList = op->falseList;
    result->falseList = op->trueList;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status and_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  if(op1->type == BBOOL && op2->type == BBOOL){
    result->type = BBOOL;
    result->intValue = op1->intValue;
    result->trueList = op2->trueList;
    result->falseList = merge(op1->falseList, op2->falseList);
    result->nextList = NULL;
    complete(op1->trueList, op2->intValue - 1);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status or_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  if(op1->type == BBOOL && op2->type == BBOOL){
    result->type = BBOOL;
    result->trueList = merge(op1->trueList, op2->trueList);
    result->falseList = op2->falseList;
    complete(op1->falseList, op2->intValue - 1);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}
