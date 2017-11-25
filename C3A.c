#include "./C3A.h"
#include "./prac3types.h"

void create_variable(char ** variable) {
  *variable = (char*) malloc(5 * sizeof(char));
  sprintf(*variable, "$t%02d", var_counter);
  var_counter++;
}

line * merge(line *group1, line *group2) {
  if (group1 == NULL)
    return group2;

  line *result = group1;

  while (group1->next != NULL)
    group1 = group1->next;

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
    sprintf(instruction, "%s %d", instruction, position);
    line = line->next;
  }
}

/* math operations */
op_status add_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  char * instruction = (char*) malloc(INSTRUCCION_LENGTH * sizeof(char));
  create_variable(&result->name);

  if(op1->type == BSTRING || op2->type == BSTRING){
    result->type = BSTRING;

    if(op1->type == BSTRING && op2->type == BSTRING){
      char * aux = (char *) malloc(1 + strlen(op1->stringValue)+ strlen(op2->stringValue));
      strcpy(aux, op1->stringValue);
      strcat(aux, op2->stringValue);
      result->stringValue = aux;
    }else if(op1->type == BSTRING && op2->type == BINT){
      char * aux = (char *) malloc(1 + strlen(op1->stringValue) + 12);
      sprintf(aux, "%s%i", op1->stringValue, op2->intValue);
      result->stringValue = aux;
    }else if(op1->type == BINT && op2->type == BSTRING){
      char * aux = (char *) malloc(1 + strlen(op2->stringValue) + 12);
      sprintf(aux, "%i%s", op1->intValue, op2->stringValue);
      result->stringValue = aux;
    }else if(op1->type == BSTRING && op2->type == BFLOAT){
      char * aux = (char *) malloc(1 + strlen(op1->stringValue) + 12);
      sprintf(aux, "%s%f", op1->stringValue, op2->floatValue);
      result->stringValue = aux;
    }else if(op1->type == BFLOAT && op2->type == BSTRING){
      char * aux = (char *) malloc(1 + strlen(op2->stringValue) + 12);
      sprintf(aux, "%f%s", op1->floatValue, op2->stringValue);
      result->stringValue = aux;
    }

    sprintf(instruction, "%s := %s ADDS %s", result->name, op1->name, op2->name);
  }else if(op1->type == BINT && op2->type == BINT){
    result->type = BINT;
    result->intValue = op1->intValue + op2->intValue;
    sprintf(instruction, "%s := %s ADDI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    if(op1->type == BFLOAT && op2->type == BFLOAT){
      result->floatValue = op1->floatValue + op2->floatValue;
    }else if(op1->type == BFLOAT && op2->type == BINT){
      result->floatValue = op1->floatValue + op2->intValue;
    }else if(op1->type == BINT && op2->type == BFLOAT){
      result->floatValue = op1->intValue + op2->floatValue;
    }

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
    result->intValue = op1->intValue - op2->intValue;
    result->type = BINT;

    sprintf(instruction, "%s := %s SUBI %s", result->name, op1->name, op2->name);
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    if(op1->type == BFLOAT && op2->type == BFLOAT){
      result->floatValue = op1->floatValue - op2->floatValue;
    }else if(op1->type == BFLOAT && op2->type == BINT){
      result->floatValue = op1->floatValue - op2->intValue;
    }else if(op1->type == BINT && op2->type == BFLOAT){
      result->floatValue = op1->intValue - op2->floatValue;
    }

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
  if(op1->type == BINT && op2->type == BINT){
    result->intValue = op1->intValue * op2->intValue;
    result->type = BINT;
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    if(op1->type == BFLOAT && op2->type == BFLOAT){
      result->floatValue = op1->floatValue * op2->floatValue;
    }else if(op1->type == BFLOAT && op2->type == BINT){
      result->floatValue = op1->floatValue * op2->intValue;
    }else if(op1->type == BINT && op2->type == BFLOAT){
      result->floatValue = op1->intValue * op2->floatValue;
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status divide_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  if((op2->type == BINT && op2->intValue == 0) || (op2->type == BFLOAT && op2->floatValue == 0.0)){
    return OP_FAILED;
  }

  if(op1->type == BINT && op2->type == BINT){
    result->intValue = op1->intValue / op2->intValue;
    result->type = BINT;
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    if(op1->type == BFLOAT && op2->type == BFLOAT){
      result->floatValue = op1->floatValue / op2->floatValue;
    }else if(op1->type == BFLOAT && op2->type == BINT){
      result->floatValue = op1->floatValue / op2->intValue;
    }else if(op1->type == BINT && op2->type == BFLOAT){
      result->floatValue = op1->intValue / op2->floatValue;
    }
  } else {
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status mod_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  if(op1->type == BINT && op2->type == BINT){
    result->intValue = op1->intValue % op2->intValue;
    result->type = BINT;
  }else if(op1->type == BFLOAT || op2->type == BFLOAT){
    result->type = BFLOAT;

    if(op1->type == BFLOAT && op2->type == BFLOAT){
      result->floatValue = fmodf(op1->floatValue, op2->floatValue);
    }else if(op1->type == BFLOAT && op2->type == BINT){
      result->floatValue = fmodf(op1->floatValue, op2->intValue);
    }else if(op1->type == BINT && op2->type == BFLOAT){
      result->floatValue = fmodf(op1->intValue, op2->floatValue);
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status negate_operation_c3a(uniontype *result, uniontype *op){
  if(op->type == BINT){
    result->intValue = -op->intValue;
    result->type = BINT;
  }else if(op->type == BFLOAT){
    result->floatValue = -op->floatValue;
    result->type = BFLOAT;
  }
};

/* boolean operations */
op_status compare_operation_c3a(uniontype *result, uniontype *op1, char *comp, uniontype *op2){
  result->type = BBOOL;
  if(op1->type == BSTRING && op2->type == BSTRING){
    result->boolValue = strcmp(op1->stringValue, op2->stringValue) == 0;
  }else if(op1->type == BINT && op2->type == BINT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1->intValue > op2->intValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1->intValue < op2->intValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1->intValue >= op2->intValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1->intValue <= op2->intValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1->intValue == op2->intValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1->intValue != op2->intValue;
    }
  }else if(op1->type == BFLOAT && op2->type == BFLOAT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1->floatValue > op2->floatValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1->floatValue < op2->floatValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1->floatValue >= op2->floatValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1->floatValue <= op2->floatValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1->floatValue == op2->floatValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1->floatValue != op2->floatValue;
    }
  }else if(op1->type == BFLOAT && op2->type == BINT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1->floatValue > op2->intValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1->floatValue < op2->intValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1->floatValue >= op2->intValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1->floatValue <= op2->intValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1->floatValue == op2->intValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1->floatValue != op2->intValue;
    }
  }else if(op1->type == BINT && op2->type == BFLOAT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1->intValue > op2->floatValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1->intValue < op2->floatValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1->intValue >= op2->floatValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1->intValue <= op2->floatValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1->intValue == op2->floatValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1->intValue != op2->floatValue;
    }
  } else {
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status not_operation_c3a(uniontype *result, uniontype *op){
  if(op->type == BBOOL){
    result->type = BBOOL;
    result->boolValue = !op->boolValue;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status and_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2){
  if(op1->type == BBOOL && op2->type == BBOOL){
    result->type = BBOOL;
    result->boolValue = op1->boolValue && op2->boolValue;
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
    complete(op1->falseList, line_counter);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}
