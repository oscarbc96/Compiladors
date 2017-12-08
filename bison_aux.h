#include <stdio.h>
#include <stdlib.h>
#include <regex.h>
#include "prac3types.h"

char * get_type(uniontype value);
char * utype_to_string(uniontype value);
bool reg_matches(char *str, char *pattern);
