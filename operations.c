#include "./operations.h"

op_status calculate_result_type(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BSTRING || op2.type == BSTRING){
    result->type = BSTRING;
  }else if(op1.type == BINT && op2.type == BINT){
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

/* math operations */
op_status add_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BSTRING || op2.type == BSTRING){
    result->type = BSTRING;

    if(op1.type == BSTRING && op2.type == BSTRING){
      char * aux = (char *) malloc(1 + strlen(op1.stringValue)+ strlen(op2.stringValue));
      strcpy(aux, op1.stringValue);
      strcat(aux, op2.stringValue);
      result->stringValue = aux;
    }else if(op1.type == BSTRING && op2.type == BINT){
      char * aux = (char *) malloc(1 + strlen(op1.stringValue) + 12);
      sprintf(aux, "%s%i", op1.stringValue, op2.intValue);
      result->stringValue = aux;
    }else if(op1.type == BINT && op2.type == BSTRING){
      char * aux = (char *) malloc(1 + strlen(op2.stringValue) + 12);
      sprintf(aux, "%i%s", op1.intValue, op2.stringValue);
      result->stringValue = aux;
    }else if(op1.type == BSTRING && op2.type == BFLOAT){
      char * aux = (char *) malloc(1 + strlen(op1.stringValue) + 12);
      sprintf(aux, "%s%f", op1.stringValue, op2.floatValue);
      result->stringValue = aux;
    }else if(op1.type == BFLOAT && op2.type == BSTRING){
      char * aux = (char *) malloc(1 + strlen(op2.stringValue) + 12);
      sprintf(aux, "%f%s", op1.floatValue, op2.stringValue);
      result->stringValue = aux;
    }
  }else if(op1.type == BINT && op2.type == BINT){
    result->intValue = op1.intValue + op2.intValue;
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;

    if(op1.type == BFLOAT && op2.type == BFLOAT){
      result->floatValue = op1.floatValue + op2.floatValue;
    }else if(op1.type == BFLOAT && op2.type == BINT){
      result->floatValue = op1.floatValue + op2.intValue;
    }else if(op1.type == BINT && op2.type == BFLOAT){
      result->floatValue = op1.intValue + op2.floatValue;
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status substract_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BINT && op2.type == BINT){
    result->intValue = op1.intValue - op2.intValue;
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;

    if(op1.type == BFLOAT && op2.type == BFLOAT){
      result->floatValue = op1.floatValue - op2.floatValue;
    }else if(op1.type == BFLOAT && op2.type == BINT){
      result->floatValue = op1.floatValue - op2.intValue;
    }else if(op1.type == BINT && op2.type == BFLOAT){
      result->floatValue = op1.intValue - op2.floatValue;
    }
  } else {
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status pow_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BINT && op2.type == BINT){
    result->intValue = pow(op1.intValue, op2.intValue);
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;

    if(op1.type == BFLOAT && op2.type == BFLOAT){
      result->floatValue = pow(op1.floatValue, op2.floatValue);
    }else if(op1.type == BFLOAT && op2.type == BINT){
      result->floatValue = pow(op1.floatValue, op2.intValue);
    }else if(op1.type == BINT && op2.type == BFLOAT){
      result->floatValue = pow(op1.intValue, op2.floatValue);
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status multiply_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BINT && op2.type == BINT){
    result->intValue = op1.intValue * op2.intValue;
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;

    if(op1.type == BFLOAT && op2.type == BFLOAT){
      result->floatValue = op1.floatValue * op2.floatValue;
    }else if(op1.type == BFLOAT && op2.type == BINT){
      result->floatValue = op1.floatValue * op2.intValue;
    }else if(op1.type == BINT && op2.type == BFLOAT){
      result->floatValue = op1.intValue * op2.floatValue;
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status divide_operation(uniontype *result, uniontype op1, uniontype op2){
  if((op2.type == BINT && op2.intValue == 0) || (op2.type == BFLOAT && op2.floatValue == 0.0)){
    return OP_FAILED;
  }

  if(op1.type == BINT && op2.type == BINT){
    result->intValue = op1.intValue / op2.intValue;
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;

    if(op1.type == BFLOAT && op2.type == BFLOAT){
      result->floatValue = op1.floatValue / op2.floatValue;
    }else if(op1.type == BFLOAT && op2.type == BINT){
      result->floatValue = op1.floatValue / op2.intValue;
    }else if(op1.type == BINT && op2.type == BFLOAT){
      result->floatValue = op1.intValue / op2.floatValue;
    }
  } else {
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status mod_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BINT && op2.type == BINT){
    result->intValue = op1.intValue % op2.intValue;
    result->type = BINT;
  }else if(op1.type == BFLOAT || op2.type == BFLOAT){
    result->type = BFLOAT;

    if(op1.type == BFLOAT && op2.type == BFLOAT){
      result->floatValue = fmodf(op1.floatValue, op2.floatValue);
    }else if(op1.type == BFLOAT && op2.type == BINT){
      result->floatValue = fmodf(op1.floatValue, op2.intValue);
    }else if(op1.type == BINT && op2.type == BFLOAT){
      result->floatValue = fmodf(op1.intValue, op2.floatValue);
    }
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status negate_operation(uniontype *result, uniontype op){
  if(op.type == BINT){
    result->intValue = -op.intValue;
    result->type = BINT;
  }else if(op.type == BFLOAT){
    result->floatValue = -op.floatValue;
    result->type = BFLOAT;
  }
};

/* boolean operations */
op_status compare_operation(uniontype *result, uniontype op1, char *comp, uniontype op2){
  result->type = BBOOL;
  if(op1.type == BSTRING && op2.type == BSTRING){
    result->boolValue = strcmp(op1.stringValue, op2.stringValue) == 0;
  }else if(op1.type == BINT && op2.type == BINT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1.intValue > op2.intValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1.intValue < op2.intValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1.intValue >= op2.intValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1.intValue <= op2.intValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1.intValue == op2.intValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1.intValue != op2.intValue;
    }
  }else if(op1.type == BFLOAT && op2.type == BFLOAT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1.floatValue > op2.floatValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1.floatValue < op2.floatValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1.floatValue >= op2.floatValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1.floatValue <= op2.floatValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1.floatValue == op2.floatValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1.floatValue != op2.floatValue;
    }
  }else if(op1.type == BFLOAT && op2.type == BINT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1.floatValue > op2.intValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1.floatValue < op2.intValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1.floatValue >= op2.intValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1.floatValue <= op2.intValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1.floatValue == op2.intValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1.floatValue != op2.intValue;
    }
  }else if(op1.type == BINT && op2.type == BFLOAT){
    if (strcmp(comp, ">") == 0) {
      result->boolValue = op1.intValue > op2.floatValue;
    } else if (strcmp(comp, "<") == 0) {
      result->boolValue = op1.intValue < op2.floatValue;
    } else if (strcmp(comp, ">=") == 0) {
      result->boolValue = op1.intValue >= op2.floatValue;
    } else if (strcmp(comp, "<=") == 0) {
      result->boolValue = op1.intValue <= op2.floatValue;
    } else if (strcmp(comp, "=") == 0) {
      result->boolValue = op1.intValue == op2.floatValue;
    } else if (strcmp(comp, "!=") == 0) {
      result->boolValue = op1.intValue != op2.floatValue;
    }
  } else {
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status not_operation(uniontype *result, uniontype op){
  if(op.type == BBOOL){
    result->type = BBOOL;
    result->boolValue = !op.boolValue;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status and_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BBOOL && op2.type == BBOOL){
    result->type = BBOOL;
    result->boolValue = op1.boolValue && op2.boolValue;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status or_operation(uniontype *result, uniontype op1, uniontype op2){
  if(op1.type == BBOOL && op2.type == BBOOL){
    result->type = BBOOL;
    result->boolValue = op1.boolValue || op2.boolValue;
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

/* functions */
op_status sqrt_function(uniontype *result, uniontype op){
  result->type = BFLOAT;
  if(op.type == BFLOAT){
    result->floatValue = sqrt(op.floatValue);
  }else if(op.type == BINT){
    result->floatValue = sqrt(op.intValue);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}

op_status log_function(uniontype *result, uniontype op){
  result->type = BFLOAT;
  if(op.type == BFLOAT){
    result->floatValue = log(op.floatValue);
  }else if(op.type == BINT){
    result->floatValue = log(op.intValue);
  }else{
    return OP_FAILED;
  }

  return OP_SUCCESS;
}
