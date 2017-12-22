#include "./C3A.h"
#include "./prac3types.h"
#include "bison_aux.h"

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
}

void complete(line *lines, int position) {
  line *line = lines;
  while (line != NULL) {
    char *instruction = instructions[line->line_number - 1];
    char *instruction_complete = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
    sprintf(instruction_complete, "%s %d", instruction, position);
    instructions[line->line_number - 1] = instruction_complete;
    line = line->next;
    free(instruction);
  }
}

/* math operations */
void convert_to_float(uniontype *op) {
  char * temp_var;
  create_variable(&temp_var);

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  sprintf(instruction, "%s := I2F %s", temp_var, op->name);
  emit(instruction);
  free(instruction);
  
  op->name = temp_var;
  op->type = BFLOAT;
}

op_status add_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2) {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));

  if (op1->type == BINT && op2->type == BINT) {
    result->type = BINT;
    create_variable(&result->name);
    sprintf(instruction, "%s := %s ADDI %s", result->name, op1->name, op2->name);
  } else if (op1->type == BFLOAT || op2->type == BFLOAT) {
    if (op1->type == BINT)
      convert_to_float(op1);
    else if (op2->type == BINT)
      convert_to_float(op2);

    create_variable(&result->name);
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s ADDF %s", result->name, op1->name, op2->name);
  }else{
    return OP_FAILED;
  }

  emit(instruction);
  free(instruction);
  
  return OP_SUCCESS;
}

op_status substract_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2) {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));

  if (op1->type == BINT && op2->type == BINT) {
    result->type = BINT;
    create_variable(&result->name);
    sprintf(instruction, "%s := %s SUBI %s", result->name, op1->name, op2->name);
  } else if (op1->type == BFLOAT || op2->type == BFLOAT) {
    if (op1->type == BINT)
      convert_to_float(op1);
    else if (op2->type == BINT)
      convert_to_float(op2);

    create_variable(&result->name);
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s SUBF %s", result->name, op1->name, op2->name);
  } else {
    return OP_FAILED;
  }

  emit(instruction);
  free(instruction);

  return OP_SUCCESS;
}

op_status pow_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2) {
  if ((op1->type != BINT && op1->type != BFLOAT) || (op2->type != BINT && op2->type != BFLOAT))
    return OP_FAILED;

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  sprintf(instruction, "PARAM %s", op1->name);
  emit(instruction);

  sprintf(instruction, "PARAM %s", op2->name);
  emit(instruction);

  sprintf(instruction, "%s := CALL POW,2", result->name);
  emit(instruction);
  free(instruction);
  
  return OP_SUCCESS;
}

op_status multiply_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2) {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));

  if (op1->type == BINT && op2->type == BINT) {
    result->type = BINT;
    create_variable(&result->name);
    sprintf(instruction, "%s := %s MULI %s", result->name, op1->name, op2->name);
  } else if (op1->type == BFLOAT || op2->type == BFLOAT) {
    if (op1->type == BINT)
      convert_to_float(op1);
    else if (op2->type == BINT)
      convert_to_float(op2);

    create_variable(&result->name);
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s MULF %s", result->name, op1->name, op2->name);
  }else{
    return OP_FAILED;
  }

  emit(instruction);
  free(instruction);

  return OP_SUCCESS;
}

op_status divide_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2) {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));

  if ((op2->type == BINT && op2->intValue == 0) || (op2->type == BFLOAT && op2->floatValue == 0.0))
    return OP_FAILED;

  if (op1->type == BINT && op2->type == BINT) {
    result->type = BINT;
    create_variable(&result->name);
    sprintf(instruction, "%s := %s DIVI %s", result->name, op1->name, op2->name);
  } else if (op1->type == BFLOAT || op2->type == BFLOAT) {
    if (op1->type == BINT)
      convert_to_float(op1);
    else if (op2->type == BINT)
      convert_to_float(op2);

    create_variable(&result->name);
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s DIVF %s", result->name, op1->name, op2->name);
  } else {
    return OP_FAILED;
  }

  emit(instruction);
  free(instruction);

  return OP_SUCCESS;
}

