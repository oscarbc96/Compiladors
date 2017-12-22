#include "prac3types.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef prac3op_statusH
  #define prac3op_statusH
  typedef enum {OP_SUCCESS, OP_FAILED} op_status;
#endif

#define N_INSTRUCCIONS_ADD 10
#define INSTRUCCION_LENGTH 50

extern int var_counter;
extern int line_counter;
extern int instructions_capacity;
extern char ** instructions;
void create_variable(char ** variable);
line * create_line(int line_number);
line * merge(line *group1, line *group2);
op_status emit(char *instruction);
void complete(line *lines, int position);

/* math operations */
op_status add_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2);
op_status substract_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2);
op_status pow_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2);
op_status multiply_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2);
op_status divide_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2);
op_status mod_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2);
op_status negate_operation_c3a(uniontype *result, uniontype *op);

/* boolean operations */
op_status compare_operation_c3a(uniontype *result, uniontype *op1, char *comp, uniontype *op2);
op_status not_operation_c3a(uniontype *result, uniontype *op);
op_status and_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2, uniontype *m);
op_status or_operation_c3a(uniontype *result, uniontype *op1, uniontype *op2, uniontype *m);

/* functions */
op_status sqrt_function_c3a(uniontype *result, uniontype *op);
op_status log_function_c3a(uniontype *result, uniontype *op);
