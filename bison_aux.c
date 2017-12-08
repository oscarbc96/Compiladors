#include "bison_aux.h"

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

bool reg_matches(char *str, char *pattern){
  regex_t re;
  int ret;

  if (regcomp(&re, pattern, REG_EXTENDED) != 0)
    return false;

  ret = regexec(&re, str, (size_t) 0, NULL, 0);
  regfree(&re);

  if (ret == 0)
    return true;

  return false;
}
