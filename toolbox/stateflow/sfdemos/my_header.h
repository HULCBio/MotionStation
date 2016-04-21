/* $Revision: 1.1 $ */
#include "tmwtypes.h"

extern real_T my_function(real_T x);

/* Definition of custom type */
typedef struct {
	real_T a;
	int8_T b[10];
}MyStruct;

/* External declaration of a global struct variable */
extern MyStruct gMyStructVar;
extern MyStruct *gMyStructPointerVar;