op_status mod_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2) {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));

  if (op1->type == BINT && op2->type == BINT) {
    result->type = BINT;
    create_variable(&result->name);
    sprintf(instruction, "%s := %s MODI %s", result->name, op1->name, op2->name);
  } else if (op1->type == BFLOAT || op2->type == BFLOAT) {
    if (op1->type == BINT)
      convert_to_float(op1);
    else if (op2->type == BINT)
      convert_to_float(op2);
    create_variable(&result->name);
    result->type = BFLOAT;
    sprintf(instruction, "%s := %s MODF %s", result->name, op1->name, op2->name);
  }else{
    return OP_FAILED;
  }

  emit(instruction);
  free(instruction);

  return OP_SUCCESS;
}

op_status negate_operation_c3a(uniontype *result, uniontype *op) {
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  result->type = op->type;
  if (op->type == BINT)
    sprintf(instruction, "%s := CHSI %s", result->name, op->name);
  else
    sprintf(instruction, "%s := CHSF %s", result->name, op->name);

  emit(instruction);
  free(instruction);
};

/* boolean operations */
op_status compare_operation_c3a(uniontype *result, uniontype *op1, char *comp, uniontype *op2) {
  result->type = BBOOL;

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  strcpy(instruction, "IF ");
  strcat(instruction, op1->name);

  if (strcmp(comp, ">") == 0)
    strcat(instruction, " GT");
  else if (strcmp(comp, "<") == 0)
    strcat(instruction, " LT");
  else if (strcmp(comp, ">=") == 0)
    strcat(instruction, " GE");
  else if (strcmp(comp, "<=") == 0)
    strcat(instruction, " LE");
  else if (strcmp(comp, "=") == 0)
    strcat(instruction, " EQ ");
  else if (strcmp(comp, "<>") == 0)
    strcat(instruction, " NE ");

  bool add_symbol = (strcmp(comp, "=") != 0 && strcmp(comp, "<>") != 0);
  if (add_symbol && op1->type == BINT && op2->type == BINT)
    strcat(instruction, "I ");
  else if (add_symbol && (op1->type == BFLOAT || op2->type == BFLOAT))
    strcat(instruction, "F ");

  strcat(instruction, op2->name);
  strcat(instruction, " GOTO");
  
  emit(instruction);
  free(instruction);

  result->trueList = create_line(line_counter);

  emit("GOTO");
  result->falseList = create_line(line_counter);
  result->intValue = line_counter;

  return OP_SUCCESS;
}

op_status not_operation_c3a(uniontype *result, uniontype *op) {
  if (op->type == BBOOL) {
    result->type = BBOOL;
    result->trueList = op->falseList;
    result->falseList = op->trueList;
    result->nextList = NULL;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status and_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2, uniontype *m) {
  if (op1->type == BBOOL && op2->type == BBOOL) {
    result->type = BBOOL;
    result->intValue = op1->intValue;
    result->trueList = op2->trueList;
    result->falseList = merge(op1->falseList, op2->falseList);
    result->nextList = NULL;
    complete(op1->trueList, m->intValue + 1);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status or_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2, uniontype *m) {
  if (op1->type == BBOOL && op2->type == BBOOL) {
    result->type = BBOOL;
    result->trueList = merge(op1->trueList, op2->trueList);
    result->falseList = op2->falseList;
    complete(op1->falseList, m->intValue + 1);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

/* functions */

op_status sqrt_function_c3a(uniontype *result, uniontype *op) {
  if (op->type != BINT && op->type != BFLOAT)
    return OP_FAILED;

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  sprintf(instruction, "PARAM %s", op->name);
  emit(instruction);

  sprintf(instruction, "%s := CALL SQRT,1", result->name);
  emit(instruction);
  free(instruction);
  
  return OP_SUCCESS;
}

op_status log_function_c3a(uniontype *result, uniontype *op) {
  if (op->type != BINT && op->type != BFLOAT)
    return OP_FAILED;

  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  sprintf(instruction, "PARAM %s", op->name);
  emit(instruction);

  sprintf(instruction, "%s := CALL LOG,1", result->name);
  emit(instruction);
  free(instruction);
  
  return OP_SUCCESS;
}
