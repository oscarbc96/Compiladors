#include "prac2types.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum {OP_SUCCESS, OP_FAILED} op_status;

/* math operations */
op_status add_operation(uniontype *result, uniontype op1, uniontype op2);
op_status substract_operation(uniontype *result, uniontype op1, uniontype op2);
op_status pow_operation(uniontype *result, uniontype op1, uniontype op2);
op_status multiply_operation(uniontype *result, uniontype op1, uniontype op2);
op_status divide_operation(uniontype *result, uniontype op1, uniontype op2);
op_status mod_operation(uniontype *result, uniontype op1, uniontype op2);

/* boolean operations */
op_status compare_operation(uniontype *result, uniontype op1, char *comp, uniontype op2);
op_status not_operation(uniontype *result, uniontype op);
op_status and_operation(uniontype *result, uniontype op1, uniontype op2);
op_status or_operation(uniontype *result, uniontype op1, uniontype op2);

/* functions */
op_status sqrt_function(uniontype *result, uniontype op);
op_status log_function(uniontype *result, uniontype op);
