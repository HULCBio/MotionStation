/* $Revision: 1.2 $ */
/* This is the source file called from the Stateflow 
   diagram. The function simply takes the input and 
   doubles it */

#include "my_header.h"
#include <stdio.h>

/* Definition of global struct var */
MyStruct gMyStructVar;
MyStruct *gMyStructPointerVar=NULL;

real_T my_function(real_T x)
{
    real_T y;
    
    y=2*x;
    
    return(y);
}
 
